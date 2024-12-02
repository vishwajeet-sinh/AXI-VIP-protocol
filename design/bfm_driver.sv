class axi_slave_bfm extends uvm_driver#(axi_tx);
    axi_tx tx_wrA[16];
    axi_tx tx_rdA[16];
    bit [31:0] write_addr_t;
    bit [3:0] write_len_t;
    bit [2:0] write_size_t;
    virtual axi_intf vif;
    byte memA[int]; //big memory
    `uvm_component_utils(axi_slave_bfm)
    `NEW
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //vif = axi_config::vif;
        uvm_config_db#(virtual axi_intf)::get(this, "", "vif_a", vif);
    endfunction

    task run_phase(uvm_phase phase);
        //this.vif = axi_config::vif;
        forever begin
            @(posedge vif.aclk);
            if (vif.awvalid == 0) vif.awready = 0;
            if (vif.wvalid == 0) vif.wready = 0;
            if (vif.arvalid == 0) vif.arready = 0;
            if (vif.arvalid) begin //master vip has given valid write address phase, I need to collect info
                tx_rdA[vif.arid] = new();
                tx_rdA[vif.arid].randomize();
                tx_rdA[vif.arid].read_addr = vif.araddr;
                tx_rdA[vif.arid].read_len = vif.arlen;
                tx_rdA[vif.arid].read_size = vif.arsize;
                tx_rdA[vif.arid].read_id = vif.arid;
                tx_rdA[vif.arid].read_prot = vif.arprot;
                tx_rdA[vif.arid].read_cache = vif.arcache;
                tx_rdA[vif.arid].read_lock = vif.arlock;
                vif.arready = 1;  //automatically slave bfm should start doing read data dirivng
                fork
                do_read_data_resp(vif.arid, vif.arlen);
                repeat(2) @(posedge vif.aclk);
                join_any
            end
            if (vif.awvalid) begin //master vip has given valid write address phase, I need to collect info
                tx_wrA[vif.awid] = new();
                tx_wrA[vif.awid].randomize();
                tx_wrA[vif.awid].write_addr = vif.awaddr;
                tx_wrA[vif.awid].write_len = vif.awlen;
                tx_wrA[vif.awid].write_size = vif.awsize;
                tx_wrA[vif.awid].write_id = vif.awid;
                tx_wrA[vif.awid].write_prot = vif.awprot;
                tx_wrA[vif.awid].write_cache = vif.awcache;
                tx_wrA[vif.awid].write_lock = vif.awlock;
                vif.awready = 1;
            end
            if (vif.wvalid) begin
                $display("%t : WRITE DATA PHASE, wlast = %b", $time, vif.wlast);
                write_addr_t = tx_wrA[vif.wid].write_addr;
                write_len_t = tx_wrA[vif.wid].write_len;
                write_size_t = tx_wrA[vif.wid].write_size;
                vif.wready = 1;
                case (write_size_t)
                    0 : begin //1 byte is being written
                        case (vif.wstrb)
                            4'b0001 : begin
                                memA[write_addr_t] = vif.wdata[7:0];
                            end
                            4'b0010 : begin
                                memA[write_addr_t] = vif.wdata[15:8];
                            end
                            4'b0100 : begin
                                memA[write_addr_t] = vif.wdata[23:16];
                            end
                            4'b1000 : begin
                                memA[write_addr_t] = vif.wdata[31:24];
                            end
                            default : begin
                                $display("ERROR");
                            end
                        endcase
                        tx_wrA[vif.wid].write_addr = write_addr_t + 1;
                    end
                    1 : begin  //2 bytes being written
                        case (vif.wstrb)
                            4'b0011 : begin
                                memA[write_addr_t] = vif.wdata[7:0];
                                memA[write_addr_t+1] = vif.wdata[15:8];
                            end
                            4'b1100 : begin
                                memA[write_addr_t] = vif.wdata[23:16];
                                memA[write_addr_t+1] = vif.wdata[31:24];
                            end
                            default : begin
                                $display("ERROR");
                            end
                        endcase
                        tx_wrA[vif.wid].write_addr = write_addr_t + 2;
                    end
                    2 : begin  //4 bytes
                        $display("%t : write addr = %h, data = %h", $time, write_addr_t, vif.wdata);
                        memA[write_addr_t] = vif.wdata[7:0];
                        memA[write_addr_t+1] = vif.wdata[15:8];
                        memA[write_addr_t+2] = vif.wdata[23:16];
                        memA[write_addr_t+3] = vif.wdata[31:24];
                        tx_wrA[vif.wid].write_addr = write_addr_t + 4;
                    end
                    default : begin  //not possible
                        $display("ERROR");
                    end
                endcase
                if (tx_wrA[vif.wid].write_type == 2'b10) tx_wrA[vif.wid].wrap_write_addr();
                if (vif.wlast) begin //done with all data phases
                    @(posedge vif.aclk);
                    $display("%t : START WRITE RESPONSE PHASE", $time);
                    do_write_resp(vif.wid);
                end
            end
        end
    endtask

    task do_read_data_resp(bit [3:0] rid, bit [3:0] arlen);
    bit ready_f;
    $display("%t : calling do_read_data_resp", $time);
    for (int i = 0; i <= arlen; i++) begin
        vif.rvalid = 1;
        vif.rid = rid;
        if (i == arlen) vif.rlast = 1;
        vif.rdata = 
            {memA[tx_rdA[rid].read_addr+3],
            memA[tx_rdA[rid].read_addr+2],
            memA[tx_rdA[rid].read_addr+1],
            memA[tx_rdA[rid].read_addr]};
        @(posedge vif.aclk);
        tx_rdA[rid].read_addr += 4;
        if (tx_rdA[vif.rid].read_type == 2'b10) tx_rdA[vif.rid].wrap_read_addr();
        //ready_f = 0;
        $display("%t: read response and data, read_addr = %h, data = %h", $time, tx_rdA[rid].read_addr, vif.rdata);
        //@(posedge vif.aclk);
        //while(ready_f == 0) begin
        //    @(posedge vif.aclk);
        //    if (vif.rready) begin
        //        ready_f = 1;
        //    end
        //end
        //@(posedge vif.aclk);
        //vif.rvalid = 0;
        //vif.rlast = 0;
        //vif.rdata = 0;
    end
        @(posedge vif.aclk);
        @(posedge vif.aclk);
        vif.rvalid = 0;
        vif.rlast = 0;
        vif.rdata = 0;
    endtask

    task do_write_resp(bit [3:0] bid);
        bit ready_f;
        vif.bresp = 2'b00;
        vif.bvalid = 1;
        vif.bid = bid;
        ready_f = 0;
        //@(posedge vif.aclk);
        while(ready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.bready) begin
                ready_f = 1;
            end
        end
        vif.bvalid = 0;
        $display("%t : COMPLETED WRITE RESPONSE PHASE", $time);
    endtask
endclass