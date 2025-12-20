import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_env extends uvm_env;

  `uvm_component_utils(dut_env)

  dut_agent       m_agent;
  dut_scoreboard  m_scoreboard;

  function new(string name = "dut_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_agent      = dut_agent     ::type_id::create("m_agent", this);
    m_scoreboard = dut_scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.ap.connect(m_scoreboard.analysis_export);
  endfunction

endclass : dut_env
