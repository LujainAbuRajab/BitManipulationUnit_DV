import uvm_pkg::*;
`include "uvm_macros.svh"

class or_seq extends uvm_sequence #(bmu_transaction);

  `uvm_object_utils(or_seq)

  function new(string name = "or_seq");
    super.new(name);
  endfunction

  task body();
    bmu_transaction tr;

    repeat (5) begin
      tr = bmu_transaction::type_id::create("tr");

      start_item(tr);

      // Clear AP struct first
      tr.clear_ap();

      // OR operation
      tr.ap.lor     = 1'b1;
      tr.ap.zbb     = 1'b0;  

      // Inputs
      tr.a_in       = $urandom;
      tr.b_in       = $urandom;

      // Control
      tr.valid_in   = 1'b1;
      tr.csr_ren_in = 1'b0;
      tr.expect_error = 1'b0;

      finish_item(tr);

      `uvm_info("OR_SEQ",
        $sformatf("Sent OR transaction: a=0x%08h b=0x%08h",
                  tr.a_in, tr.b_in),
        UVM_LOW)
    end
  endtask

endclass : or_seq
