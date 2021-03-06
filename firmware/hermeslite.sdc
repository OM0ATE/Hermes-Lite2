
set_time_format -unit ns -decimal_places 3


create_clock -period 76.8MHz [get_ports rffe_ad9866_clk76p8]		-name rffe_ad9866_clk76p8
##create_clock -period 153.6MHz -waveform {1 4.255}	  [get_ports rffe_ad9866_rxclk]				-name rffe_ad9866_rxclk


create_clock -name phy_clk125 -period 125.000MHz	[get_ports phy_clk125]

create_clock -name phy_rx_clk -period 8.000	-waveform {2 6} [get_ports {phy_rx_clk}]

#virtual base clocks on required inputs
create_clock -name virt_phy_rx_clk	-period 8.000

create_clock -name virt_clock_76p8MHz	-period 76.8MHz

create_clock -name virt_ad9866_rxclk_tx -waveform {1.5 4.755} -period 153.6MHz 
create_clock -name virt_ad9866_rxclk_rx -period 153.6MHz 


## run derive_pll_clocks -use_net_name in timing analyzer to generate template for below

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name clock_125MHz {ethpll_inst|altpll_component|auto_generated|pll1|clk[0]}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 90.00 -duty_cycle 50.00 -name clock_90_125MHz {ethpll_inst|altpll_component|auto_generated|pll1|clk[1]}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 50 -duty_cycle 50.00 -name clock_2_5MHz {ethpll_inst|altpll_component|auto_generated|pll1|clk[2]}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|inclk[0]} -phase 180.0 -divide_by 5 -duty_cycle 50.00 -name clock_25MHz {ethpll_inst|altpll_component|auto_generated|pll1|clk[3]}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 10 -duty_cycle 50.00 -name clock_12p5MHz {ethpll_inst|altpll_component|auto_generated|pll1|clk[4]}


create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|clk[1]} -name clock_ethtxextfast {ethtxext_clkmux_i|auto_generated|clkctrl1|outclk}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|clk[3]} -name clock_ethtxextslow {ethtxext_clkmux_i|auto_generated|clkctrl1|outclk} -add

set_clock_groups -exclusive -group {clock_ethtxextslow} -group {clock_ethtxextfast} 

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|clk[0]} -name clock_ethtxintfast {ethtxint_clkmux_i|auto_generated|clkctrl1|outclk}

create_generated_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|clk[4]} -name clock_ethtxintslow {ethtxint_clkmux_i|auto_generated|clkctrl1|outclk} -add

set_clock_groups -exclusive -group {clock_ethtxintslow} -group {clock_ethtxintfast} 

