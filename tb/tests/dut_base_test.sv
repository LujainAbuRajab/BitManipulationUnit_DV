//Base UVM test for BMU verification

import uvm_pkg::*;
`include "uvm_macros.svh"

// Import TB package (env, agent, scoreboard, etc.)
import dut_test_package::*;

class dut_base_test extends uvm_test;

  `uvm_component_utils(dut_base_test)

  // Environment
  dut_env m_env;

  // Constructor
  function new(string name = "dut_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    m_env = dut_env::type_id::create("m_env", this);
  endfunction

  // Run phase
  // Run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    `uvm_info("BASE_TEST",
              "Starting dut_base_test run_phase",
              UVM_LOW)

    // Raise objection to keep simulation alive
    phase.raise_objection(this);

    // No stimulus here (yet)
    // Derived tests will start sequences on m_env.m_agent.m_sequencer

    // Simple delay to allow reset / idle observation
    #100ns;

    phase.drop_objection(this);

    `uvm_info("BASE_TEST",
              "Finished dut_base_test run_phase",
              UVM_LOW)
  endtask

endclass : dut_base_test
