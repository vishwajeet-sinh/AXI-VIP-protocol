class axi_base_seq extends uvm_sequence#(axi_tx);
    `uvm_object_utils(axi_base_seq)
    `NEW_OBJ
    task pre_body();
        if (starting_phase != null) starting_phase.raise_objection(this);
    endtask
    task post_body();
        if (starting_phase != null) starting_phase.drop_objection(this);
    endtask
endclass

class axi_2_tx_seq extends axi_base_seq;
    `uvm_object_utils(axi_2_tx_seq)
    `NEW_OBJ
    task body();
        repeat(2) `uvm_do_with(req, {req.wr_rd == WRITE;})  //it does all the steps
    endtask
endclass

class axi_10_tx_seq extends axi_base_seq;
    `uvm_object_utils(axi_10_tx_seq)
    `NEW_OBJ
    task body();
        axi_tx txQ[5];
        for (int  i = 0; i < 5; i++) begin
            `uvm_do_with(req, {req.wr_rd == WRITE;})  //it does all the steps
            txQ[i] = new req;
        end
        for (int  i = 0; i < 5; i++) begin
            `uvm_do_with(req, {req.wr_rd == READ; req.read_addr == txQ[i].write_addr; req.read_len == txQ[i].write_len; req.read_size == txQ[i].write_size; req.read_id == txQ[i].write_id;})  //it does all the steps
        end
    endtask
endclass

class axi_fixed_addr_seq extends axi_base_seq;
    `uvm_object_utils(axi_fixed_addr_seq)
    `NEW_OBJ
    task body();
        repeat(10) `uvm_do_with(req, {req.write_addr == 32'h10000_0000; req.read_addr == 32'h10000_0000;})  //it does all the steps
    endtask
endclass