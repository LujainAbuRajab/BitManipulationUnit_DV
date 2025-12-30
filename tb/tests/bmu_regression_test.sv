`timescale 1ns/1ps
`ifndef BMU_REGRESSION_TEST_SV
`define BMU_REGRESSION_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

<<<<<<< HEAD
// `include "dut_env.sv"
// `include "bmu_regression_seq.sv"

=======
>>>>>>> fix-timing-work
// BMU Regression Test: to test all BMU functionalities at once
class bmu_regression_test extends uvm_test;

  `uvm_component_utils(bmu_regression_test)

  dut_env             m_env;
  bmu_regression_seq  m_seq;

  function new(string name="bmu_regression_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = dut_env::type_id::create("m_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    m_seq = bmu_regression_seq::type_id::create("m_seq");
    m_seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask

endclass
`endif
