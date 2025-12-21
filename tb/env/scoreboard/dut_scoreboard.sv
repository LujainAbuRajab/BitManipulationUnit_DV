// FIFO match, no fixed latency assumption

`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

class dut_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(dut_scoreboard)

  // Receive input/output events from monitor
  uvm_analysis_imp #(bmu_transaction, dut_scoreboard) in_imp;
  uvm_analysis_imp #(bmu_transaction, dut_scoreboard) out_imp;

  // FIFO queues for match-by-order
  bmu_transaction in_q[$];
  bmu_transaction out_q[$];

  // Statistics
  int unsigned num_in;
  int unsigned num_out;
  int unsigned num_checked;
  int unsigned num_mismatches;

  function new(string name="dut_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    in_imp  = new("in_imp",  this);
    out_imp = new("out_imp", this);
  endfunction

  // -------------------------------------------------
  // UVM analysis write methods
  // NOTE: Xcelium uses write() naming for analysis_imp.
  // We differentiate via the "imp" instance names by overloading:
  // - write() for in_imp calls write_in()
  // - write() for out_imp calls write_out()
  // -------------------------------------------------

  // Xcelium/IEEE: analysis_imp calls write(T t)
  function void write(bmu_transaction t);
    // This default should never be used because we bind to two imps.
    `uvm_warning("SCB_WRITE", "Default write() called; expected write_in/write_out dispatch.")
  endfunction

  // Dedicated input path
  function void write_in(bmu_transaction t);
    bmu_transaction c;
    c = bmu_transaction::type_id::create("in_copy");
    c.copy(t);
    in_q.push_back(c);
    num_in++;
    try_check();
  endfunction

  // Dedicated output path
  function void write_out(bmu_transaction t);
    bmu_transaction c;
    c = bmu_transaction::type_id::create("out_copy");
    c.copy(t);
    out_q.push_back(c);
    num_out++;
    try_check();
  endfunction

  // Hook up the imps to the right methods
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Bind analysis_imp callbacks explicitly
    // in_imp.set_imp(this, "write_in");         // [Naser.t] : you connect the analysis port in the enviroment , no need for this 
    // out_imp.set_imp(this, "write_out");
  endfunction

  // Checking (FIFO match; no latency assumption)
  function void try_check();
    bmu_transaction in_t;
    bmu_transaction out_t;
    logic [31:0] exp_result;
    logic        exp_error;

    // Match in order: 1 input corresponds to 1 output
    while ((in_q.size() > 0) && (out_q.size() > 0)) begin
      in_t  = in_q.pop_front();
      out_t = out_q.pop_front();

      // Predict expected outputs from the VP subset only
      compute_expected(in_t, exp_result, exp_error);

      num_checked++;

      // Compare error first
      if (out_t.dut_error !== exp_error) begin
        num_mismatches++;
        `uvm_error("SCB_ERR_MISMATCH",
          $sformatf("Error mismatch. exp=%0b got=%0b | in=%s",
                    exp_error, out_t.dut_error, in_t.convert2string()))
      end

      // Compare result only when not error (per DUT coding style)
      if (!exp_error) begin
        if (out_t.dut_result !== exp_result) begin
          num_mismatches++;
          `uvm_error("SCB_RES_MISMATCH",
            $sformatf("Result mismatch. exp=0x%08h got=0x%08h | in=%s",
                      exp_result, out_t.dut_result, in_t.convert2string()))
        end
      end
    end
  endfunction

  // Expected model (black-box spec model for VP ops)
  function void compute_expected(bmu_transaction t,
    output logic [31:0] exp_result,
    output logic        exp_error);
    logic [31:0] a_u, b_u;
    logic signed [31:0] a_s, b_s;
    logic [4:0] shamt;

    a_s = t.a_in;
    b_s = $signed(t.b_in);
    a_u = t.a_in;
    b_u = t.b_in;
    shamt = t.b_in[4:0];

    // Default
    exp_result = '0;
    exp_error  = 1'b0;

    // -------- Guard / error conditions from VP --------
    // CSR conflict: csr_ren_in asserted while any op enabled
    if (t.csr_ren_in && (t.ap != '0)) begin
      exp_error = 1'b1;
      return;
    end

    // ZBA requirement for SH2ADD
    if (t.ap.sh2add && (t.ap.zba != 1'b1)) begin
      exp_error = 1'b1;
      return;
    end

    // You can extend invalid combinations here later (multi-enables, etc.)
    // Note: current transaction constraint enforces onehot, but error sequences will relax it.

    //Functional expectations (VP ops only)
    // Logical ops: OR/ORN/XOR/XNOR via lor/lxor with zbb meaning inverted operand mode
    if (t.ap.lor && !t.ap.zbb) begin
      exp_result = a_u | b_u;                 // OR
    end
    else if (t.ap.lor && t.ap.zbb) begin
      exp_result = a_u | (~b_u);              // ORN
    end
    else if (t.ap.lxor && !t.ap.zbb) begin
      exp_result = a_u ^ b_u;                 // XOR
    end
    else if (t.ap.lxor && t.ap.zbb) begin
      exp_result = a_u ^ (~b_u);              // XNOR (per DUT behavior)
    end

    // Shifts / rotates
    else if (t.ap.srl) begin
      exp_result = a_u >> shamt;
    end
    else if (t.ap.sra) begin
      exp_result = a_s >>> shamt;
    end
    else if (t.ap.ror) begin
      exp_result = (a_u >> shamt) | (a_u << (32 - shamt));
    end
    else if (t.ap.binv) begin
      exp_result = a_u ^ (32'h1 << shamt);
    end
    else if (t.ap.sh2add) begin
      exp_result = (a_u << 2) + b_u;
    end

    // Arithmetic
    else if (t.ap.sub) begin
      exp_result = a_u - b_u;
    end

    // SLT/SLTU (single control bit slt + mode unsign)
    else if (t.ap.slt) begin
      if (t.ap.unsign) exp_result = (a_u < b_u) ? 32'd1 : 32'd0; // SLTU
      else             exp_result = (a_s < b_s) ? 32'd1 : 32'd0; // SLT
    end

    // CTZ
    else if (t.ap.ctz) begin
      exp_result = ctz32(a_u);
    end

    // CPOP (population count)
    else if (t.ap.cpop) begin
      exp_result = popcount32(a_u);
    end

    // SEXT.B (siext_b)
    else if (t.ap.siext_b) begin
      exp_result = {{24{a_u[7]}}, a_u[7:0]};
    end

    // MAX (signed compare per VP default)
    else if (t.ap.max) begin
      exp_result = (a_s >= b_s) ? a_u : b_u;
    end

    // PACK
    else if (t.ap.pack) begin
      exp_result = {a_u[15:0], b_u[15:0]};
    end

    // GREV (your VP constrains to byte reverse mode b[4:0]=11000; RTL uses grev bit)
    else if (t.ap.grev) begin
      // For VP scope we treat GREV as byte swap when shamt==24 (0x18)
      if (t.b_in[4:0] == 5'b11000) exp_result = {a_u[15:8],a_u[7:0],a_u[31:24],a_u[23:16]};
      else exp_error = 1'b1; // out of VP mode -> flag as invalid for this plan
    end

    else begin
      // Unsupported in VP scope
      exp_error = 1'b1;
    end

  endfunction

  // Helpers
  function automatic logic [31:0] popcount32(input logic [31:0] x);
    int i;
    popcount32 = 32'd0;
    for (i = 0; i < 32; i++) popcount32 += x[i];
  endfunction

  function automatic logic [31:0] ctz32(input logic [31:0] x);
    int i;
    begin
      if (x == 32'd0) return 32'd32;
      ctz32 = 32'd0;
      for (i = 0; i < 32; i++) begin
        if (x[i]) return ctz32;
        ctz32++;
      end
    end
  endfunction

  // Report
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCB_SUMMARY",
      $sformatf("Inputs=%0d Outputs=%0d Checked=%0d Mismatches=%0d InQ=%0d OutQ=%0d",
                num_in, num_out, num_checked, num_mismatches, in_q.size(), out_q.size()),
      UVM_LOW)
  endfunction

endclass : dut_scoreboard
