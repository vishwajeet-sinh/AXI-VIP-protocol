//Monitor the AXI Interface for valid transactionsa(always at posedge of clk)
//Collect address phase, data phase & response phase informaiton fromm interface
//Once whole tx is collected, give it to upper layers(Coverage, reference model)
class axi_mon extends uvm_monitor;
    uvm_analysis_port#(axi_tx) ap_mon;  //object
    virtual axi_intf vif;
    axi_tx tx;
    axi_tx tx_wrA[16];
    axi_tx tx_rdA[16];

    `uvm_component_utils(axi_mon)
    `NEW

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //vif = axi_config::vif;
        uvm_config_db#(virtual axi_intf)::get(this, "", "vif_a", vif);
        ap_mon = new("ap_mon", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.aclk);
            //if (vif.awvalid && vif.awready) begin  //Current cycle write address phase is valid
            if (vif.awvalid) begin  //Current cycle write address phase is valid
                tx_wrA[vif.awid] = new();
                tx_wrA[vif.awid].write_addr = vif.awaddr;
                tx_wrA[vif.awid].write_len = vif.awlen;
                tx_wrA[vif.awid].write_size = vif.awsize;
                tx_wrA[vif.awid].write_type = vif.awburst;
                tx_wrA[vif.awid].write_cache = vif.awcache;
                tx_wrA[vif.awid].write_prot = vif.awprot;
                tx_wrA[vif.awid].write_lock = vif.awlock;
                tx_wrA[vif.awid].write_id = vif.awid;
            end
            if (vif.wvalid && vif.wready) begin  //Current cycle write data phase is valid
                //tx_wrA[vif.awid] = new(); not requried since it will clear the eariler collected write address info
                tx_wrA[vif.wid].write_dataQ.push_back(vif.wdata);
                tx_wrA[vif.wid].write_strbQ.push_back(vif.wstrb);
            end
            if (vif.bvalid && vif.bready) begin  //Current cycle write response phase is valid
                //bresp,
                tx_wrA[vif.bid].write_resp = vif.bresp;
                ap_mon.write(tx_wrA[vif.bid]);
                //axi_config::mon2cov.put(tx_wrA[vif.bid]);
                //axi_config::mon2ref.put(tx_wrA[vif.bid]);
            end
            //if (vif.arvalid && vif.arready) begin  //Current cycle read address phase is valid
            if (vif.arvalid) begin  //Current cycle read address phase is valid
                tx_rdA[vif.arid] = new();
                tx_rdA[vif.arid].read_addr = vif.araddr;
                tx_rdA[vif.arid].read_len = vif.arlen;
                tx_rdA[vif.arid].read_size = vif.arsize;
                tx_rdA[vif.arid].read_type = vif.arburst;
                tx_rdA[vif.arid].read_cache = vif.arcache;
                tx_rdA[vif.arid].read_prot = vif.arprot;
                tx_rdA[vif.arid].read_lock = vif.arlock;
                tx_rdA[vif.arid].read_id = vif.arid;
            end
            if (vif.rvalid && vif.rready) begin  //Current cycle read data & repsonse phase is valid
                tx_rdA[vif.rid].read_dataQ.push_back(vif.rdata);
                tx_rdA[vif.rid].read_respQ.push_back(vif.rresp);
                if (vif.rlast) begin
                    //axi_config::mon2cov.put(tx_rdA[vif.rid]);
                    //axi_config::mon2ref.put(tx_rdA[vif.rid]);
                    ap_mon.write(tx_rdA[vif.rid]);
                end
            end
        end
    endtask
endclass