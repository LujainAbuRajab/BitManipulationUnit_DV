package dut_test_package;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import rtl_pkg::*;

  `include "../env/agent/sequencer/transaction.sv"
  `include "../env/agent/sequencer/dut_sequencer.sv"
  `include "../env/agent/driver/dut_driver.sv"
  `include "../env/agent/monitor/dut_monitor.sv"
  `include "../env/scoreboard/dut_scoreboard.sv"
  `include "../env/agent/dut_agent.sv"
  `include "../env/dut_env.sv"
  `include "../tests/dut_base_test.sv"

endpackage : dut_test_package
