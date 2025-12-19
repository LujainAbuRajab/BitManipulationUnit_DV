// Purpose: BMU UVM agent
// Note: Active agent (driver + sequencer + monitor)

`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb/env/agent/driver/dut_driver.sv"
`include "tb/env/agent/sequencer/dut_sequencer.sv"
`include "tb/env/agent/monitor/dut_monitor.sv"

class dut_agent extends uvm_agent;

  `uvm_component_utils(dut_agent)

  // Components
  dut_driver     m_driver;
  dut_sequencer  m_sequencer;
  dut_monitor    m_monitor;

  // Constructor
  function new(string name = "dut_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create monitor always
    m_monitor = dut_monitor::type_id::create("m_monitor", this);

    // Create driver & sequencer only if agent is active
    if (is_active == UVM_ACTIVE) begin
      m_driver    = dut_driver::type_id::create("m_driver", this);
      m_sequencer = dut_sequencer::type_id::create("m_sequencer", this);
    end
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      // Connect driver to sequencer
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction

endclass : dut_agent
