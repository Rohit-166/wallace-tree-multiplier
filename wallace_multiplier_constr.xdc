# CONSTRAINT FILE

# INPUT OF CLOCK

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 7.000 -name sys_clk -waveform {0 5} [get_ports clk]

# ------------------------
# RESET INPUT (BTN0)
# ------------------------
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# ------------------------
# INPUT A[7:0] - from switches SW[7:0]
# ------------------------
set_property PACKAGE_PIN V17 [get_ports {a[0]}]
set_property PACKAGE_PIN V16 [get_ports {a[1]}]
set_property PACKAGE_PIN W16 [get_ports {a[2]}]
set_property PACKAGE_PIN W17 [get_ports {a[3]}]
set_property PACKAGE_PIN W15 [get_ports {a[4]}]
set_property PACKAGE_PIN V15 [get_ports {a[5]}]
set_property PACKAGE_PIN W14 [get_ports {a[6]}]
set_property PACKAGE_PIN W13 [get_ports {a[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {a[*]}]

# ------------------------
# INPUT B[7:0] - from switches SW[15:8]
# ------------------------
set_property PACKAGE_PIN U12 [get_ports {b[0]}]
set_property PACKAGE_PIN V12 [get_ports {b[1]}]
set_property PACKAGE_PIN V11 [get_ports {b[2]}]
set_property PACKAGE_PIN W11 [get_ports {b[3]}]
set_property PACKAGE_PIN U11 [get_ports {b[4]}]
set_property PACKAGE_PIN V10 [get_ports {b[5]}]
set_property PACKAGE_PIN W10 [get_ports {b[6]}]
set_property PACKAGE_PIN W9  [get_ports {b[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[*]}]

# ------------------------
# OUTPUT PRODUCT[15:0] - to LEDs LD15..LD0
# ------------------------
set_property PACKAGE_PIN U16 [get_ports {product[0]}]
set_property PACKAGE_PIN E19 [get_ports {product[1]}]
set_property PACKAGE_PIN U19 [get_ports {product[2]}]
set_property PACKAGE_PIN V19 [get_ports {product[3]}]
set_property PACKAGE_PIN W18 [get_ports {product[4]}]
set_property PACKAGE_PIN U15 [get_ports {product[5]}]
set_property PACKAGE_PIN U14 [get_ports {product[6]}]
set_property PACKAGE_PIN V14 [get_ports {product[7]}]
set_property PACKAGE_PIN V13 [get_ports {product[8]}]
set_property PACKAGE_PIN V3  [get_ports {product[9]}]
set_property PACKAGE_PIN W3  [get_ports {product[10]}]
set_property PACKAGE_PIN U3  [get_ports {product[11]}]
set_property PACKAGE_PIN V2  [get_ports {product[12]}]
set_property PACKAGE_PIN U2  [get_ports {product[13]}]
set_property PACKAGE_PIN V1  [get_ports {product[14]}]
set_property PACKAGE_PIN W2  [get_ports {product[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {product[*]}]

##=========================================================
## NOTES:
## - Inputs a[7:0], b[7:0] come from switches SW0-SW15.
## - Output product[15:0] drives LEDs LD0-LD15.
## - Fits easily in 2 IO banks → no [Place 30-777] errors.
##=========================================================
