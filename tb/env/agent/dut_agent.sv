import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_agent extends uvm_agent;

  `uvm_component_utils(dut_agent)

  dut_driver     m_driver;
  dut_sequencer  m_sequencer;
  dut_monitor    m_monitor;

  function new(string name = "dut_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_driver    = dut_driver   ::type_id::create("m_driver", this);
    m_sequencer = dut_sequencer::type_id::create("m_sequencer", this);
    m_monitor   = dut_monitor  ::type_id::create("m_monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction

endclass : dut_agent
