
/*#############################################################################################
//top.sv
##############################################################################################*/
module top;
axi_assertion  assert_dut(
    .aclk(pif.aclk),
    .arstn(pif.arstn),
    .awvalid(pif.awvalid),
    .awready(pif.awready)
);

//1. design instiantion
axi_slave  dut(
    .aclk(pif.aclk),
    .arstn(pif.arstn),
    //write addr channel
    .awaddr(pif.awaddr),
    .awlen(pif.awlen),
    .awsize(pif.awsize),
    .awburst(pif.awburst),
    .awcache(pif.awcache),
    .awprot(pif.awprot),
    .awlock(pif.awlock),
    .awid(pif.awid),
    .awvalid(pif.awvalid),
    .awready(pif.awready),
    //Write data channel
    .wdata(pif.wdata),
    .wstrb(pif.wstrb),
    .wid(pif.wid),
    .wvalid(pif.wvalid),
    .wready(pif.wready),
    .wlast(pif.wlast),
    //write response channel
    .bid(pif.bid),
    .bresp(pif.bresp),
    .bvalid(pif.bvalid),
    .bready(pif.bready),
    //read address channel
    .araddr(pif.araddr),
    .arlen(pif.arlen),
    .arsize(pif.arsize),
    .arburst(pif.arburst),
    .arcache(pif.arcache),
    .arprot(pif.arprot),
    .arlock(pif.arlock),
    .arid(pif.arid),
    .arvalid(pif.arvalid),
    .arready(pif.arready),
    //read data & resp channel
    .rdata(pif.rdata),
    .rid(pif.rid),
    .rvalid(pif.rvalid),
    .rready(pif.rready),
    .rlast(pif.rlast),
    .rresp(pif.rresp)
        );


//2. clk, rst declaration, generation
reg clk, rst;
//3. interface instinaitons
axi_intf  pif(clk, rst);
//4. testbench instinaitons
axi_tb tb();
//5. assertion module instinaitons
//6. logic to decide when to end simultion(when to call $finish)
initial begin
    #5000;
    $finish();
end


//clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//7. logic to read the testname
initial begin
    $value$plusargs("testname=%s",axi_cfg::testname);  //Process#1
    axi_cfg::vif = pif;
    axi_cfg::testread_f = 1;
end
endmodule
/*#############################################################################################
//        axi_slave.sv
##############################################################################################*/
module axi_slave(
    aclk,
    arstn,
    //write addr channel
    awaddr,
    awlen,
    awsize,
    awburst,
    awcache,
    awprot,
    awlock,
    awid,
    awvalid,
    awready,
    //Write data channel
    wdata,
    wstrb,
    wid,
    wvalid,
    wready,
    wlast,
    //write response channel
    bid,
    bresp,
    bvalid,
    bready,
    //read address channel
    araddr,
    arlen,
    arsize,
    arburst,
    arcache,
    arprot,
    arlock,
    arid,
    arvalid,
    arready,
    //read data & resp channel
    rdata,
    rid,
    rvalid,
    rready,
    rlast,
    rresp
);
input aclk;
input arstn;
input [3:0] awid;
input [31:0] awaddr;
input [2:0] awsize;
input [3:0] awlen;
input [1:0] awlock;
input [1:0] awburst;
input [3:0] awcache;
input [1:0] awprot;
input awvalid;
output reg awready;

input [31:0]    wdata;
input [3:0]    wstrb;
input [3:0]    wid;
input [0:0]    wvalid;
output reg [0:0]    wready;
input [0:0]    wlast;

output reg [3:0] bid;
output reg [1:0] bresp;
output reg [0:0] bvalid;
input bready;

input [3:0] arid;
input [31:0] araddr;
input [2:0] arsize;
input [3:0] arlen;
input [1:0] arlock;
input [1:0] arburst;
input [3:0] arcache;
input [1:0] arprot;
input arvalid;
output reg arready;

output reg [31:0]    rdata;
output reg [3:0]    rid;
output reg [0:0]    rvalid;
input [0:0]    rready;
output reg [0:0] rlast;
output reg [1:0] rresp;

byte mem[*];
bit [31:0] awaddr_t_arr[16];
bit [3:0] awlen_t_arr[16];
bit [2:0] awsize_t_arr[16];
bit [1:0] awburst_t_arr[16];

bit [31:0] araddr_t_arr[16];
bit [3:0] arlen_t_arr[16];
bit [2:0] arsize_t_arr[16];
bit [1:0] arburst_t_arr[16];

    bit bready_f = 0;

