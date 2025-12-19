// File: tb/interface/Bit_Manipulation_intf.sv
// Purpose: DUT <-> TB interface for BMU verification (black-box DV)

interface Bit_Manipulation_intf (input logic clk);

  // Import DUT types (ap is a packed struct: rtl_alu_pkt_t)
  import rtl_pkg::*;


  // DUT Inputs
  logic              rst_l;
  logic              scan_mode;

  logic              valid_in;
  rtl_alu_pkt_t      ap;

  logic              csr_ren_in;
  logic       [31:0] csr_rddata_in;

  logic signed [31:0] a_in;
  logic        [31:0] b_in;

  // DUT Outputs
  logic       [31:0] result_ff;
  logic              error;

  // Clocking blocks
  // Driver drives inputs on posedge (adjust skew if needed by simulator/DUT timing)
  clocking drv_cb @(posedge clk);
    default input #1step output #1step;

    output rst_l;
    output scan_mode;

    output valid_in;
    output ap;

    output csr_ren_in;
    output csr_rddata_in;

    output a_in;
    output b_in;

    input  result_ff;
    input  error;
  endclocking

  // Monitor samples everything on posedge
  clocking mon_cb @(posedge clk);
    default input #1step output #1step;

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

  // Modports
  modport DRIVER  (clocking drv_cb, input clk);
  modport MONITOR (clocking mon_cb, input clk);

endinterface : Bit_Manipulation_intf
