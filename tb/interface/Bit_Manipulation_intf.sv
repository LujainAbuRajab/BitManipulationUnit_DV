`timescale 1ns/1ps

interface Bit_Manipulation_intf (input logic clk);

  // Import DUT types
  import rtl_pkg::*;

  // DUT Inputs
  logic               rst_l;
  logic               scan_mode;

  logic               valid_in;
  rtl_alu_pkt_t       ap;

  logic               csr_ren_in;
  logic        [31:0] csr_rddata_in;

  logic signed [31:0] a_in;
  logic        [31:0] b_in;

  // DUT Outputs
  logic        [31:0] result_ff;
  logic               error;

  // Clocking blocks
  // Driver: drives DUT inputs only
  clocking drv_cb @(posedge clk);
    default input #1ps output #1ps;

    output rst_l;
    output scan_mode;

    output valid_in;
    output ap;

    output csr_ren_in;
    output csr_rddata_in;

    output a_in;
    output b_in;
  endclocking

  // Monitor: observes all DUT signals
  clocking mon_cb @(posedge clk);
    default input #1ps output #1ps;

    input  rst_l;
    input  scan_mode;

    input  valid_in;
    input  ap;

    input  csr_ren_in;
    input  csr_rddata_in;

    input  a_in;
    input  b_in;

    input  result_ff;
    input  error;
  endclocking

  endinterface : Bit_Manipulation_intf

