module router_fsm_tb();

reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
reg [1:0]data_in;
wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy;

router_fsm DUT(clock,resetn,pkt_valid,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy);

initial
begin
	#5 clock = 1'b0;
	forever #5 clock = ~clock;
end

task rst();
	begin
		@(negedge clock);
		resetn = 1'b0;
		@(negedge clock);
		resetn = 1'b1;
	end
endtask

task soft_rst_0();
	begin
		@(negedge clock);
		soft_reset_0 = 1'b1;
		@(negedge clock);
		soft_reset_0 = 1'b0;
	end
endtask

task soft_rst_1();
	begin
		@(negedge clock);
		soft_reset_1 = 1'b1;
		@(negedge clock);
		soft_reset_1 = 1'b0;
	end
endtask

task soft_rst_2();
	begin
		@(negedge clock);
		soft_reset_2 = 1'b1;
		@(negedge clock);
		soft_reset_2 = 1'b0;
	end
endtask

//Router packet small size i.e. less than 16

//case1

task da_lfd_ld_lp_cpe_da();
	begin
		@(negedge clock);           
		pkt_valid     = 1'b1;
		data_in       = 2'b00;       //decode_address
		fifo_empty_0  = 1'b1;
		@(negedge clock);            //load_first_data
		@(negedge clock);            //load_data
		fifo_full = 1'b0;                       
		pkt_valid = 1'b0;      
		@(negedge clock);            //load_parity
		@(negedge clock);            //check_parity_error
		fifo_full = 1'b0;            //decode_address
	end
endtask

//Router packet medium size i.e. 16 < packet > 18

//case2

task da_wte_lfd_ld_lp_cpe_da();
	begin
		@(negedge clock);            
		pkt_valid     = 1'b1;
		data_in       = 2'b01;       //decode_address
		fifo_empty_1  = 1'b0;
    @(negedge clock);            //wait_till_empty 
		fifo_empty_1  = 1'b1;       
		data_in       = 1'b1;
    @(negedge clock);            //load_first_data
		@(negedge clock);            //load_data
		fifo_full = 1'b0;
		pkt_valid = 1'b0;     
		@(negedge clock);            //load_parity
		@(negedge clock);            //check_parity_error
		fifo_full = 1'b0;            //decode_address
	end
endtask
		
//case3

task da_lfd_ld_ff_laf_lp_cpe_da();
	begin
	  @(negedge clock);            
		pkt_valid     = 1'b1;
		data_in       = 2'b01;        //decode_address
		fifo_empty_1  = 1'b1;
		@(negedge clock);            //load_first_data
		@(negedge clock);            //load_data
		fifo_full = 1'b1;
		@(negedge clock);            //fifo_full_state
		fifo_full = 1'b0;
		@(negedge clock);            //load_after_full
		parity_done = 1'b0;
		low_pkt_valid = 1'b1;
		@(negedge clock);            //load_parity
		@(negedge clock);            //check_parity_error
		fifo_full = 1'b0;            //decode_address
	end
endtask

//case4

task da_lfd_ld_lp_cpe_ff_laf_da();
	begin
		@(negedge clock);            //decode_address
		pkt_valid     = 1'b1;
		data_in       = 2'b01;
		fifo_empty_1  = 1'b1;
		@(negedge clock);            //load_first_data
		@(negedge clock);            //load_data
		fifo_full = 1'b0;
		pkt_valid = 1'b0;     
		@(negedge clock);            //load_parity
		@(negedge clock);            //check_parity_error
		fifo_full = 1'b1;
		@(negedge clock);            //fifo_full_state
		fifo_full = 1'b0;
		@(negedge clock);            //load_after_full
		parity_done = 1'b1;          //decode_address
	end
endtask

//case5

task da_lfd_ld_ff_laf_ld_lp_cpe_da();
	begin
		@(negedge clock);            //decode_address
		pkt_valid     = 1'b1;
		data_in       = 2'b01;
		fifo_empty_1  = 1'b1;
		@(negedge clock);            //load_first_data
		@(negedge clock);            //load_data
		fifo_full = 1'b1;
		@(negedge clock);            //fifo_full_state
		fifo_full = 1'b0;
		@(negedge clock);            //load_after_full
		parity_done = 1'b0;
		low_pkt_valid = 1'b0;        //load_data
		@(negedge clock);           
	  fifo_full = 1'b0;            //load_parity
		pkt_valid = 1'b0;
		@(negedge clock);            //check_parity_error
		fifo_full = 1'b0;            //decode_address
	end
endtask

//process to generate stimulus

initial
begin
    
	rst;
	soft_rst_0;
	soft_rst_1;
	soft_rst_2;
	da_lfd_ld_lp_cpe_da;

	#1000 $finish;
end
endmodule
