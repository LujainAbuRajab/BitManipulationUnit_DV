// Purpose: UVM sequencer for BMU transactions

`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_sequencer extends uvm_sequencer #(bmu_transaction);

  `uvm_component_utils(dut_sequencer)

  function new(string name = "dut_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : dut_sequencer
