# media_filer — Median Filter with APB Interface

A **Vivado FPGA project** implementing a **hardware median filter** with **APB (Advanced Peripheral Bus) interface** for image processing applications. Built for **Xilinx Artix-7** using **Vivado 2021.1**.

## Overview

This project implements a **median filter** — a non-linear digital filter commonly used for noise reduction in images (especially salt-and-pepper noise). The filter takes multiple input values, sorts them, and outputs the median value.

The system is wrapped with an **APB bus interface**, making it easy to integrate into a SoC (System on Chip) design where a processor can configure and read results via a standard bus protocol.

## Architecture

The median filter processes **8 input values** of **4-bit** width each, sorts them in ascending order using an **insertion sort** algorithm, and outputs:

1. **All 8 sorted values** (32-bit output bus)
2. **The median value** (4-bit, the 5th element in sorted order)

### Sorting Algorithm

The implementation uses **insertion sort**, which is efficient for small arrays (n=8):

```vhdl
for i in 1 to 7 loop
    temp := r_Mem(i);
    j := i - 1;
    while j >= 0 and r_Mem(j) > temp loop
        r_Mem(j+1) := r_Mem(j);
        j := j - 1;
    end loop;
    r_Mem(j+1) := temp;
end loop;
```

**Characteristics**:
- **Time complexity**: O(n²) worst case, but O(n) for nearly-sorted data
- **Space complexity**: O(1) — in-place sorting
- **Optimal for n=8**: Very low overhead for small fixed-size arrays

### Median Extraction

With 8 values sorted in ascending order:

```
Index:  0    1    2    3    4    5    6    7
          ↓    ↓    ↓    ↓   MED   ↓    ↓    ↓
       [min ...        lower    median    upper ... max]
```

The median is at **index 4** (0-based), which is the 5th smallest value out of 8.

## Component Breakdown

### MedianFilter Entity (VHDL)

Core sorting module:

| Generic | Default | Description |
|---------|---------|-------------|
| **NUM_VALS** | 8 | Number of input values to sort |
| **SIZE** | 4 | Bit width of each value |

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| **clk** | 1-bit | Input | Clock (combinational sort) |
| **input_data** | 32-bit | Input | 8 × 4-bit values packed |
| **output_data** | 32-bit | Output | 8 × 4-bit sorted values |
| **mid** | 4-bit | Output | Median value (5th element) |

**Architecture**: Pure combinational sorting — no pipeline stages. The sort completes in a single combinational path, making it fast but with O(n²) gate delay for n=8.

### apb_wrapper_Median_Filter (Verilog)

APB bus interface wrapper that maps the median filter into memory-mapped I/O:

| APB Address | Register | Access | Description |
|-------------|----------|--------|-------------|
| **0x00** | input_data | Write | Load 32-bit input data (8 × 4-bit values) |
| **0x04** | output_data | Read | Read 32-bit sorted output |
| **0x08** | median | Read | Read 4-bit median value (padded to 32-bit) |

| Signal | Width | Description |
|--------|-------|-------------|
| **clk** | 1-bit | Clock |
| **rst** | 1-bit | Synchronous reset |
| **S_PSEL** | 1-bit | APB select |
| **S_PENABLE** | 1-bit | APB enable (phase 2) |
| **S_PADDR** | 32-bit | Address bus (lower 3 bits used) |
| **S_PWRITE** | 1-bit | Write strobe |
| **S_PWDATA** | 32-bit | Write data |
| **S_PREADY** | 1-bit | Ready response |
| **S_PSLVERR** | 1-bit | Error response |
| **S_PRDATA** | 32-bit | Read data |

**APB Protocol Timing**:
1. **Phase 1 (PENABLE=0)**: Address and control signals are set
2. **Phase 2 (PENABLE=1)**: Data transfer occurs, slave responds with PREADY

## Interfaces

### MedianFilter VHDL Entity

```vhdl
entity MedianFilter is
    Generic (
        NUM_VALS : integer := 8;
        SIZE : integer := 4
    );
    Port (
        clk           : in  std_logic;
        input_data    : in  std_logic_vector(NUM_VALS*SIZE-1 downto 0);
        output_data   : out std_logic_vector(NUM_VALS*SIZE-1 downto 0);
        mid           : out std_logic_vector(SIZE-1 downto 0)
    );
end entity;
```

