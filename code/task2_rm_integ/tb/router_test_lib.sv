class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    function new (string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    router_tb tb;

    function void build_phase(uvm_phase phase);
    //     uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", 
    //     "default_sequence",
    //     yapp_5_packets::get_type());

        //tb = new("tb", this);
        tb = router_tb::type_id::create("tb", this);

        `uvm_info(get_type_name(), "Build phase of test is being executed", UVM_HIGH);
        uvm_config_int::set(this, "*", "recording_detail", 1);
    endfunction: build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    //new added
    task run_phase (uvm_phase phase);
        uvm_objection obj;
        obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask: run_phase

    function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction: check_phase

endclass: base_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                simple_test                          ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class simple_test extends base_test;
    `uvm_component_utils(simple_test)

    function new (string name = "simple_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
    endfunction: build_phase

endclass: simple_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////              test_uvc_integration                   ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class test_uvc_integration extends base_test;
    `uvm_component_utils(test_uvc_integration)

    function new (string name = "test_uvc_integration", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_four::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.hbu.masters[?].sequencer.run_phase", "default_sequence", hbus_small_packet_seq::get_type());
    endfunction: build_phase

endclass: test_uvc_integration

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                multi_channel                        ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class multi_channel extends base_test;
    `uvm_component_utils(multi_channel)

    function new (string name = "multi_channel", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.mcseq.run_phase", "default_sequence", router_mcseqs::get_type());
    endfunction: build_phase

endclass: multi_channel

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                uvm_reset_test                       ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

class uvm_reset_test extends base_test;

    uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
      uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     reset_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     reset_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
          
  endtask

endclass : uvm_reset_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                uvm_mem_walk_test                      ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

class uvm_mem_walk_test extends base_test;

    uvm_mem_walk_seq mem_walk_test;

  `uvm_component_utils(uvm_mem_walk_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      mem_walk_test = uvm_mem_walk_seq::type_id::create("mem_walk_test");
      uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     mem_walk_test.model = tb.yapp_rm;
     mem_walk_test.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
          
  endtask

endclass : uvm_reset_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                Short Packet Test                    ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class short_packet_test extends base_test;
//     `uvm_component_utils(short_packet_test)

//     function new (string name = "short_packet_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//     endfunction: build_phase
// endclass: short_packet_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                Set Config Test                      ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class set_config_test extends base_test;
//     `uvm_component_utils(set_config_test)

//     function new (string name = "set_config_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         uvm_config_int::set(this, "tb.uvc.agent", "is_active", UVM_PASSIVE);
//         super.build_phase(phase);
//     endfunction: build_phase

// endclass: set_config_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                incr_payload_test                    ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class incr_payload_test extends base_test;
//     `uvm_component_utils(incr_payload_test)

//     function new (string name = "incr_payload_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_incr_payload_seq::get_type());
//     endfunction: build_phase

// endclass: incr_payload_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                exhaustive_seq_test                  ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class exhaustive_seq_test extends base_test;
//     `uvm_component_utils(exhaustive_seq_test)

//     function new (string name = "exhaustive_seq_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_exhaustive_seq::get_type());
//     endfunction: build_phase

// endclass: exhaustive_seq_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                task_2_test                          ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class task_2_test extends base_test;
//     `uvm_component_utils(task_2_test)

//     function new (string name = "task_2_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
//     endfunction: build_phase

// endclass: task_2_test