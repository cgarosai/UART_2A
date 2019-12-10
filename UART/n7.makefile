
SRC =	TxUnit.vhd		\
	clkUnit.vhd		\
	RxUnit.vhd		\
	ctrlUnit.vhd		\
	diviseurClk.vhd		\
	echoUnit.vhd		\
	UART.vhd		\
	UART_FPGA_N4.vhd	\
	UART_FPGA_N4.ucf	\

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF = UART_FPGA_N4.ucf
