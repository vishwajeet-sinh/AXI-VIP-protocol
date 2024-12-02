class axi_base_test extends uvm_test;
    axi_agent agent;
    uvm_table_printer printer;
    `uvm_component_utils(axi_base_test)
    `NEW
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = axi_agent::type_id::create("agent", this);
        printer = new();
    endfunction
endclass

class axi_2_tx_test extends axi_base_test;
    `uvm_component_utils(axi_2_tx_test)
    `NEW
    function void build_phase(uvm_phase phase);
        //uvm_config_db#(uvm_object_wrapper)::set(this, "agent.sqr.run_phase", "default_sequence", axi_2_tx_seq::get_type());
        super.build_phase(phase);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $psprintf("AXI VIP hierarchy is %s", this.sprint(printer)), UVM_NONE);
    endfunction


    task run_phase(uvm_phase phase);
        axi_2_tx_seq seq;
        seq = axi_2_tx_seq::type_id::create("seq");
        assert(seq.randomize());
        phase.raise_objection(this);
        seq.start(agent.sqr);
        phase.drop_objection(this);
    endtask
endclass

class axi_10_tx_test extends axi_base_test;
    `uvm_component_utils(axi_10_tx_test)
    `NEW
    function void build_phase(uvm_phase phase);
        //uvm_config_db#(uvm_object_wrapper)::set(this, "agent.sqr.run_phase", "default_sequence", axi_10_tx_seq::get_type());
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        axi_10_tx_seq tx_seq;
        tx_seq = axi_10_tx_seq::type_id::create("tx_seq");
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 150);
        tx_seq.start(agent.sqr);
        phase.drop_objection(this);
    endtask
endclass

class axi_fixed_addr_test extends axi_base_test;
    `uvm_component_utils(axi_fixed_addr_test)
    `NEW
    function void build_phase(uvm_phase phase);
        uvm_config_db#(uvm_object_wrapper)::set(this, "agent.sqr.run_phase", "default_sequence", axi_fixed_addr_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass