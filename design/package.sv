`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "axi_config.sv"
`include "axi_intf.sv"
`include "axi_tx.sv"
`include "axi_seq_lib.sv"
`include "axi_slave_bfm.sv"
`include "axi_driver.sv"
`include "axi_sqr.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_agent.sv"
//`include "axi_tb.sv"
`include "top.sv"


class axi_agent extends uvm_env;
    axi_driver driver;
    axi_slave_bfm slave_bfm;
    axi_sqr sqr;
    axi_mon mon;
    axi_cov cov;
    `uvm_component_utils(axi_agent)
    `NEW
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = axi_driver::type_id::create("driver", this);
        slave_bfm = axi_slave_bfm::type_id::create("slave_bfm", this);
        sqr = axi_sqr::type_id::create("sqr", this);
        mon = axi_mon::type_id::create("mon", this);
        cov = axi_cov::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sqr.seq_item_export);
    endfunction
    /*
    task run();
        $display("axi_env :: run");
        fork
            bfm.run();
            sqr.run();
            mon.run();
            cov.run();
        join
    endtask
    */
endclass


typedef enum {
    READ,
    WRITE,
    WRITE_READ
} wr_rd_e;
`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define STRB_WIDTH 4
`define ID_WIDTH 4

`define NEW
    function new(string name="", uvm_component parent=null);
        super.new(name, parent);
    endfunction

`define NEW_OBJ
    function new(string name="");
        super.new(name);
    endfunction


class axi_config; //it is class used to store all the commonly used varaibles
    static string testname;
    static mailbox gen2bfm = new();
    static mailbox bfm2gen = new();
    static mailbox mon2cov = new();
    static mailbox mon2ref = new();
    static virtual axi_intf vif;
endclass


