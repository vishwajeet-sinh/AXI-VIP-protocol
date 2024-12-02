class axi_tx extends uvm_sequence_item;
    rand wr_rd_e wr_rd; //READ/WRITE/WRITE_READ
    //write addr
    rand bit [`ID_WIDTH-1 : 0] write_id;
    rand bit [`ADDR_WIDTH-1 : 0] write_addr;
         bit [`ADDR_WIDTH-1 : 0] write_addr_t;
    rand bit [3:0] write_len;
    rand bit [2:0] write_size;
    rand bit [1:0] write_type;
    rand bit [1:0] write_lock;
    rand bit [1:0] write_prot;
    rand bit [1:0] write_cache;
    //write data
    rand bit [`DATA_WIDTH-1 : 0] write_dataQ[$];
    rand bit [`STRB_WIDTH-1 : 0] write_strbQ[$];
    //write resp
    rand bit [1:0] write_resp;
    //read addr
    rand bit [`ID_WIDTH-1 : 0] read_id;
    rand bit [`ADDR_WIDTH-1 : 0] read_addr;
         bit [`ADDR_WIDTH-1 : 0] read_addr_t;
    rand bit [3:0] read_len;
    rand bit [2:0] read_size;
    rand bit [1:0] read_type;
    rand bit [1:0] read_lock;
    rand bit [1:0] read_prot;
    rand bit [1:0] read_cache;
    //read data
    rand bit [`DATA_WIDTH-1 : 0] read_dataQ[$];
    rand bit [3:0] read_respQ[$];
    int wr_txsize;
    bit [31:0] wr_lower_wrap_addr;
    bit [31:0] wr_upper_wrap_addr;
    int rd_txsize;
    bit [31:0] rd_lower_wrap_addr;
    bit [31:0] rd_upper_wrap_addr;
    `uvm_object_utils_begin(axi_tx)  //registering axi_tx to the factory , when properties are registered to factory, methods like print, copy, compare, pack, unpack automatically gets updated
        `uvm_field_enum( wr_rd_e, wr_rd, UVM_ALL_ON)  //registering axi_tx properties to the factory
        //write addr
        `uvm_field_int( write_id, UVM_ALL_ON)
        `uvm_field_int( write_addr, UVM_ALL_ON)
        `uvm_field_int( write_len, UVM_ALL_ON)
        `uvm_field_int( write_size, UVM_ALL_ON)
        `uvm_field_int( write_type, UVM_ALL_ON)
        `uvm_field_int( write_lock, UVM_ALL_ON)
        `uvm_field_int( write_prot, UVM_ALL_ON)
        `uvm_field_int( write_cache, UVM_ALL_ON)
        //write data
        `uvm_field_queue_int( write_dataQ, UVM_ALL_ON)
        `uvm_field_queue_int( write_strbQ, UVM_ALL_ON)
        //write resp
        `uvm_field_int( write_resp, UVM_ALL_ON)
        //read addr
        `uvm_field_int( read_id, UVM_ALL_ON)
        `uvm_field_int( read_addr, UVM_ALL_ON)
        `uvm_field_int( read_len, UVM_ALL_ON)
        `uvm_field_int( read_size, UVM_ALL_ON)
        `uvm_field_int( read_type, UVM_ALL_ON)
        `uvm_field_int( read_lock, UVM_ALL_ON)
        `uvm_field_int( read_prot, UVM_ALL_ON)
        `uvm_field_int( read_cache, UVM_ALL_ON)
        //read data
        `uvm_field_queue_int( read_dataQ, UVM_ALL_ON)
        `uvm_field_queue_int( read_respQ, UVM_ALL_ON)
    `uvm_object_utils_end
    `NEW_OBJ

    /*
    //methods
    function void print();
        $display("Printing Axi_tx");
        if (wr_rd == WRITE) begin
            $display("write_addr = %h", write_addr);
            $display("write_id = %h", write_id);
            $display("write_len = %h", write_len);
            $display("write_size = %h", write_size);
            $display("write_type = %h", write_type);
            $display("write_lock = %h", write_lock);
            $display("write_prot = %h", write_prot);
            $display("write_cache = %h", write_cache);
            $display("write_dataQ = %p", write_dataQ);
            $display("write_strbQ = %p", write_strbQ);
        end
        if (wr_rd == READ) begin
            $display("read_addr = %h", read_addr);
            $display("read_id = %h", read_id);
            $display("read_len = %h", read_len);
            $display("read_size = %h", read_size);
            $display("read_type = %h", read_type);
            $display("read_lock = %h", read_lock);
            $display("read_prot = %h", read_prot);
            $display("read_cache = %h", read_cache);
            $display("read_dataQ = %p", read_dataQ);
            $display("read_respQ = %p", read_respQ);
        end
        if (wr_rd == WRITE_READ) begin
            $display("write_addr = %h", write_addr);
            $display("write_id = %h", write_id);
            $display("write_len = %h", write_len);
            $display("write_size = %h", write_size);
            $display("write_type = %h", write_type);
            $display("write_lock = %h", write_lock);
            $display("write_prot = %h", write_prot);
            $display("write_cache = %h", write_cache);
            $display("write_dataQ = %p", write_dataQ);
            $display("write_strbQ = %p", write_strbQ);
            $display("read_addr = %h", read_addr);
            $display("read_id = %h", read_id);
            $display("read_len = %h", read_len);
            $display("read_size = %h", read_size);
            $display("read_type = %h", read_type);
            $display("read_lock = %h", read_lock);
            $display("read_prot = %h", read_prot);
            $display("read_cache = %h", read_cache);
            $display("read_dataQ = %p", read_dataQ);
            $display("read_respQ = %p", read_respQ);
        end
        $display("#########################");
    endfunction

    */
    //Constraints
    constraint burst_c {
        write_type != 2'b11;  //INCR, FIXED, WRAP, RSVD(2'b11)
        read_type != 2'b11;
    }
    constraint lock_c {
        write_lock != 2'b11;
        read_lock != 2'b11;
    }
    constraint dataQ_c {
        write_dataQ.size() == write_len + 1;
        write_strbQ.size() == write_len + 1;
        read_dataQ.size() == read_len + 1;
        read_respQ.size() == read_len + 1;
    }
    constraint wstrb_c {
        foreach (write_strbQ[i]) {
            (write_size == 0) -> write_strbQ[i] inside {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            (write_size == 1) -> write_strbQ[i] inside {4'b0011, 4'b1100};
            (write_size == 2) -> write_strbQ[i] inside {4'b1111};
        }
    }
    constraint wsize_c {
        //write_size <= 2;
        write_size == 2;
    }

function void post_randomize();
    write_addr_t = write_addr;
    read_addr_t = read_addr;
    calc_wrap_boundaries();
endfunction

//methods
//wrap boundaries : Used during Wrap bursts
function void calc_wrap_boundaries();
    //Write
    //txsize = num_transfers * bytes_per_beat;
    wr_txsize = (write_len+1) * (2**write_size); //wrap boundaries will be 0, 1*txsize, 2*txsize..
    wr_lower_wrap_addr = write_addr - (write_addr%wr_txsize);
    wr_upper_wrap_addr = wr_lower_wrap_addr + wr_txsize - 1;
    //Read
    //txsize = num_transfers * bytes_per_beat;
    rd_txsize = (read_len+1) * (2**read_size); //wrap boundaries will be 0, 1*txsize, 2*txsize..
    rd_lower_wrap_addr = read_addr - (read_addr%rd_txsize);
    rd_upper_wrap_addr = rd_lower_wrap_addr + rd_txsize - 1;
endfunction

function void wrap_read_addr();
    if (read_addr > rd_upper_wrap_addr) read_addr = rd_lower_wrap_addr;
endfunction

function void wrap_write_addr();
    if (write_addr > wr_upper_wrap_addr) write_addr = wr_lower_wrap_addr;
endfunction
endclass