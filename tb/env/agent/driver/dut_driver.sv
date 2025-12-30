//drives only DUT inputs

`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class dut_driver extends uvm_driver #(bmu_transaction);

  `uvm_component_utils(dut_driver)

  // Virtual interface handle
  virtual Bit_Manipulation_intf vif;

  function new(string name = "dut_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual Bit_Manipulation_intf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV_NO_VIF", "Virtual interface not set for dut_driver")
    end
  endfunction

  task run_phase(uvm_phase phase);
    bmu_transaction tr;

    drive_idle();

    forever begin
      seq_item_port.get_next_item(tr);

      `uvm_info("DRV", $sformatf("Driving transaction: %s", tr.convert2string()), UVM_MEDIUM)

      drive_transaction(tr);

      seq_item_port.item_done();
    end
  endtask

  task drive_transaction(bmu_transaction tr);

    // Drive on next clock edge via driver clocking block
    @(vif.drv_cb);

    vif.drv_cb.valid_in       <= tr.valid_in;
    vif.drv_cb.ap             <= tr.ap;
    vif.drv_cb.csr_ren_in     <= tr.csr_ren_in;
    vif.drv_cb.csr_rddata_in  <= tr.csr_rddata_in;
    vif.drv_cb.a_in           <= tr.a_in;
    vif.drv_cb.b_in           <= tr.b_in;

    // Hold values for one cycle
    @(vif.drv_cb);

    // Deassert valid by default
    vif.drv_cb.valid_in <= 1'b0;

  endtask

  task drive_idle();
    @(vif.drv_cb);

    vif.drv_cb.valid_in       <= 1'b0;
    vif.drv_cb.ap             <= '0;
    vif.drv_cb.csr_ren_in     <= 1'b0;
    vif.drv_cb.csr_rddata_in  <= '0;
    vif.drv_cb.a_in           <= '0;
    vif.drv_cb.b_in           <= '0;
  endtask

endclass : dut_driver