### apb_wrapper_Median_Filter Verilog Module

```verilog
module apb_wrapper_Median_Filter #(
    parameter BUS_WIDTH = 32,
    parameter ADDR_OFFSET = 'h00000000
) (
    input clk, rst,
    input S_PSEL, S_PENABLE,
    input [31:0] S_PADDR,
    input S_PWRITE,
    input [31:0] S_PWDATA,
    output reg S_PREADY, S_PSLVERR,
    output reg [31:0] S_PRDATA
);
```

## Usage Example (APB Bus Access)

To compute the median of 8 pixel values:

```
1. Write input data to address 0x00:
   APB_WRITE addr=0x00 data=0xABCD1234
   (Each 4-bit nibble represents one pixel value)

2. The filter computes the median combinatorially.

3. Read sorted output from address 0x04:
   APB_READ addr=0x04 → data=0x1234ABCD (sorted)

4. Read median from address 0x08:
   APB_READ addr=0x08 → data=0x00000056 (median value)
```

## Building

### Prerequisites

- **Xilinx Vivado 2021.1** (or later, 64-bit)
- **Xilinx Artix-7 FPGA board** (e.g., Digilent Arty A7, Basys 3)

### Compilation Steps

1. Open **Vivado 2021.1**
2. Select **File → Open Project**
3. Open `project_1.xpr`
4. Select **Flow → Run Synthesis**
5. After synthesis, select **Flow → Run Implementation**
6. Generate bitstream with **Flow → Generate Bitstream**
7. Program the Artix-7 board

### Device Configuration

| Parameter | Value |
|-----------|-------|
| **Family** | Artix-7 |
| **Device** | XC7A35T |
| **Package** | CPG236 |
| **Speed Grade** | -1 |
| **Vivado Version** | 2021.1 |
| **Top-Level Entity** | apb_wrapper_Median_Filter |

### Resource Usage (Estimated)

| Resource | Estimated Usage |
|----------|----------------|
| **LUTs** | ~1-2% of available |
| **FFs** | ~0.5-1% (APB wrapper only, median filter is combinational) |
| **DSPs** | 0 |
| **BRAM** | 0 |

The median filter itself is **purely combinational** — no registers or BRAM are needed. All logic uses LUTs for comparison and swap operations.

## Image Processing Application

Median filters are widely used in image processing for:

### Noise Reduction

- **Salt-and-pepper noise**: Random black and white pixels
- **Impulse noise**: Sudden, sharp disturbances in the signal
- **Preserves edges**: Unlike average filters, median filters preserve sharp transitions

### Processing Modes

| Mode | Description |
|------|-------------|
| **1D filtering** | Filter a row/column of pixel values |
| **2D sliding window** | Apply to NxN neighborhood (requires buffering) |
| **Real-time** | Process pixel streams with FIFO buffering |

**Note**: This implementation processes **8 values at once**. For 2D image filtering, additional logic (line/frame buffers, sliding window logic) is needed to collect the 3×3 or 5×5 neighborhood.

## VHDL Conventions

- **IEEE 1164** — Standard logic types
- **IEEE.STD_LOGIC_ARITH / STD_LOGIC_UNSIGNED** — Arithmetic operations
- **Combinational sort** — Single-cycle sort, no pipeline
- **Type declarations** — `t_Memory` for the sortable array

## Testbench

The project includes a testbench (`MedianFilter_tb.v`) for simulation:

1. Open Vivado and select **Add Sources**
2. Add `MedianFilter_tb.v` from the project directory
3. Set **testbench** as the top module
4. Run **Run Simulation → Run Behavioral Simulation**

The testbench applies sample 32-bit input values and verifies the sorted output and median extraction.

## References

- G.Y. Yang, "Median Filters: A Nonlinear Smoothing Filter," 1984.
- J. Sklansky, "Finding the Signature of an Array," JACM, 1972.
- Xilinx UG573: Artix-7 Data Sheet
- Xilinx UG687: Vivado Design Suite User Guide

> *Note: This README was generated by AI to describe the project. The source code itself was written by the user.*
