# Median Filter — 8x4-Bit Insertion Sort on Artix-7

VHDL implementation of a median filtering module with APB bus interface for image processing. Built for Xilinx Artix-7.

## Overview

This project implements a median filtering module using insertion sort algorithm for an 8-element input window. The design includes an APB bus wrapper for easy System-on-Chip integration, making it suitable for embedded image processing pipelines.

## Project Structure

| File | Description |
|------|-------------|
| `MedianFilter.vhd` | Core median filter: 8-element insertion sort, APB interface |
| `apb_wrapper_Median_Filter.v` | APB bus wrapper for SoC integration |
| `MedianFilter_tb.v` | Testbench |

## Hardware

- **Device:** Xilinx Artix-7 XC7A35T (xc7a35tcpg236-1)
- **Tool:** Vivado 2021.1
- **Language:** VHDL-2008

## Building

1. Open the project in Vivado
2. Run Synthesis and Implementation
3. Generate bitstream
