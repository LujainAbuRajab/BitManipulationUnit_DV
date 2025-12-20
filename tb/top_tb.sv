// Top-level testbench for BMU verification

`timescale 1ns/1ps

module bmu_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rtl_pkg::*; 
  
  // Clock generation
  logic clk;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Interface
  Bit_Manipulation_intf bmu_if (clk);

  // DUT
  Bit_Manipulation_Unit dut (
    .clk            (clk),
    .rst_l          (bmu_if.rst_l),
    .scan_mode      (bmu_if.scan_mode),
    .valid_in       (bmu_if.valid_in),
    .ap             (bmu_if.ap),
    .csr_ren_in     (bmu_if.csr_ren_in),
    .csr_rddata_in  (bmu_if.csr_rddata_in),
    .a_in           (bmu_if.a_in),
    .b_in           (bmu_if.b_in),
    .result_ff      (bmu_if.result_ff),
    .error          (bmu_if.error)
  );

  // Reset
  initial begin
    bmu_if.rst_l          = 0;
    bmu_if.scan_mode     = 0;
    bmu_if.valid_in      = 0;
    bmu_if.ap            = '0;
    bmu_if.csr_ren_in    = 0;
    bmu_if.csr_rddata_in = '0;
    bmu_if.a_in          = '0;
    bmu_if.b_in          = '0;
    #50;
    bmu_if.rst_l = 1;
  end

  // UVM start
  initial begin
    uvm_config_db#(virtual Bit_Manipulation_intf)::set(
      null, "*", "vif", bmu_if
    );
    run_test();
  end

endmodule
