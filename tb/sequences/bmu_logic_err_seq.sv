`timescale 1ns/1ps

`ifndef BMU_LOGIC_ERR_SEQ_SV
`define BMU_LOGIC_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

// BMU Logic Error / Guard Sequence
// Generates illegal / overlap / CSR conflict cases intentionally
class bmu_logic_err_seq extends bmu_base_seq;

  `uvm_object_utils(bmu_logic_err_seq)

  function new(string name="bmu_logic_err_seq");
    super.new(name);
  endfunction

  // Helper to reduce repetition
  task automatic send_err_case(
    string name,
    bit csr_conflict,
    rtl_alu_pkt_t ap_cfg
  );
    bmu_transaction tr;

    tr = bmu_transaction::type_id::create(name);

    start_item(tr);

    // Randomize only the fields that are safe to randomize here.
    // NOTE: We intentionally override tr.ap later (illegal overlaps).
    if (csr_conflict) begin
      if (!tr.randomize() with { valid_in == 1'b1; csr_ren_in == 1'b1; }) begin
        `uvm_error("RANDFAIL", $sformatf("%s: randomize failed (csr_conflict=1)", name))
        finish_item(tr);
        return;
      end
    end
    else begin
      if (!tr.randomize() with { valid_in == 1'b1; csr_ren_in == 1'b0; }) begin
        `uvm_error("RANDFAIL", $sformatf("%s: randomize failed (csr_conflict=0)", name))
        finish_item(tr);
        return;
      end
    end

    // Force the illegal ap pattern AFTER randomize (bypasses onehot constraint)
    tr.ap = ap_cfg;

    // Optional: keep deterministic values for other inputs
    tr.csr_rddata_in = '0;

    finish_item(tr);

    `uvm_info("BMU_LOGIC_ERR_SEQ",
              $sformatf("Sent error case '%s' csr_conflict=%0b ap=0x%0h",
                        name, csr_conflict, ap_cfg),
              UVM_LOW)
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_LOGIC_ERR_SEQ", "Starting Logic Error Sequence", UVM_LOW)

    // Case 0: OR + XOR overlap
    ap = '0;
    ap.lor  = 1'b1;
    ap.lxor = 1'b1;
    ap.zbb  = 1'b0;
    send_err_case("err_or_and_xor_overlap", 1'b0, ap);

    // Case 1: OR + SH2ADD overlap
    ap = '0;
    ap.lor    = 1'b1;
    ap.sh2add = 1'b1;
    send_err_case("err_or_and_sh2add_overlap", 1'b0, ap);

    // Case 1b: OR + SUB overlap
    ap = '0;
    ap.lor = 1'b1;
    ap.sub = 1'b1;
    send_err_case("err_or_and_sub_overlap", 1'b0, ap);

    // Case 1c: XOR + SH2ADD overlap
    ap = '0;
    ap.lxor   = 1'b1;
    ap.sh2add = 1'b1;
    send_err_case("err_xor_and_sh2add_overlap", 1'b0, ap);

    // Case 2: XOR + SUB overlap
    ap = '0;
    ap.lxor = 1'b1;
    ap.sub  = 1'b1;
    send_err_case("err_xor_and_sub_overlap", 1'b0, ap);

    // Case 3: XOR + SRL overlap (Logic + Shift)
    ap = '0;
    ap.lxor = 1'b1;
    ap.srl  = 1'b1;
    send_err_case("err_xor_and_srl_overlap", 1'b0, ap);

    // Case 4: XOR + CTZ overlap (Logic + Bitcount)
    ap = '0;
    ap.lxor = 1'b1;
    ap.ctz  = 1'b1;
    send_err_case("err_xor_and_ctz_overlap", 1'b0, ap);

    // Case 5: CSR conflict with OR (csr_ren_in=1)
    ap = '0;
    ap.lor = 1'b1;
    send_err_case("err_csr_conflict_or", 1'b1, ap);

    // Case 6: CSR conflict with XOR (csr_ren_in=1)
    ap = '0;
    ap.lxor = 1'b1;
    send_err_case("err_csr_conflict_xor", 1'b1, ap);

    // Case 7: Everything ON (guard worst-case)
    ap = '1;
    send_err_case("err_all_ap_bits_on", 1'b0, ap);

    // Case 8: OR + SRL overlap
    ap = '0;
    ap.lor = 1'b1;
    ap.srl = 1'b1;
    send_err_case("err_or_and_srl_overlap", 1'b0, ap);

    `uvm_info("BMU_LOGIC_ERR_SEQ", "Finished Logic Error Sequence", UVM_LOW)
  endtask

endclass

`endif
