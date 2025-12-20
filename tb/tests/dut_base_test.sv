// Base UVM test for BMU verification

import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_base_test extends uvm_test;

  `uvm_component_utils(dut_base_test)

  dut_env m_env;

  function new(string name="dut_base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = dut_env::type_id::create("m_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100ns;
    phase.drop_objection(this);
  endtask

endclass
