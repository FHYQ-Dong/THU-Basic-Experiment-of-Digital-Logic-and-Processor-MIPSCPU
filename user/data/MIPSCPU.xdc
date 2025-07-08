# 100MHz clock
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {clk}]

# reset: KEY3
set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS33} [get_ports {reset}]

# BCD7
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {BCD7[0]}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {BCD7[1]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {BCD7[2]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {BCD7[3]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {BCD7[4]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {BCD7[5]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {BCD7[6]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {BCD7[7]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {BCD7[8]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {BCD7[9]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {BCD7[10]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVCMOS33} [get_ports {BCD7[11]}]