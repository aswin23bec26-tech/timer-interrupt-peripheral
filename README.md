# Timer Interrupt Peripheral (Verilog)

## 1. Overview
This project implements a **memory-mapped hardware timer peripheral with interrupt generation**, similar to timers found in microcontrollers and SoCs.  
The design allows a CPU to configure a timer via registers, start the timer, and receive an interrupt when the timer expires.

Key focus areas:
- Event-driven design (no polling)
- Clear separation of control, data path, and interrupt logic
- Synthesizable RTL suitable for FPGA/SoC integration

---

## 2. Architecture
The timer peripheral consists of three main hardware blocks:

- **Register File (`timer_regs`)**  
  Provides a memory-mapped interface for software control and status.

- **Timer Counter (`timer_counter`)**  
  Implements a down-counting timer with automatic reload.

- **Interrupt Controller (`irq_ctrl`)**  
  Latches interrupt events and generates a CPU interrupt request.



---

## 3. Register Map

| Address | Register | Description |
|-------:|---------|-------------|
| 0x0 | CTRL | bit[0]: Timer Enable, bit[1]: Interrupt Enable |
| 0x4 | LOAD | 32-bit timer reload value |
| 0x8 | COUNT | Read-only current timer count |
| 0xC | STATUS | bit[0]: Interrupt Flag (Write-1-to-Clear) |

---

## 4. Interrupt Operation (Step-by-Step)

1. Software writes a non-zero value to the **LOAD** register  
2. Software enables the timer and interrupt using the **CTRL** register  
3. The timer counter decrements on every clock cycle  
4. When the counter reaches zero, a **timer expiration event** is generated  
5. The interrupt controller latches this event and asserts `irq`  
6. The CPU services the interrupt  
7. Software clears the interrupt by writing `1` to `STATUS[0]`

This behavior closely matches real MCU timer peripherals.

---

## 5. RTL Modules

### `timer_top`
Top-level integration module connecting registers, counter, and interrupt logic.

### `timer_regs`
Implements control, load, status, and count registers with a simple bus interface.

### `timer_counter`
Down-counting timer with reload capability.

### `irq_ctrl`
Interrupt flag latch with masking and software clear support.

---

## 6. Verification
A self-checking testbench (`tb_timer_top.v`) is used to verify:
- Register read/write operations
- Correct timer countdown behavior
- Interrupt assertion on timer expiration
- Interrupt clear using W1C semantics



---

## 7. Synthesis
The design was synthesized using **Xilinx Vivado**.

- LUTs: 124  
- Flip-Flops: 68  
- BRAM: 0  
- DSP: 0  
- Timing: Met  

This confirms the design is lightweight and synthesizable.

---

## 8. How to Run

### Simulation
- Open Vivado
- Add RTL files from `rtl/`
- Add testbench from `tb/`
- Run behavioral simulation

### Synthesis
- Set `timer_top` as the top module
- Run synthesis

---

## 9. Future Improvements
- Add APB/AHB bus interface
- Support multiple timers
- Add prescaler for flexible timing
- Integrate power-saving clock gating

---

