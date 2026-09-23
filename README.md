# SPI Master-Slave Communication

## Description
Verilog implementation of SPI Master-Slave communication
using SPI Mode 0 (CPOL=0, CPHA=0).

## Features
- 8-bit data transfer
- Full-duplex communication
- MSB-first transmission
- Master-generated SCLK
- Chip Select control
- MOSI and MISO communication

## Architecture

Master                    Slave

MOSI  ------------------> MOSI
MISO  <------------------ MISO
SCLK  ------------------> SCLK
CS    ------------------> CS

## Test
Master transmits: 10110010
Slave transmits:  11001010

Expected:
Slave receives:  10110010
Master receives: 11001010

## Result
SPI Master-Slave communication successfully verified
through behavioral simulation in Xilinx Vivado.
