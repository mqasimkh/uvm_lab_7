# UVM Lab # 7: Register Level Modeling

# Table of Contents

- [Task 1: Generation](#task-1-generation)
- [Task 2: Integration](#task-2-integration)
    - [uvm_mem_walk_test](#uvm_mem_walk_test)
- [Task 3: Simulation](#task-3-simulation)
    - [Access Verificaton](#access-verificaton)
    - [Functional Verification](#functional-verification)
    - [Automatic Checking on Read](#automatic-checking-on-read)
    - [Register Introspection](#register-introspection)

## Task 1: Generation

Generated the reg model using the command provided in the lab manual. Next called the  the print method in the quicktest.sv to print topology of the reg model.

![screenshot-3](/screenshots/3.png)

## Task 2: Integration

Instantiated the reg model and adapter in router_tb.sv file.

```systemverilog
    yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5 yapp_rm;
    hbus_reg_adapter reg2hbus;
```

Also enabled UVM automation macro for reg model by adding this line:

```systemverilog
`uvm_field_object(yapp_rm, UVM_ALL_ON)
```

Created the reg model and adapter using factory method in the build phase, set path for backdoor accesss and enabled prediction model.

In connect phase, set the sequencer for model address map:

```systemverilog
 yapp_rm.default_map.set_sequencer(hbu.masters[0].sequencer, reg2hbus);
```

Edited the file.f by adding the reg model files for compiling:

```systemverilog
cdns_uvmreg_utils_pkg.sv 
yapp_router_regs_rdb.sv
```

Added the uvm_reset_test to router_test_lib and then set it as file.f to `+UVM_TESTNAME= uvm_reset_test`.

All registers reset were successful with no errors.

![screenshot-6](/screenshots/6.png)

![screenshot-7](/screenshots/7.png)

### uvm_mem_walk_test

Created a new uvm_mem_walk_test and ran uvm_mem_walk_seq which is built-in sequence in uvm that test all read-write memories in reg model.

![screenshot-8](/screenshots/8.png)

Ran the test, and it access all the memory locations 'h1100 to ‘h11ff.

![screenshot-9](/screenshots/9.png)

Added –define INJECT_ERROR in run.sh script and ran again and this time it added 1 error and reported:

## Task 3: Simulation

### Access Verificaton

Created a new reg_access_test in router_test_lib and in the run_phase, test 2 registers, one with RW policy and wrote to it using write and then read using peek, and then wrote using poke and read again. Both the values should be written and read should verify that.

In second test, wrote to RO register using poke and then read it using read. Next wrote using write and read using peek. It should write using poke and return the value with read but with write it should not write to RO reg and should return the old value with peek.

***`RW Test`***

Wrote 17, Returned 17
Wrote 15, Returnned 15.

***PASSED***

![screenshot-12](/screenshots/12c.png)

***`RO Test`***

Wrote 55 using Poke, returned 55. 
Wrote 57 using Write, returned 55.

***PASSED***

![screenshot-12](/screenshots/13c.png)

### Functional Verification

Next created new test named reg_function_test for functional verification. Created handle for yapp_tx_sequencer and yapp_012_seq. Connected the sequencer handle to YAPP UVC sequencer in connect phase.

In run phase, ran the seuqnecer on sequencer using .start method.

1. In test, first wrote to using write method to enable 0th bit of en_reg.
2. Ran the yapp_012 sequence twice. 
3. Accessed and printed using uvm_info the addr count registers.
4. Also printed the values of reg that records oversized registers and bad parity.

Ran the test and the addr count registers were 0 because we needed to enable them in en_reg as well.

So set en_reg to 8’hff and re-ran the test.

![screenshot-14](/screenshots/14c.png)

![screenshot-15](/screenshots/15c.png)

### Automatic Checking on Read

Enabled automatic checking on read by enabling it in the run_phase.

```systemverilog
 tb.yapp_rm.default_map.set_check_on_read(1);
```

Re-ran the error and it gave 4 errors. The reason the we manually set the reg value which should be then called using predict method.

![screenshot-20](/screenshots/20nn.png)

![screenshot-20](/screenshots/n20.png)

So used predict calls and re-ran the test and error were gone.

Since running yapp_short packet, so no oversized packet registered in oversized_pkt_cnt_reg.

### Register Introspection

Instead of manually performing operation on registers, used introspection method directly from reg model to create queue for all RW registers and all the RO registers.

Printed all reg contents along with name using print method by traversing whole queue using foreach loop.

```systemverilog
    foreach(qreg[i]) begin
        if (qreg[i].get_rights() == "RO")
            roregs.push_back(qreg[i]);
            rwregs = qreg.find(i) with (i.get_rights() == "RW");
        end

        foreach(rwregs[i]) begin
            `uvm_info("RW REG:", $sformatf("REG Name: %s   |\tReg #:  %0d |\tReg Value:  %0d", rwregs[i].get_name(), i, rwregs[i]), UVM_LOW)
        end

        foreach(roregs[i]) begin
            `uvm_info("RO REG:", $sformatf("REG Name: %s   |\tReg #:  %0d |\tReg Value:  %0d", roregs[i].get_name(), i, roregs[i]), UVM_LOW)
    end
```
![screenshot-22d](/screenshots/22d.png)