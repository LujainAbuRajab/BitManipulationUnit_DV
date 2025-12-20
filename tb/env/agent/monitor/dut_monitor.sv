`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_monitor extends uvm_monitor;

  `uvm_component_utils(dut_monitor)

  // Virtual interface
  virtual Bit_Manipulation_intf vif;

  // Analysis ports
  uvm_analysis_port #(bmu_transaction) input_ap;
  uvm_analysis_port #(bmu_transaction) output_ap;


  // Constructor
  function new(string name = "dut_monitor", uvm_component parent = null);
    super.new(name, parent);
    input_ap  = new("input_ap",  this);
    output_ap = new("output_ap", this);
  endfunction


  // Build phase: get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual Bit_Manipulation_intf)::get(
          this, "", "vif", vif)) begin
      `uvm_fatal("MON_NO_VIF", "Virtual interface not set for dut_monitor")
    end
  endfunction


  // Run phase
  task run_phase(uvm_phase phase);
    fork
      monitor_inputs();
      monitor_outputs();
    join
  endtask

  // Monitor input transactions (valid_in based)
  task monitor_inputs();
    bmu_transaction tr;

    forever begin
      @(vif.mon_cb);

      if (vif.mon_cb.valid_in) begin
        tr = bmu_transaction::type_id::create("input_tr");

        tr.valid_in      = vif.mon_cb.valid_in;
        tr.ap            = vif.mon_cb.ap;
        tr.csr_ren_in    = vif.mon_cb.csr_ren_in;
        tr.csr_rddata_in = vif.mon_cb.csr_rddata_in;
        tr.a_in          = vif.mon_cb.a_in;
        tr.b_in          = vif.mon_cb.b_in;

        `uvm_info("MON_IN",
          $sformatf("Captured INPUT transaction: %s", tr.convert2string()),
          UVM_MEDIUM)

        input_ap.write(tr);
      end
    end
  endtask

  // Monitor output events (result / error)
task monitor_outputs();
  bmu_transaction tr;

  forever begin
    @(vif.mon_cb);

    // Capture any observable output event
    if (vif.mon_cb.result_ff !== 'x || vif.mon_cb.error !== 1'bx) begin
      tr = bmu_transaction::type_id::create("output_tr");

      // Fill observed DUT outputs
      tr.dut_result = vif.mon_cb.result_ff;
      tr.dut_error  = vif.mon_cb.error;

      `uvm_info("MON_OUT",
        $sformatf("Captured OUTPUT event: result=0x%08h error=%0b",
                  vif.mon_cb.result_ff, vif.mon_cb.error),
        UVM_MEDIUM)

      output_ap.write(tr);
    end
  end
endtask


endclass : dut_monitor
