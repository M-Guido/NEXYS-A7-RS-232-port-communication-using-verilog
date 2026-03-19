# NEXYS-A7-RS-232-port-communication-using-verilog
Verilog implementation of RS-232 receiver/transmitter for 9600 bps, 8N1, with ASCII offset by 0x20.


## Project overview

The goal of this project is to design HDL modules implementing **data reception and transmission in the RS-232 standard** with the following transmission parameters:

- **1start bit**
- **8 data bits**
- **no parity bit**
- **1 stop bit**
- **9600 bps**
- **no hardware flow control**

The system receives a character from the serial input line `RXD_i`, passes it through a simple processing path, adds the value **0x20** to the received byte, and then transmits the modified byte through `TXD_o`.

For ASCII characters, adding `0x20` often converts uppercase letters to lowercase, for example:

- `A (0x41)` → `a (0x61)`
- `B (0x42)` → `b (0x62)`

The project is intended for:
- **functional simulation**
- **hardware implementation on the Digilent Nexys A7 board**
- **practical verification using a serial terminal**, such as PuTTY

---

## Principle of operation

RS-232 transmission is serial. In the idle state, the line remains at logic high. A frame in **8N1** format consists of:

1. **start bit** = `0`
2. **8 data bits** transmitted from **LSB to MSB**
3. **1 stop bit** = `1`

The project contains:
- a **UART receiver (RX)**
- a **UART transmitter (TX)**
- a **data processing block** adding `0x20` to the received byte
- a **top-level module** connecting everything together

---

## Top-level interface

The top-level design should expose the following ports:

| Signal | Direction | Description |
|--------|-----------|-------------|
| `clk_i` | input | 100 MHz system clock |
| `rst_i` | input | asynchronous reset |
| `RXD_i` | input | RS-232 serial data input |
| `TXD_o` | output | RS-232 serial data output |

---

## Project architecture

A typical module split for this repository is:

- `uart_rx` – RS-232 / UART receiver
- `uart_tx` – RS-232 / UART transmitter
- `top` – top-level module connecting RX, the adder, and TX
- `tb_top` / `tb_uart_*` – simulation testbench(s)

Processing flow:
1. The receiver detects the start bit.
2. It samples the incoming bits according to the bit period for `9600 bps`.
3. After receiving a full byte, it presents the data in parallel form.
4. The byte is incremented by `8'h20`.
5. The transmitter sends the result in UART 8N1 format.

---

## Transmission parameters

For the input clock:

- `clk_i = 100 MHz`
- `baudrate = 9600 bps`

Bit period:
- `Tbit = 1 / 9600 ≈ 104.167 µs`

Number of clock cycles per bit:
- `100,000,000 / 9600 ≈ 10416.67`

In practice, the design usually uses:
- **`CLKS_PER_BIT = 10417`**

---

## Hardware target

The project is prepared for the following FPGA board:

- **Digilent Nexys A7**
- device **Artix-7 XC7A100T-1CSG324C**

The board emulates a serial port over USB, so communication with a PC can be tested without an external UART converter.

---

## Constraints file (XDC)

Example pin assignment:

```xdc
#########################################################################################
# CLOCK:
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk_i} ];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_i}];
#########################################################################################
# RESET:
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {rst_i} ];
#########################################################################################
# RS232:
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports {RXD_i} ];
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports {TXD_o} ];
#########################################################################################
