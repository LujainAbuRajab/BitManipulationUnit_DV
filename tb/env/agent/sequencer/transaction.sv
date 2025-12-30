// Black-box DV transaction – no internal DUT assumptions
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

import rtl_pkg::*;

class bmu_transaction extends uvm_sequence_item; //.

  // DUT-visible fields (inputs only)
  rand logic signed [31:0] a_in;
  rand logic        [31:0] b_in;

  // Observed DUT outputs (filled by monitor)
  logic [31:0] dut_result;
  logic        dut_error;

  rand rtl_alu_pkt_t       ap;
  rand logic               valid_in;
  rand logic               csr_ren_in;
  rand logic        [31:0] csr_rddata_in;


  // Verification metadata 
  typedef enum {
    OP_OR,
    OP_ORN,
    OP_XOR,
    OP_XNOR,

    OP_SRL,
    OP_SRA,
    OP_ROR,
    OP_BINV,
    OP_SH2ADD,

    OP_SUB,

    OP_SLT,
    OP_SLTU,
    OP_CTZ,
    OP_CPOP,
    OP_SEXT_B,
    OP_MAX,
    OP_PACK,
    OP_GREV,

    OP_CSR,
    OP_INVALID
  } bmu_op_t;

  bmu_op_t op_type;

  // Expected classification 
  bit expect_error;

  // Constraints
  // valid_in is usually asserted for transactions
  constraint c_valid {
    valid_in == 1'b1;
  }

  // no CSR access unless explicitly tested
  constraint c_csr_default {
    csr_ren_in == 1'b0;
  }

  // One-hot operation enable (only ONE ap field active)
  constraint c_one_hot_ap {
    $onehot({
      ap.lor,
      ap.lxor,
      ap.land,

      ap.srl,
      ap.sra,
      ap.ror,
      ap.binv,

      ap.sh2add,

      ap.sub,

      ap.slt,
      ap.ctz,
      ap.cpop,
      ap.siext_b,
      ap.max,
      ap.pack,
      ap.grev
    });
  }

  // SH2ADD requires zba = 1
  constraint c_sh2add_zba {
    (ap.sh2add) -> (ap.zba == 1'b1);
  }

  // SLT vs SLTU controlled by unsign
  constraint c_slt_mode {
    (ap.slt && ap.unsign) -> (op_type == OP_SLTU);
    (ap.slt && !ap.unsign) -> (op_type == OP_SLT);
  }

  // Constructor
  function new(string name = "bmu_transaction"); //.
    super.new(name);
  endfunction

  // Utility: Clear ap struct before setting bits
  function void clear_ap();
    ap = '0;
  endfunction

  // Utility: Pretty print (for debug)
  function string convert2string();
    return $sformatf(
      "BMU_TXN: op=%0d valid=%0b csr_ren=%0b a=0x%08h b=0x%08h expect_error=%0b",
      op_type, valid_in, csr_ren_in, a_in, b_in, expect_error
    );
  endfunction

  // UVM automation
  `uvm_object_utils_begin(bmu_transaction) //.
    `uvm_field_int(dut_result,     UVM_ALL_ON)
    `uvm_field_int(dut_error,      UVM_ALL_ON)
    `uvm_field_int(a_in,           UVM_ALL_ON)
    `uvm_field_int(b_in,           UVM_ALL_ON)
    `uvm_field_int(valid_in,       UVM_ALL_ON)
    `uvm_field_int(csr_ren_in,     UVM_ALL_ON)
    `uvm_field_int(csr_rddata_in,  UVM_ALL_ON)
    `uvm_field_enum(bmu_op_t, op_type, UVM_ALL_ON)
    `uvm_field_int(expect_error,   UVM_ALL_ON)
  `uvm_object_utils_end

endclass : bmu_transaction //.
