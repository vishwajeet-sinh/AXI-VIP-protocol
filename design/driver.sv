
class axi_driver extends uvm_driver#(axi_tx);
    axi_tx tx;
    //axi_tx req; => by default this line is defined from uvm_driver code
    virtual axi_intf vif;
    `uvm_component_utils(axi_driver)
    function new(string name="", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //vif = axi_config::vif;
        uvm_config_db#(virtual axi_intf)::get(this, "", "vif_a", vif);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("axi_driver", "run_phase", UVM_LOW);
        fork
        forever begin
            seq_item_port.get_next_item(req);
            req.print();
            drive_tx(req);  //no need to change, because it is not sepcific to SV or UVM, it is speicifc to AXI protocol timing diagram
            seq_item_port.item_done();
        end
        forever begin
            @(posedge vif.aclk);
            if (vif.bvalid == 1) begin
                vif.bready = 1;
            end
            if (vif.bvalid == 0) begin
                vif.bready = 0;
            end
            if (vif.rvalid == 0) begin
                vif.rready = 0;
            end
        end
        join
        $display("drive_tx : completed");
    endtask

    task drive_tx(axi_tx tx);
        `uvm_info("axi_driver", "drive_tx", UVM_LOW)
        case (tx.wr_rd)
            WRITE : begin
                write_addr_t(tx);
                write_data_t(tx);
                write_resp_t(tx);
            end
            READ : begin
                read_addr_t(tx);
                read_data_t(tx);
            end
            WRITE_READ : begin
                fork
                begin
                write_addr_t(tx);
                write_data_t(tx);
                write_resp_t(tx);
                end
                begin
                read_addr_t(tx);
                read_data_t(tx);
                end
                join
            end
        endcase
    endtask

    task write_addr_t(axi_tx tx);
        bit ready_f = 0;
        vif.awaddr = tx.write_addr;
        vif.awlen = tx.write_len;
        vif.awsize = tx.write_size;
        vif.awburst = tx.write_type;
        vif.awid = tx.write_id;
        vif.awcache = tx.write_cache;
        vif.awprot = tx.write_prot;
        vif.awvalid = 1'b1;
        //wait for vif.awready
        //wait(vif.awready == 1); //I am not checking it at +edge of clock
        while(ready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.awready) begin
                ready_f = 1;
            end
        end
        @(negedge vif.aclk);
        vif.awvalid = 0;
    endtask

    task write_data_t(axi_tx tx);
        bit ready_f = 0;
    for (int i = 0;  i <= tx.write_len; i++) begin
        vif.wdata = tx.write_dataQ.pop_front();
        vif.wstrb = tx.write_strbQ.pop_front();
        vif.wid = tx.write_id;
        vif.wvalid = 1;
        if (i == tx.write_len) vif.wlast = 1;
        ready_f = 0;
        @(posedge vif.aclk);
        while(ready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.wready) begin
                ready_f = 1;
            end
        end
        vif.wvalid = 0;
        vif.wlast = 0;
    end
    endtask

    task write_resp_t(axi_tx tx);
        bit valid_f;
        valid_f = 0;
    while(valid_f == 0) begin
        @(posedge vif.aclk);
        if (vif.bvalid) begin
            vif.bready = 1;
            valid_f = 1;
            tx.write_resp = vif.bresp;
        end
    end
    endtask

    task read_addr_t(axi_tx tx);
        bit ready_f = 0;
        vif.araddr = tx.read_addr;
        vif.arlen = tx.read_len;
        vif.arsize = tx.read_size;
        vif.arburst = tx.read_type;
        vif.arid = tx.read_id;
        vif.arcache = tx.read_cache;
        vif.arprot = tx.read_prot;
        vif.arvalid = 1'b1;
        @(posedge vif.aclk);
        while(ready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.arready) begin
                ready_f = 1;
            end
        end
        @(posedge vif.aclk);
        vif.arvalid = 0;
    endtask

    task read_data_t(axi_tx tx);
    for (int i = 0; i <= tx.read_len; i++) begin
        @(posedge vif.aclk);
        if (vif.rvalid == 1) begin
            vif.rready = 1;
        end
        //if (i == tx.read_len) begin
        //    wait (vif.rlast == 1);
        //end
    end
    endtask
endclass

//getting tx from generator
//drive them on axi_itnf to DUT
//collect response from DUT througj axi_intf
//give reponse abck to generator