module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import yapp_pkg::*;

    import hbus_pkg::*;
    import clock_and_reset_pkg::*;
    import channel_pkg::*;
    import yapp_router_reg_pkg::*;
    
    import router_module::*;
    // `include "router_scoreboard.sv"
    `include "router_mcsequencer.sv"
    `include "router_mcseqs_lib.sv"
    `include "router_tb.sv"
    `include "router_test_lib.sv"
    
    initial begin
        yapp_vif_config::set(null,"uvm_test_top.tb.uvc.agent.*", "vif", hw_top.in0);

        channel_vif_config::set(null,"uvm_test_top.tb.c0.rx_agent.*", "vif", hw_top.c0);
        channel_vif_config::set(null,"uvm_test_top.tb.c1.rx_agent.*", "vif", hw_top.c1);
        channel_vif_config::set(null,"uvm_test_top.tb.c2.rx_agent.*", "vif", hw_top.c2);

        hbus_vif_config::set(null,"uvm_test_top.tb.hbu.*", "vif", hw_top.hbu);

        clock_and_reset_vif_config::set(null,"uvm_test_top.tb.clk_rst.agent.*", "vif", hw_top.clk_rst);

        run_test();
        //running test from file.f using +UVM_TESTNAME
    end

endmodule