always @(posedge aclk) begin
    if (awvalid == 1) begin
        awready = 1;
        //also stote the infromation 
        awaddr_t_arr[awid] = awaddr; ///TX1(32'h1000) even before TX1 gets over, I can start TX2 //1000
        awlen_t_arr[awid] = awlen; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
        awsize_t_arr[awid] = awsize; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
        awburst_t_arr[awid] = awburst; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
    end
    if (awvalid == 0) begin
        awready = 0;
    end
    //Handdle write data phase
    if (wvalid == 1) begin
        wready = 1;
        //also stote the infromation write data phase will happen data being written to slave, slave needs to store the data
        mem[awaddr_t_arr[wid]] = wdata[7:0];
        mem[awaddr_t_arr[wid]+1] = wdata[15:8];
        mem[awaddr_t_arr[wid]+2] = wdata[23:16];
        mem[awaddr_t_arr[wid]+3] = wdata[31:24];
        awaddr_t_arr[wid] = awaddr_t_arr[wid]+4;
    end
    if (wvalid == 0) begin
        wready = 0;
    end
    if (wlast == 1) begin
        do_write_resp(wid);
    end
end

always @(posedge aclk) begin
    if (arvalid == 1) begin
        arready = 1;
        //also stote the infromation 
        araddr_t_arr[arid] = araddr; ///TX1(32'h1000) even before TX1 gets over, I can start TX2 //1000
        arlen_t_arr[arid] = arlen; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
        arsize_t_arr[arid] = arsize; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
        arburst_t_arr[arid] = arburst; ///TX1(32'h1000) even before TX1 gets over, I can start TX2
        do_read_data_phase(arid);
    end
    if (arvalid == 0) begin
        arready = 0;
    end
end

task do_read_data_phase(input [31:0] arid_t);
    bit rready_f;
    int i;


for (i = 0; i <= arlen_t_arr[arid_t]; i++) begin
    rdata[7:0] = mem[araddr_t_arr[arid_t]];
    rdata[15:8] = mem[araddr_t_arr[arid_t]+1];
    rdata[23:16] = mem[araddr_t_arr[arid_t]+2];
    rdata[31:24] = mem[araddr_t_arr[arid_t]+3];
    rid = arid;
    rvalid = 1;
    rresp = 2'b00;
    araddr_t_arr[arid_t] = araddr_t_arr[arid_t] + 4;
    if (i == arlen_t_arr[arid_t]) rlast = 1;
    //wait for rready
    rready_f = 0;
    while(rready_f == 0) begin
        @(posedge aclk);
        if (rready == 1) rready_f = 1;
    end
    @(negedge aclk);
    rvalid = 0;
    rlast = 0;
end
endtask

task do_write_resp(input [3:0] bid_t);
    @(posedge aclk);
    bid = bid_t;
    bresp = 2'b00;
    bvalid = 1;
    //handing concept
    bready_f = 0;
    while (bready_f == 0) begin
        @(posedge aclk);
        if (bready == 1) bready_f = 1;
    end
    @(negedge aclk);
    bvalid = 0;
endtask

endmodule
/*#############################################################################################
//        axi_tx.sv
##############################################################################################*/
typedef enum {
    READ,
    WRITE,
    READ_WRITE
} tx_type_t;

typedef enum {
    FIXED,
    INCR,
    WRAP
} burst_type_t;

typedef enum {
    NORMAL,
    LOCKED,
    EXCL
}  lock_t;

