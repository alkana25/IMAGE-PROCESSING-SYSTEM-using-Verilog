# FPGA-Based Real-Time Image Processing System

This repository hosts a high-performance **Image Processing System** implemented on an FPGA using **Verilog HDL**. The system performs real-time **2D Convolution** to apply a **Laplacian Edge Detection** filter on images and displays the processed output via a **VGA Interface** (640x480 @ 60Hz).

The design features a fully pipelined architecture with **Line Buffering** and **Sliding Window** techniques to process RGB channels in parallel.

## Features
* **Real-Time Processing:** Processes 640x480 video frames at 60 FPS using a 25 MHz pixel clock.
* **Parallel Architecture:** Three independent processing pipelines for **Red, Green, and Blue** channels.
* **Convolution Engine:** Implements a $3\times3$ Laplacian Kernel (Center: -8, Periphery: +1) for sharp edge detection.
* **Memory Management:** Utilizes **Line Buffering** to create a $3\times3$ pixel window from a continuous data stream, minimizing memory bandwidth.
* **VGA Controller:** Custom VGA driver generating standard H-Sync and V-Sync signals for display output.
* **Verification:** Validated against a **MATLAB** reference model to ensure bit-precise accuracy.

## Repository Structure

| File | Description |
| :--- | :--- |
| `src/conv_unit.v` | The core arithmetic unit performing the convolution operation on a $3\times3$ pixel matrix. |
| `src/controller.v` | Manages Line Buffers (`buffer1`, `buffer2`) and implements the **Sliding Window** algorithm. |
| `src/vga_driver.v` | Generates horizontal and vertical timing signals for 640x480 @ 60Hz resolution. |
| `src/top.v` | Top-level module integrating the Clock Wizard, VGA Driver, and RGB processing pipelines. |
| `src/blk_mem_*.v` | Block RAM IP cores storing the image data for R, G, and B channels. |
| `sim/` | Testbenches for individual modules and the top-level system verification. |
| `docs/Experiment_8_Report.pdf` | Detailed technical report covering architecture, state machines, and resource utilization. |

## System Architecture
The system architecture is designed to minimize latency and maximize throughput:

1.  **Memory Read:** Pixel data is read from Block RAM (BRAM) sequentially.
2.  **Line Buffering (Controller):**
    * Incoming pixels are stored in internal line buffers to maintain access to 3 concurrent rows (N-2, N-1, N).
    * A **Sliding Window** moves across these rows to form a $3\times3$ matrix for the convolution kernel.
3.  **Convolution (Processing Unit):**
    * The $3\times3$ matrix is multiplied by the Laplacian Kernel:
        $$
        K = \begin{bmatrix}
        1 & 1 & 1 \\
        1 & -8 & 1 \\
        1 & 1 & 1
        \end{bmatrix}
        $$
    * The result is clamped (0-15) and passed to the output.
4.  **Display (VGA):** The processed pixels are synchronized with `VGA_HS` and `VGA_VS` signals for monitor display.

## Simulation & Verification
The design was verified using **Xilinx Vivado** and compared against a software model:
* **MATLAB Comparison:** The hardware output (exported as `.txt` files) was compared with a MATLAB implementation of the Laplacian filter. The results showed a near-perfect match, confirming the correctness of the Verilog logic.
* **Visual Output:** High-frequency components (edges) were successfully isolated, creating clear outlines on a black background.

## Results & Performance
The design was synthesized and implemented on the target FPGA with the following resource utilization:

### Resource Utilization
| Resource | Used | Total | Utilization % |
| :--- | :--- | :--- | :--- |
| **LUT** | 6,883 | 63,400 | **10.86%** |
| **FF (Flip-Flop)** | 15,861 | 126,800 | **12.51%** |
| **BRAM (Block RAM)** | 106.5 | 135 | **78.89%** |
| **IO** | 16 | 210 | 7.62% |

*Note: High BRAM usage is due to the storage requirements for three full-frame image channels and line buffering mechanisms.*

### Timing Analysis
* **Pixel Clock:** 25 MHz (derived from 100 MHz system clock).
* **Horizontal Active Time:** $25.6 \mu s$ (Matches theoretical 640 cycles).
* **Vertical Active Time:** $16.74 ms$ (Matches theoretical 60Hz frame rate).

---
*This project was developed as part of the Digital System Design Applications course (Experiment 8).*
