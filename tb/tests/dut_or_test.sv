// File: dut_or_test.sv
// Purpose: UVM test to run basic OR operation sequence

import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_or_test extends dut_base_test;

  `uvm_component_utils(dut_or_test)

  function new(string name="dut_or_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    or_seq seq;

    phase.raise_objection(this);

    seq = or_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    #100ns;
    phase.drop_objection(this);
  endtask

endclass
