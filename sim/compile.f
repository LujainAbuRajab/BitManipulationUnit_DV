+incdir+../dut
+incdir+../tb

// RTL files 
../rtl/rtl_defines.sv
../rtl/rtl_pdef.sv
../rtl/rtl_def.sv
../rtl/rtl_lib.sv
../rtl/Bit_Manipulation_Unit.sv

// UVM Testbench Components
../tb/env/agent/sequencer/transaction.sv
../tb/env/agent/sequencer/dut_sequencer.sv
../tb/env/agent/monitor/dut_monitor.sv
../tb/env/agent/driver/dut_driver.sv
../tb/env/agent/dut_agent.sv
../tb/env/scoreboard/dut_scoreboard.sv
../tb/env/dut_env.sv

// Tests 
../tb/sequences/bmu_logic_seq.sv
../tb/tests/bmu_smoke_test.sv

// Testbench files
../tb/interface/Bit_Manipulation_intf.sv
../tb/top_tb.sv