create_generated_clock -source {ad9866pll_inst|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name clock_76p8MHz {ad9866pll_inst|altpll_component|auto_generated|pll1|clk[0]}

create_generated_clock -source {ad9866pll_inst|altpll_component|auto_generated|pll1|inclk[0]} -multiply_by 2 -duty_cycle 50.00 -name clock_153p6_mhz {ad9866pll_inst|altpll_component|auto_generated|pll1|clk[1]}


## Create TX clock version based on pin output
create_generated_clock -name tx_output_clock -master_clock [get_clocks {clock_ethtxextfast}] -source [get_pins {ethtxext_clkmux_i|auto_generated|clkctrl1|outclk}] [get_ports {phy_tx_clk}]
##create_generated_clock -name tx_output_clock -source {ethpll_inst|altpll_component|auto_generated|pll1|clk[0]} [get_ports {phy_tx_clk}]
##create_generated_clock -name tx_output_clock -source [get_clocks clock_ethtxextfast] [get_ports {phy_tx_clk}]


derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************

# If setup and hold delays are equal then only need to specify once without max or min

#PHY Data in
set_input_delay  -max 0.8  -clock virt_phy_rx_clk [get_ports {phy_rx[*]}]
set_input_delay  -min 1.0 -clock virt_phy_rx_clk -add_delay [get_ports {phy_rx[*]}]
set_input_delay  -max 0.8 -clock virt_phy_rx_clk -clock_fall -add_delay [get_ports {phy_rx[*]}]
set_input_delay  -min 1.0 -clock virt_phy_rx_clk -clock_fall -add_delay [get_ports {phy_rx[*]}]

set_input_delay  -max 0.8  -clock virt_phy_rx_clk [get_ports {phy_rx_dv}]
set_input_delay  -min 1.8 -clock virt_phy_rx_clk -add_delay [get_ports {phy_rx_dv}]
set_input_delay  -max 0.8 -clock virt_phy_rx_clk -clock_fall -add_delay [get_ports {phy_rx_dv}]
set_input_delay  -min 1.8 -clock virt_phy_rx_clk -clock_fall -add_delay [get_ports {phy_rx_dv}]


#PHY PHY_MDIO Data in +/- 10nS setup and hold
set_input_delay  10  -clock clock_2_5MHz -reference_pin [get_ports phy_mdc] {phy_mdio}


#**************************************************************
# Set Output Delay
#**************************************************************

# If setup and hold delays are equal then only need to specify once without max or min

#PHY
set_output_delay  -max 1.0  -clock tx_output_clock [get_ports {phy_tx[*] phy_tx_en}]
set_output_delay  -min -0.8 -clock tx_output_clock [get_ports {phy_tx[*] phy_tx_en}]  -add_delay
set_output_delay  -max 1.0  -clock tx_output_clock [get_ports {phy_tx[*] phy_tx_en}]  -clock_fall -add_delay
set_output_delay  -min -0.8 -clock tx_output_clock [get_ports {phy_tx[*] phy_tx_en}]  -clock_fall -add_delay

#PHY (2.5MHz)
set_output_delay  10 -clock clock_2_5MHz -reference_pin [get_ports phy_mdc] {phy_mdio}



## IO

set_input_delay -min 100 -clock virt_clock_76p8MHz [get_ports io_phone_tip]
set_input_delay -max -100 -clock virt_clock_76p8MHz [get_ports io_phone_tip]
set_input_delay -min 100 -clock virt_clock_76p8MHz [get_ports io_phone_ring]
set_input_delay -max -100 -clock virt_clock_76p8MHz [get_ports io_phone_ring]
set_input_delay -min 100 -clock virt_clock_76p8MHz [get_ports io_cn8]
set_input_delay -max -100 -clock virt_clock_76p8MHz [get_ports io_cn8]

set_output_delay -min 100 -clock virt_clock_76p8MHz [get_ports io_db1_5]
set_output_delay -max -100 -clock virt_clock_76p8MHz [get_ports io_db1_5]
set_output_delay -min 100 -clock virt_clock_76p8MHz [get_ports {io_led_d*}]
set_output_delay -max -100 -clock virt_clock_76p8MHz [get_ports {io_led_d*}]

#*************************************************************************************
# Set Clock Groups
#*************************************************************************************


set_clock_groups -asynchronous -group { \
					clock_ethtxintfast \
					clock_ethtxintslow \
					clock_ethtxextfast \
					clock_ethtxextslow \
					clock_125MHz \
					clock_90_125MHz \
					clock_2_5MHz \
					tx_output_clock \
				       } \
					-group {phy_rx_clk } \
					-group {clock_153p6_mhz rffe_ad9866_clk76p8 clock_76p8MHz}

#**************************************************************
# Set Maximum Delay
#**************************************************************

set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|dhcp:dhcp_inst|length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|dhcp:dhcp_inst|length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|tx_protocol*}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|tx_protocol*}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|cdc_sync:cdc_sync_inst7|sigb[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 2
set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|cdc_sync:cdc_sync_inst7|sigb[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 1


#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|run_destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 2
#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|run_destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 1


set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|arp:arp_inst|tx_byte_no[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]}] -setup -start 2
set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|arp:arp_inst|tx_byte_no[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]}] -hold -start 1


