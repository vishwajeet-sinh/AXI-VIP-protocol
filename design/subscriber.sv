class axi_cov extends uvm_subscriber#(axi_tx);
    axi_tx tx;
    `uvm_component_utils(axi_cov)
    covergroup axi_cg;
        AWBURST : coverpoint tx.write_type {
            bins FIXED = {2'b00};
            bins INCR = {2'b01};
            bins WRAP = {2'b10};
            illegal_bins ILL_BINS = {2'b11};
        }
        AWLOCK : coverpoint tx.write_lock {
            bins NORMAL = {2'b00};
            bins EXCL = {2'b01};
            bins LOCKED = {2'b10};
            ignore_bins IGNR_BINS = {2'b11};
        }
        AWLEN : coverpoint tx.write_len;  //16 bins
        AWID : coverpoint tx.write_id {
            option.auto_bin_max = 4;  //0..3, 4..7, 8..11, 12..15
        }
        AWIDXAWLEN : cross AWID, AWLEN;
        //transition coverage
    endgroup

    function new(string name="", uvm_component parent=null); 
        super.new(name, parent); 
        axi_cg = new();
    endfunction

    function void write(axi_tx t);  //this gets called whenever monitor calls, ap.write(tx);
        this.tx = t;
        axi_cg.sample(); //we are triggering coverage smapling once
    endfunction


    /*
    task run();
        $display("axi_cov :: run");
        forever begin
            axi_config::mon2cov.get(tx);
            axi_cg.sample(); //we are triggering coverage smapling once
        end
    endtask
    */
endclass