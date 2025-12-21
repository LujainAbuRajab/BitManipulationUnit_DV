// ==========================
// Include directories
// ==========================
+incdir+../rtl
+incdir+../tb
+incdir+../tb/interface
+incdir+../tb/env
+incdir+../tb/env/agent
+incdir+../tb/env/agent/sequencer
+incdir+../tb/env/scoreboard
+incdir+../tb/sequences
+incdir+../tb/tests

// ==========================
// xmelab options
// ==========================
// -xmelab+no_timescale
// -xmelab+nospecify

// ==========================
// RTL files
// ==========================
../rtl/rtl_defines.sv
../rtl/rtl_pdef.sv
../rtl/rtl_def.sv
../rtl/rtl_lib.sv
../rtl/Bit_Manipulation_Unit.sv

// ==========================
// Interface
../tb/interface/Bit_Manipulation_intf.sv

// ==========================
// Transaction & Sequencer
// ==========================
../tb/env/agent/sequencer/transaction.sv
../tb/env/agent/sequencer/dut_sequencer.sv

// ==========================
// Agent components
// ==========================
../tb/env/agent/driver/dut_driver.sv
../tb/env/agent/monitor/dut_monitor.sv
../tb/env/agent/dut_agent.sv

// ==========================
// Scoreboard & Env
// ==========================
../tb/env/scoreboard/dut_scoreboard.sv
../tb/env/dut_env.sv

// ==========================
// Tests
// ==========================
../tb/tests/dut_base_test.sv
../tb/tests/dut_or_test.sv

// ==========================
// Top TB
// ==========================
../tb/top_tb.sv