class axi_tx;
    //properties
    //write channels fields
    rand tx_type_t tx_type;
    rand bit [31:0] waddr;
    rand bit [31:0] wdataQ[$:15];
    rand bit [3:0] wstrbQ[$:15];
    rand bit [3:0] wlen;
    rand burst_type_t wburst;
    rand bit [2:0] wsize;
    rand bit [3:0] wcache; //cahcble, bufferable, write-througk, allocate
    rand lock_t wlock;
    rand bit [1:0] wprot;
    rand bit [3:0] wid;  //Write transaction ID
    bit [1:0] wresp;
    //bit wvalid;  //NO : these signals correspnds to handshaking, which is the role of BFM, it is not for transaction
    //bit wready;
    //read channels fields
    rand bit [31:0] raddr;
    rand bit [31:0] rdataQ[$:15];
    rand bit [3:0] rlen;
    rand burst_type_t rburst;
    rand bit [2:0] rsize;
    rand bit [3:0] rcache; //cahcble, bufferable, rrite-througk, allocate
    rand lock_t rlock;
    rand bit [1:0] rprot;
    rand bit [3:0] rid;  //Write transaction ID
    rand bit [1:0] rrespQ[$:16];
    //methods
    //eth_pkt : print, copy, compare, pack,unpack
    //axi_tx : print, copy, compare, 
    function void print();
            $display("###################Pritnign AXI_TX ###############");
        if (tx_type == WRITE) begin
            //display only read fields above
            $display("Pritnign Write fields");
            $display("write_id = %h", wid);
            $display("write_addr = %h", waddr);
            $display("write_dataQ = %p", wdataQ);
            $display("write_len = %h", wlen);
            $display("write_size = %h", wsize);
            $display("write_burst = %h", wburst);
            $display("write_len = %h", wlen);
        end
        if (tx_type == READ) begin
            //display only write fields above
            $display("Printing Read fields");
            $display("read_id = %h", rid);
            $display("read_addr = %h", raddr);
            $display("read_dataQ = %p", rdataQ);
            $display("read_len = %h", rlen);
            $display("read_size = %h", rsize);
            $display("read_burst = %h", rburst);
            $display("read_len = %h", rlen);
        end
        if (tx_type == READ_WRITE) begin
            //display only write and read fields above
            $display("Pritnign Write fields");
            $display("write_id = %h", wid);
            $display("write_addr = %h", waddr);
            $display("write_dataQ = %p", wdataQ);
            $display("write_len = %h", wlen);
            $display("write_size = %h", wsize);
            $display("write_burst = %h", wburst);
            $display("write_len = %h", wlen);
            //display only write fields above
            $display("Printing Read fields");
            $display("read_id = %h", rid);
            $display("read_addr = %h", raddr);
            $display("read_dataQ = %p", rdataQ);
            $display("read_len = %h", rlen);
            $display("read_size = %h", rsize);
            $display("read_burst = %h", rburst);
            $display("read_len = %h", rlen);
        end
    endfunction

    function void copy(output axi_tx tx);
        tx = new();
        tx.tx_type = this.tx_type; //do this for all otehr fields
        tx.waddr = this.waddr; 
    endfunction

    function bit compare(axi_tx tx);
        if ( tx.tx_type != this.tx_type ) begin
            $display("FAILED : Tx type itself does not match, exiting compare with fail!!");
            return 0;
        end
        case (tx_type)
            WRITE : begin
                if (
                    tx.waddr != this.waddr ||
                    tx.wid != this.wid ||
                    tx.wlock != this.wlock ||
                    tx.wcache != this.wcache ||
                    tx.wlen != this.wlen ||
                    tx.wsize != this.wsize ||
                    tx.wburst != this.wburst
                    //also compare wdataQ, wstrbQ, wresp
                ) begin
                    $display("FAILED : Write Tx fields does not match");
                    return 0;
                end
            end
            READ : begin
                if (
                    tx.raddr != this.raddr ||
                    tx.rid != this.rid ||
                    tx.rlock != this.rlock ||
                    tx.rcache != this.rcache ||
                    tx.rlen != this.rlen ||
                    tx.rsize != this.rsize ||
                    tx.rburst != this.rburst
                    //rdataQ
                ) begin
                    $display("FAILED : Write Tx fields does not match");
                    return 0;
                end
            end
            READ_WRITE : begin
            end
        endcase
    endfunction
    //constraints
    constraint wdataQ_c { wdataQ.size() == wlen + 1; }
    constraint wstrbQ_c { wstrbQ.size() == wlen + 1; }
    constraint rdataQ_c { rdataQ.size() == rlen + 1; }
    constraint rrespQ_c { rrespQ.size() == rlen + 1; }
    constraint wprot_c {wprot != 2'b11;}
    constraint rprot_c {rprot != 2'b11;}

endclass
/*#############################################################################################
//        axi_intf.sv
##############################################################################################*/
interface axi_intf(input logic aclk, input logic arstn);
logic [3:0] awid;
logic [31:0] awaddr;
logic [2:0] awsize;
logic [3:0] awlen;
logic [1:0] awlock;
logic [1:0] awburst;
logic [3:0] awcache;
logic [1:0] awprot;
logic awvalid;
logic awready;

logic [31:0]    wdata;
logic [3:0]    wstrb;
logic [3:0]    wid;
logic [0:0]    wvalid;
logic [0:0]    wready;
logic [0:0]    wlast;

logic [3:0] bid;
logic [1:0] bresp;
logic [0:0] bvalid;
logic bready;

logic [3:0] arid;
logic [31:0] araddr;
logic [2:0] arsize;
logic [3:0] arlen;
logic [1:0] arlock;
logic [1:0] arburst;
logic [3:0] arcache;
logic [1:0] arprot;
logic arvalid;
logic arready;

logic [31:0]    rdata;
logic [3:0]    rid;
logic [0:0]    rvalid;
logic [0:0]    rready;
logic [0:0] rlast;
logic [1:0] rresp;

endinterface
/*#############################################################################################
//        axi_cfg.sv
##############################################################################################*/
class axi_cfg;
    static mailbox gen2bfm = new();
    static mailbox bfm2gen = new();
    static mailbox mon2cov = new();
    static string testname;
    static bit testread_f = 0;
    static virtual axi_intf vif;
endclass
/*#############################################################################################
//        axi_gen.sv
##############################################################################################*/
class axi_gen;
    axi_tx tx, tx_t;
    axi_tx wrtxQ[$];
    axi_tx tx_resp;
    task run();
        $display("axi_gen :: run");
        case (axi_cfg::testname)
            "TEST_SINGLE_WRITE_READ" : begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE; tx.wlen == 0;});
                axi_cfg::gen2bfm.put(tx);
                $cast (tx_t, tx);
                tx = new();
                assert(tx.randomize() with {tx.tx_type == READ; 
                                tx.raddr == tx_t.waddr; 
                                tx.rlen == 0; 
                                tx.rsize == tx_t.wsize; 
                                tx.rburst == tx_t.wburst;}
                                );
                axi_cfg::gen2bfm.put(tx);
            end
            "TEST_TWO_WRITE_READ" : begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE; tx.wlen == 1;});
                axi_cfg::gen2bfm.put(tx);
                $cast (tx_t, tx);
                tx = new();
                assert(tx.randomize() with {tx.tx_type == READ; 
                                tx.raddr == tx_t.waddr; 
                                tx.rlen == 1; 
                                tx.rsize == tx_t.wsize; 
                                tx.rburst == tx_t.wburst;}
                                );
                axi_cfg::gen2bfm.put(tx);
            end
            "TEST_16_WRITE_READ" : begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE; tx.wlen == 15;});
                axi_cfg::gen2bfm.put(tx);
                $cast (tx_t, tx);
                tx = new();
                assert(tx.randomize() with {tx.tx_type == READ; 
                                tx.raddr == tx_t.waddr; 
                                tx.rlen == 15; 
                                tx.rsize == tx_t.wsize; 
                                tx.rburst == tx_t.wburst;}
                                );
                axi_cfg::gen2bfm.put(tx);
            end
            "TEST_16_WRITE_READ_2" : begin
            repeat(2) begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE; tx.wlen == 15;});
                axi_cfg::gen2bfm.put(tx);
                $cast (tx_t, tx);
                tx = new();
                assert(tx.randomize() with {tx.tx_type == READ; 
                                tx.raddr == tx_t.waddr; 
                                tx.rlen == 15; 
                                tx.rsize == tx_t.wsize; 
                                tx.rburst == tx_t.wburst;}
                                );
                axi_cfg::gen2bfm.put(tx);
            end
            end
            "TEST_10_WR_TX" : begin
               for (int i = 0; i < 10; i++) begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE;});
                axi_cfg::gen2bfm.put(tx);
               end
            end
            "TEST_10_RD_TX" : begin
               for (int i = 0; i < 10; i++) begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == READ;});
                axi_cfg::gen2bfm.put(tx);
               end
            end
            "TEST_10_WR_10_RD_COMPARE_TX" : begin
                //read 10 times from same 10 locaitons above
                //then compare the data that is written to data that is read

               //write 10 times to random locations
               for (int i = 0; i < 10; i++) begin
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE;});
                axi_cfg::gen2bfm.put(tx);
                wrtxQ.push_back(tx); //stroing the tx's into Q, so that it will be used for readtx & for comapre
               end
                //now Q has 10 tx's, each of type write tx
               //read 10 times to same locations as of write
               for (int i = 0; i < 10; i++) begin
                tx = new();
                assert(tx.randomize() with {
                    tx.tx_type == READ;
                    tx.raddr == wrtxQ[i].waddr; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rlen == wrtxQ[i].wlen; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rburst == wrtxQ[i].wburst; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rprot == wrtxQ[i].wprot; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rcache == wrtxQ[i].wcache; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rsize == wrtxQ[i].wsize; //in 1st iteration of read, I shoule 1st element of Q
                      }); //??
                axi_cfg::gen2bfm.put(tx);
               end
               //Compare
               //what all things to compare?  len, data
               for (int i = 0; i < 10; i++) begin
                   axi_cfg::bfm2gen.get(tx_resp);
                   //I need to compare tx_resp with tx done durign write phase(not read cycle)
                   //compare addr
                   if (wrtxQ[i].waddr != tx_resp.raddr) begin
                       $display("FAILED : Address does not match");
                       return;
                   end
                   if (wrtxQ[i].wdataQ.size() != tx_resp.rdataQ.size()) begin
                       $display("FAILED : DataQ size does not match, WriteDataQ.Size=%d, ReadDataQ.Size= %d", wrtxQ[i].wdataQ.size(), tx_resp.rdataQ.size());
                       return;  //no need to do further compares
                   end
                   foreach (wrtxQ[i].wdataQ[i]) begin
                       if (wrtxQ[i].wdataQ[i] != tx_resp.rdataQ[i]) begin
                           $display("FAILED : Data value does not match, WriteData=%h, ReadData= %h", wrtxQ[i].wdataQ[i], tx_resp.rdataQ[i]);
                           return;  //no need to do further compares
                       end
                   end
               end
            end
            "TEST_WR_RD_ADDR_1000" : begin
                //Write
                tx = new();
                assert(tx.randomize() with {tx.tx_type == WRITE; tx.waddr == 32'h1000;});
                axi_cfg::gen2bfm.put(tx);
                wrtxQ.push_back(tx); //stroing the tx's into Q, so that it will be used for readtx & for comapre
                //Write
                tx = new();
                assert(tx.randomize() with {
                    tx.tx_type == READ;
                    tx.raddr == wrtxQ[0].waddr; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rlen == wrtxQ[0].wlen; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rburst == wrtxQ[0].wburst; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rprot == wrtxQ[0].wprot; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rcache == wrtxQ[0].wcache; //in 1st iteration of read, I shoule 1st element of Q
                    tx.rsize == wrtxQ[0].wsize; //in 1st iteration of read, I shoule 1st element of Q
                      }); //??
                axi_cfg::gen2bfm.put(tx);
            end
        endcase
    endtask
endclass
/*#############################################################################################
//        axi_bfm.sv
##############################################################################################*/
class axi_bfm;
    axi_tx tx;
    virtual axi_intf vif;
    task run();
        $display("axi_bfm :: run");
        vif = axi_cfg::vif;
        forever begin
            axi_cfg::gen2bfm.get(tx);
            tx.print();
            //drive the tx to the slave using interface
            drive_tx(tx);
        end
    endtask

    task drive_tx(axi_tx tx);
        //if write : write_addr, multiple write data, write resp
        if (tx.tx_type == WRITE) begin
            write_addr(tx);
            write_data(tx);
            write_resp(tx);
        end
        //if read : read_addr, multiple read data
        if (tx.tx_type == READ) begin
            read_addr(tx);
            read_data(tx);
        end
        //if write & read : combine above 2
        if (tx.tx_type == READ_WRITE) begin
        fork
        begin
            read_addr(tx);
            read_data(tx);
        end
        begin
            write_addr(tx);
            write_data(tx);
            write_resp(tx);
        end
        join
        end
    endtask

    task write_addr(axi_tx tx);
        bit awready_f = 0;
        $display("axi_bfm :: write_addr");
        //master will give which address to write to, what is the length, size, prot, cache, etc, then slave will say that I am ready by asserting awready=1, we have to wait till this condition
        vif.awaddr = tx.waddr;
        vif.awburst = tx.wburst;
        vif.awlen = tx.wlen;
        vif.awsize = tx.wsize;
        vif.awcache = tx.wcache;
        vif.awprot = tx.wprot;
        vif.awlock = tx.wlock;
        vif.awid = tx.wid;
        vif.awvalid = 1'b1; //I am telling to teh slave, that I am giving valid tx write address info to you
        while(awready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.awready == 1) begin
                awready_f = 1;  //awready has come now, exit while loop
            end
        end
        vif.awvalid = 0;
        @(negedge vif.aclk);
        $display("axi_bfm :: write_addr compelted");
    endtask
    task write_data(axi_tx tx);
        bit wready_f = 0;
        $display("axi_bfm :: write_data");
        for (int i = 0; i <= tx.wlen; i++) begin
            $display("axi_bfm :: write_data phase :: %d", i);
            vif.wdata = tx.wdataQ[i];
            vif.wstrb = tx.wstrbQ[i];
            vif.wid = tx.wid;
            vif.wvalid = 1'b1;
            if (i == tx.wlen) vif.wlast = 1;
            while(wready_f == 0) begin
                @(posedge vif.aclk);
                if (vif.wready == 1) begin
                    wready_f = 1;  //wready has come now, exit while loop
                end
            end
            vif.wvalid = 0;
            vif.wlast = 0;
            wready_f = 0;
        end
    endtask
    task write_resp(axi_tx tx);
        bit bvalid_f = 0;
        $display("axi_bfm :: write_resp");
        bvalid_f = 0;
        while (bvalid_f == 0) begin
            @(posedge vif.aclk);
            if (vif.bvalid == 1) begin
                bvalid_f = 1;
                vif.bready = 1;
            end
        end
        @(negedge vif.aclk);
        //vif.bready = 0;
    endtask
    task read_addr(axi_tx tx);
        bit arready_f = 0;
        $display("axi_bfm :: read_addr");
        //master will give which address to read to, what is the length, size, prot, cache, etc, then slave will say that I am ready by asserting arready=1, we have to wait till this condition
        vif.araddr = tx.raddr;
        vif.arburst = tx.rburst;
        vif.arlen = tx.rlen;
        vif.arsize = tx.rsize;
        vif.arcache = tx.rcache;
        vif.arprot = tx.rprot;
        vif.arlock = tx.rlock;
        vif.arid = tx.rid;
        vif.arvalid = 1'b1; //I am telling to teh slave, that I am giving valid tx read address info to you
        while(arready_f == 0) begin
            @(posedge vif.aclk);
            if (vif.arready == 1) begin
                arready_f = 1;  //arready has come now, exit while loop
            end
        end
        vif.arvalid = 0;
        @(negedge vif.aclk);
        $display("axi_bfm :: read_addr compelted");
    endtask
    task read_data(axi_tx tx);
        bit rvalid_f = 0;
        $display("axi_bfm :: read_data");
    for (int i = 0; i <= tx.rlen; i++) begin
        rvalid_f = 0;
        while(rvalid_f == 0) begin
            if (vif.rvalid == 1) begin
                rvalid_f = 1;
                vif.rready = 1;
                $display("read data = %h", vif.rdata);
            end
        end
        @(negedge vif.aclk);
        vif.rready = 0;
    end
        $display("axi_bfm :: read_data completed");
    endtask
endclass

/*#############################################################################################
//        axi_mon.sv
##############################################################################################*/
class axi_mon;
    virtual axi_intf vif;
    axi_tx tx;
    axi_tx tx_wr_arr[16];
    axi_tx tx_rd_arr[16];
    task run();
    $display("axi_mon :: run");
    vif = axi_cfg::vif;
    while(1) begin
        @(posedge vif.aclk);
        if (vif.awvalid && vif.awready) begin //start of a transaciton
            $display("axi_mon :: write_addr valid");
            tx_wr_arr[vif.awid] = new();
            tx_wr_arr[vif.awid].tx_type = WRITE;
            tx_wr_arr[vif.awid].waddr = vif.awaddr;
            tx_wr_arr[vif.awid].wlen = vif.awlen;
            tx_wr_arr[vif.awid].wsize = vif.awsize;
            tx_wr_arr[vif.awid].wburst = burst_type_t'(vif.awburst);
            tx_wr_arr[vif.awid].wprot = vif.awprot;
            tx_wr_arr[vif.awid].wcache = vif.awcache;
            tx_wr_arr[vif.awid].wlock = lock_t'(vif.awlock);
            tx_wr_arr[vif.awid].wid = vif.awid;
        end
        if (vif.wvalid && vif.wready) begin
            $display("axi_mon :: write_data valid");
            tx_wr_arr[vif.wid].wdataQ.push_back(vif.wdata);
            tx_wr_arr[vif.wid].wstrbQ.push_back(vif.wstrb);
        end
        if (vif.bvalid && vif.bready) begin
            $display("axi_mon :: write_resp valid");
            tx_wr_arr[vif.bid].wresp = vif.bresp;
            //now give the tx to coverage
            axi_cfg::mon2cov.put(tx_wr_arr[vif.bid]);
        end
        if (vif.arvalid && vif.arready) begin
            $display("axi_mon :: read_addr valid");
            tx_rd_arr[vif.arid] = new();
            tx_rd_arr[vif.arid].tx_type = READ;
            tx_rd_arr[vif.arid].raddr = vif.araddr;
            tx_rd_arr[vif.arid].rlen = vif.arlen;
            tx_rd_arr[vif.arid].rsize = vif.arsize;
            tx_rd_arr[vif.arid].rburst = burst_type_t'(vif.arburst);
            tx_rd_arr[vif.arid].rprot = vif.arprot;
            tx_rd_arr[vif.arid].rcache = vif.arcache;
            tx_rd_arr[vif.arid].rlock = lock_t'(vif.arlock);
            tx_rd_arr[vif.arid].rid = vif.arid;
        end
        if (vif.rvalid && vif.rready) begin
            $display("axi_mon :: read_data valid");
            tx_rd_arr[vif.rid].rdataQ.push_back(vif.rdata);
            tx_rd_arr[vif.rid].rrespQ.push_back(vif.rresp);
            //need to check when read tx is going to complete
            if (vif.rlast == 1) begin
                axi_cfg::mon2cov.put(tx_rd_arr[vif.rid]);
            end
        end
    end
    endtask
endclass

/*#############################################################################################
//        axi_cov.sv
##############################################################################################*/
class axi_cov;
    axi_tx tx;
    covergroup axi_cg;
        AWLEN_CP : coverpoint tx.wlen iff (tx.tx_type == WRITE) {
            bins LOW_LEN = {[0:2]};
            bins MID_LEN = {[3:8]};
            bins HIGH_LEN = {[9:15]};
        }
        AWSIZE_CP : coverpoint tx.wsize iff (tx.tx_type == WRITE) {
            bins LOW_SIZE = {[0:1]};
            bins MID_SIZE = {[2:4]};
            bins HIGH_SIZE = {[5:7]};
        }
        ARLEN_CP : coverpoint tx.rlen iff (tx.tx_type == READ) {
            bins LOW_LEN = {[0:2]};
            bins MID_LEN = {[3:8]};
            bins HIGH_LEN = {[9:15]};
        }
        ARSIZE_CP : coverpoint tx.rsize iff (tx.tx_type == READ) {
            bins LOW_SIZE = {[0:1]};
            bins MID_SIZE = {[2:4]};
            bins HIGH_SIZE = {[5:7]};
        }
    endgroup

    function new();
        axi_cg = new();
    endfunction

    task run();
        $display("axi_cov :: run");
    while (1) begin
        axi_cfg::mon2cov.get(tx);
        $display("################### TX Collected in coverage ###############");
        tx.print();
        axi_cg.sample();
    end
    endtask
endclass


/*#############################################################################################
//        axi_env.sv
##############################################################################################*/
class axi_env;
    axi_bfm bfm = new();
    axi_gen gen = new();
    axi_mon mon = new();
    axi_cov cov = new();

    task run();
        $display("axi_env :: run");
        fork
            bfm.run();
            gen.run();
            mon.run();
            cov.run();
        join
    endtask
endclass
/*#############################################################################################
//        axi_tb.sv
##############################################################################################*/
program axi_tb();
    axi_env env = new();
    initial begin
        wait(axi_cfg::testread_f == 1);
        env.run(); //to start the env run method //Process#2
    end
endprogram
/*#############################################################################################
//        axi_assertion.sv
##############################################################################################*/
module axi_assertion(input aclk, input arstn, input awvalid, input awready);
property write_addr_hsk_p;
    //@(posedge aclk) awvalid |-> ##[0:0] $rose(awready);
    @(posedge aclk) awvalid |-> ##[0:3] awready;
endproperty

assert property (write_addr_hsk_p);

endmodule

/*#############################################################################################
//        axi.svh
##############################################################################################*/
`include "axi_cfg.sv"
`include "axi_slave.sv"
`include "axi_assertion.sv"
`include "axi_tx.sv"
`include "axi_intf.sv"
`include "axi_bfm.sv"
`include "axi_gen.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_env.sv"
`include "axi_tb.sv"
`include "top.sv"
