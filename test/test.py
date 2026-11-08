# SPDX-FileCopyrightText: © 2026 Toivo Henningsson
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from random import randrange


@cocotb.test()
async def test_project(dut):
	# Set the clock period to 10 us (100 KHz)
	clock = Clock(dut.clk, 10, unit="us")
	cocotb.start_soon(clock.start())

	BITS = int(dut.BITS.value)
	DEPTH = int(dut.DEPTH.value)
	print("BITS =", BITS)
	print("DEPTH =", DEPTH)
	N = 2**BITS

	# Reset
	dut.rst_n.value = 0
	await ClockCycles(dut.clk, 10)
	dut.rst_n.value = 1

	# Test
	data = []
	for i in range(DEPTH*4):
		dut.ui_in.value = randrange(256)
		dut.uio_in.value = randrange(128) # don't shift
		await ClockCycles(dut.clk, randrange(1,5))

		data_in = randrange(N)
		dut.ui_in.value = data_in & 255
		dut.uio_in.value = ((data_in >> 8)&127) | 128 # do shift
		await ClockCycles(dut.clk, 1)
		#print("in:", (i, data_in))
		data.append(data_in)

		if i >= DEPTH:
			data_out = (dut.uo_out.value.integer) | (dut.uio_out.value.integer << 8)
			#print("out:", (i, data_out))
			assert data_out == data[i - DEPTH]
