remove_design -all
set search_path {../lib}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog { ../rtl/router_fifo .v } 

elaborate router_fifo

link 

check_design

current_design  router_fifo

compile_ultra

write_file -f verilog -hier -output router_fifo_netlist.v
