module top;
    //slave instance(dut)
    //program block
    //axi_tb tb();
    `include "test_lib.sv"
    //rst, clk
    logic clk, rstn;
    //itnerface instance
    axi_intf vif(clk, rstn);  //vif is the physical interface handle
    //assertion module
    //apply reset, generate clock
    initial begin
        //axi_config::vif = vif;
        uvm_config_db#(virtual axi_intf)::set(uvm_root::get(), "*", "vif_a", vif);
    end
    initial begin
        //apply reset
        rstn = 0;
        repeat(2) @(posedge clk);
        rstn = 1; //releasing the reset
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        run_test();
    end
    
    /*
    initial begin
        $value$plusargs("testname=%s", axi_config::testname);  //string in to test_no
    end
    */
    endmodule