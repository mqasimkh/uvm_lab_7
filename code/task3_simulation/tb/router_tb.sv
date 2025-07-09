class router_tb extends uvm_env;

    //register model
    yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5 yapp_rm;
    hbus_reg_adapter reg2hbus;

    `uvm_component_utils_begin(router_tb)
        `uvm_field_object(yapp_rm, UVM_ALL_ON)
    `uvm_component_utils_end
    
    //yapp uvc
    yapp_tx_env uvc;

    //channel uvc
    channel_env c0;
    channel_env c1;
    channel_env c2;

    //hbu uvc
    hbus_env hbu;

    //clock and reset uvc
    clock_and_reset_env clk_rst;

    //multi channel sequencer
    router_mcsequencer mcseq;

    //scoreboard
    //router_scoreboard scoreboard;

    //router_env
    router_module_env router_mod;
   
    function new (string name = "router_tb", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("UVM_ENV", "Build phase of env is being executed", UVM_HIGH);

        uvc = yapp_tx_env::type_id::create("uvc", this);

        //setting channel id of each channel before they are created.
        uvm_config_int::set(this, "c0", "channel_id", 0);
        uvm_config_int::set(this, "c1", "channel_id", 1);
        uvm_config_int::set(this, "c2", "channel_id", 2);

        //creating channel using factory method.
        c0 = channel_env::type_id::create("c0", this);
        c1 = channel_env::type_id::create("c1", this);
        c2 = channel_env::type_id::create("c2", this);

        //setting master and slave nums for hbu uvc
        uvm_config_int::set(this, "hbu", "num_masters", 1);
        uvm_config_int::set(this, "hbu", "num_slaves", 0);

        //creating multi channel sequencer using factory method.
        mcseq = router_mcsequencer::type_id::create("mcseq", this);

        //creating hbu using factory method.
        hbu = hbus_env::type_id::create("hbu", this);

        //creating clock and reset uvc using factory method.
        clk_rst = clock_and_reset_env::type_id::create("clk_rst", this);

        //creating scoreboard using factory method
        //scoreboard = router_scoreboard::type_id::create("scoreboard", this);

        //creating router module using factory method
        router_mod = router_module_env::type_id::create("router_mod", this);

        //building reg mode
        yapp_rm = yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5::type_id::create("yapp_rm", this);
        yapp_rm.build();
        yapp_rm.lock_model();

        reg2hbus = hbus_reg_adapter::type_id::create("reg2hbus", this);
        //address map
        yapp_rm.default_map.set_auto_predict(1);
        
        //setting pathname for backdoor access to DUT
        yapp_rm.set_hdl_path_root("hw_top.dut");
        
    endfunction: build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    function void connect_phase(uvm_phase phase);
        mcseq.hbus = hbu.masters[0].sequencer;
        mcseq.yapps = uvc.agent.sequencer;

        //uvc.agent.monitor.yapp_collected_port.connect(scoreboard.yapp_in);
        
        c0.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan0);
        c1.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan1);
        c2.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan2);
        
        uvc.agent.monitor.yapp_collected_port.connect(router_mod.ref_model_yapp);
        hbu.bus_monitor.item_collected_port.connect(router_mod.ref_model_hbus);

        yapp_rm.default_map.set_sequencer(hbu.masters[0].sequencer, reg2hbus);
        
    endfunction: connect_phase

endclass: router_tb