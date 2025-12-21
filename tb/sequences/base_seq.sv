`timescale 1ns/1ps

`ifndef BASE_SEQ_SV
`define BASE_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "base_seq_item.sv"

// Base Sequence for BMU

class base_seq extends uvm_sequence #(base_seq_item);

  // Factory registration
  `uvm_object_utils(base_seq)

  // Constructor
  function new(string name = "base_seq");
    super.new(name);
  endfunction


  virtual task pre_randomize_hook();
  endtask

  virtual task post_randomize_hook(base_seq_item req);
  endtask

  // --------------------------------------------------------
  // BODY(): standard UVM sequence logic
  // --------------------------------------------------------
  virtual task body();
    base_seq_item req;

    // Create item
    req = base_seq_item::type_id::create("req");

    // Allow derived sequences to override behavior before randomization
    pre_randomize_hook();

    // Randomize seq_item
    if (!req.randomize()) begin
      `uvm_error("RANDFAIL", "bmu_base_seq: Failed to randomize sequence item")
      return;
    end

    // Callback for derived sequences to compute expected values, etc.
    post_randomize_hook(req);

    // Send item to sequencer/driver
    start_item(req);
    finish_item(req);

    `uvm_info("BASE_SEQ", "One BMU transaction executed", UVM_LOW)
  endtask

endclass : base_seq

`endif // BASE_SEQ_SV
