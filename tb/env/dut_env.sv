// Purpose: BMU UVM environment (agent + scoreboard)

`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

// Import TB package (contains agent, scoreboard, etc.)
import dut_test_package::*;

class dut_env extends uvm_env;

  `uvm_component_utils(dut_env)

  // Components
  dut_agent       m_agent;
  dut_scoreboard  m_scoreboard;

  // Constructor
  function new(string name = "dut_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent (active by default)
    m_agent = dut_agent::type_id::create("m_agent", this);
    m_agent.is_active = UVM_ACTIVE;

    // Create scoreboard
    m_scoreboard = dut_scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor analysis ports to scoreboard
    m_agent.m_monitor.input_ap.connect(m_scoreboard.in_imp);
    m_agent.m_monitor.output_ap.connect(m_scoreboard.out_imp);
  endfunction

endclass : dut_env
