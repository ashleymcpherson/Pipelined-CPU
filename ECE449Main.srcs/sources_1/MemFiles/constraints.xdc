## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
#set_property PACKAGE_PIN W5 [get_ports clk]
	#set_property IOSTANDARD LVCMOS33 [get_ports clk]
	#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
	#create_clock -period 10.000 -name clk [get_ports clk]

## Switches
## Memory-mapped to memory.vhd -> sw_in
##Sch name = SW0
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
##Sch name = SW1
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
##Sch name = SW2
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
##Sch name = SW3
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

##Sch name = SW4
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
##Sch name = SW5
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
##Sch name = SW6
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
##Sch name = SW7
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]

##Sch name = SW8
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
##Sch name = SW9
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
##Sch name = SW10
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
##Sch name = SW11
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]

##Sch name = SW12
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
##Sch name = SW13
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
##Sch name = SW14
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
##Sch name = SW15
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]


## LEDs
## Mapped to memory.vhd -> led_out
##Sch name = LD0
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
##Sch name = LD1
set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
##Sch name = LD2
set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
##Sch name = LD3
set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

##Sch name = LD4
set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]
##Sch name = LD5
set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]
##Sch name = LD6
set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]
##Sch name = LD7
set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]

##Sch name = LD8
set_property PACKAGE_PIN V13 [get_ports {leds[8]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[8]}]
##Sch name = LD9
set_property PACKAGE_PIN V3 [get_ports {leds[9]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]
##Sch name = LD10
set_property PACKAGE_PIN W3 [get_ports {leds[10]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]
##Sch name = LD11
set_property PACKAGE_PIN U3 [get_ports {leds[11]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]

##Sch name = LD12
set_property PACKAGE_PIN P3 [get_ports {leds[12]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]
##Sch name = LD13
set_property PACKAGE_PIN N3 [get_ports {leds[13]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]
##Sch name = LD14
set_property PACKAGE_PIN P1 [get_ports {leds[14]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]
##Sch name = LD15
set_property PACKAGE_PIN L1 [get_ports {leds[15]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]


##7 segment display
#set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
#set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
#set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
#set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
#set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
#set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]
	#set_property IOSTANDARD LVCMOS33 [get_ports dp]

#set_property PACKAGE_PIN U2 [get_ports {an[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#set_property PACKAGE_PIN U4 [get_ports {an[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
#set_property PACKAGE_PIN V4 [get_ports {an[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
#set_property PACKAGE_PIN W4 [get_ports {an[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


##Buttons
#set_property PACKAGE_PIN U18 [get_ports btnC]
	#set_property IOSTANDARD LVCMOS33 [get_ports btnC]
# Temporary on-fpga clock (button up)
#set_property PACKAGE_PIN T18 [get_ports clk]
#	set_property IOSTANDARD LVCMOS33 [get_ports clk]
#	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
set_property PACKAGE_PIN W19 [get_ports rst_ex]
	set_property IOSTANDARD LVCMOS33 [get_ports rst_ex]
set_property PACKAGE_PIN T17 [get_ports rst_ld]
	set_property IOSTANDARD LVCMOS33 [get_ports rst_ld]
#set_property PACKAGE_PIN U17 [get_ports btnD]
	#set_property IOSTANDARD LVCMOS33 [get_ports btnD]



##Pmod Header JA
##Sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
##Sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
##Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
##Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]


## JB header mapping from:
## ECE449 "boot loader presentation.pdf" page 12
## Error in .pdf file: pdf JB5-JB8 => JB7-JB10
## STM32F0 SIG      DIR     LOGIC VECTOR        PMOD PIN    FPGA PIN
## ===========      ===     ==============      ========    ========
## DATA BIT 0       OUT     INPUT PORT(8)       JB1         A14
## DATA BIT 1       OUT     INPUT PORT(9)       JB2         A16
## DATA BIT 2       OUT     INPUT PORT(10)      JB3         B15
## DATA BIT 3       OUT     INPUT PORT(11)      JB4         B16
## DATA BIT 4       OUT     INPUT PORT(12)      JB7         A15
## DATA BIT 5       OUT     INPUT PORT(13)      JB8         A17
## DATA BIT 6       OUT     INPUT PORT(14)      JB9         C15
## DATA BIT 7       OUT     INPUT PORT(15)      JB10        C16

##Pmod Header JB
##Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {sys_in[8]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[8]}]
###Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {sys_in[9]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[9]}]
###Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {sys_in[10]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[10]}]
###Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {sys_in[11]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[11]}]

###Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {sys_in[12]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[12]}]
###Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {sys_in[13]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[13]}]
###Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {sys_in[14]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[14]}]
###Sch name = JB10
#set_property PACKAGE_PIN C16 [get_ports {sys_in[15]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[15]}]


## JC header mapping from:
## ECE449 "boot loader presentation.pdf" page 12
## Error in .pdf: JC7 => JC9, JC8 => JC10
## STM32F0 SIG      DIR     LOGIC VECTOR        PMOD PIN    FPGA PIN
## ============     ===     ===============     ========    ========
## SYSTEM CLOCK     OUT     STD LOGIC           JC1         K17
## ACKNOWLEDGE      IN      OUTPUT PORT (0)     JC2         M18
## ADDRESS/DATA     OUT     INPUT PORT(6)       JC9         P17
## LOAD             OUT     INPUT PORT(7)       JC10        R18

##Pmod Header JC
##Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports {clk}]
	set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports {sys_ack_out}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_ack_out}]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]

##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {sys_in[6]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[6]}]
###Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {sys_in[7]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sys_in[7]}]


##Pmod Header JXADC
##Sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[0]}]
##Sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {JXADC[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[1]}]
##Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {JXADC[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[2]}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {JXADC[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[3]}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {JXADC[4]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[4]}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {JXADC[5]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[5]}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {JXADC[6]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[6]}]
##Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {JXADC[7]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[7]}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports Hsync]
	#set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
#set_property PACKAGE_PIN R19 [get_ports Vsync]
	#set_property IOSTANDARD LVCMOS33 [get_ports Vsync]


##USB-RS232 Interface
#set_property PACKAGE_PIN B18 [get_ports RsRx]
	#set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
#set_property PACKAGE_PIN A18 [get_ports RsTx]
	#set_property IOSTANDARD LVCMOS33 [get_ports RsTx]


##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
	#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]
	#set_property PULLUP true [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
#set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
#set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
#set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
#set_property PACKAGE_PIN K19 [get_ports QspiCSn]
	#set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]