set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|Tx_send:tx_send_inst|udp_tx_length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|Tx_send:tx_send_inst|udp_tx_length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|length[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|dhcp:dhcp_inst|destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -setup -start 3
#set_multicycle_path -from [get_keepers {ethernet:ethernet_inst|network:network_inst|dhcp:dhcp_inst|destination_ip[*]}] -to [get_keepers {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]}] -hold -start 2


#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|icmp_fifo:icmp_fifo_inst|*} -to {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]} -setup -start 2
#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|icmp_fifo:icmp_fifo_inst|*} -to {ethernet:ethernet_inst|network:network_inst|ip_send:ip_send_inst|shift_reg[*]} -hold -start 1


#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|udp_send:udp_send_inst|byte_no[*]} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -setup -start 2
#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|udp_send:udp_send_inst|byte_no[*]} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -hold -start 1


#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|tx_protocol*} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -setup -start 2
#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|tx_protocol*} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -hold -start 1


#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|sending*} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -setup -start 2
#set_multicycle_path -from {ethernet:ethernet_inst|network:network_inst|icmp:icmp_inst|sending*} -to {ethernet:ethernet_inst|network:network_inst|mac_send:mac_send_inst|shift_reg[*]} -hold -start 1



set_max_delay -from clock_ethtxintfast -to tx_output_clock 4.5
set_max_delay -from clock_ethtxintslow -to tx_output_clock 4.5

set_max_delay -from clock_2_5MHz -to clock_ethtxintfast 22


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from clock_ethtxextfast -to tx_output_clock -2

#**************************************************************
# Set False Paths
#**************************************************************

# Set false path to generated clocks that feed output pins
set_false_path -to [get_ports {phy_mdc}]

set_false_path -from {ethtxint_clkmux_i|auto_generated|ena_reg}
set_false_path -from {ethtxext_clkmux_i|auto_generated|ena_reg}

# Set false paths to remove irrelevant setup and hold analysis
set_false_path -fall_from  virt_phy_rx_clk -rise_to phy_rx_clk -setup
set_false_path -rise_from  virt_phy_rx_clk -fall_to phy_rx_clk -setup
set_false_path -fall_from  virt_phy_rx_clk -fall_to phy_rx_clk -hold
set_false_path -rise_from  virt_phy_rx_clk -rise_to phy_rx_clk -hold

set_false_path -fall_from [get_clocks clock_ethtxintfast] -rise_to [get_clocks tx_output_clock] -setup
set_false_path -rise_from [get_clocks clock_ethtxintfast] -fall_to [get_clocks tx_output_clock] -setup
set_false_path -fall_from [get_clocks clock_ethtxintfast] -fall_to [get_clocks tx_output_clock] -hold
set_false_path -rise_from [get_clocks clock_ethtxintfast] -rise_to [get_clocks tx_output_clock] -hold

## Multicycle for frequency computation
set_multicycle_path 2 -from {data[*]} -to {freqcompp[*][*]} -setup -end 
set_multicycle_path 1 -from {data[*]} -to {freqcompp[*][*]} -hold -end 

## AD9866 RX Path

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rxsync}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rxsync}]

##set_input_delay -add_delay -max -clock virt_ad9866_rxclk_tx 2.78 [get_ports {rffe_ad9866_rx[*]}]
##set_input_delay -add_delay -min -clock virt_ad9866_rxclk_tx 0.5 [get_ports {rffe_ad9866_rx[*]}]

## Break out as bits for individual control of delay

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[0]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[0]}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[1]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[1]}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[2]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[2]}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[3]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[3]}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[4]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[4]}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 2.78 [get_ports {rffe_ad9866_rx[5]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.5 [get_ports {rffe_ad9866_rx[5]}]


## AD9866 TX Path
## Adjust for PCB delays

set_output_delay -add_delay -max -clock virt_ad9866_rxclk_tx 1.0 [get_ports {rffe_ad9866_txsync}]
set_output_delay -add_delay -min -clock virt_ad9866_rxclk_tx -0.9 [get_ports {rffe_ad9866_txsync}]

set_output_delay -add_delay -max -clock virt_ad9866_rxclk_tx 1.0 [get_ports {rffe_ad9866_tx[*]}]
set_output_delay -add_delay -min -clock virt_ad9866_rxclk_tx -0.9 [get_ports {rffe_ad9866_tx[*]}]

set_multicycle_path -to [get_ports {rffe_ad9866_txsync}] -setup -start 2
set_multicycle_path -to [get_ports {rffe_ad9866_txsync}] -hold -start 1

set_multicycle_path -to [get_ports {rffe_ad9866_tx[*]}] -setup -start 2
set_multicycle_path -to [get_ports {rffe_ad9866_tx[*]}] -hold -start 1

##set_max_delay -from {IF_Rx_ctrl_*} -to {freqcompp*} 15.9
