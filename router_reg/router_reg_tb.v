module router_reg_tb();
reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
reg [7:0]data_in;
wire parity_done,low_pkt_valid,err;
wire [7:0]dout;
integer i;
  
router_reg DUT(clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in,parity_done,low_pkt_valid,err,dout);
  
initial
begin
	clock=0;
	forever #5 clock = ~clock;
end
  
task rst();
	begin
		@(negedge clock);
		resetn = 0;
		@(negedge clock);
		resetn = 1;
	end
endtask
  
task initialize();
	begin
		{clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in}=0;
	end
endtask
  
task good_pkt();
	begin:b1
		reg [7:0]payload_data,parity,header;
		reg [5:0]payload_len;
		reg [1:0]addr;
		@(negedge clock);
		payload_len = 6'd14;
		addr = 2'b10;
		pkt_valid = 1'b1;
		detect_add = 1'b1;
		header = {payload_len,addr};
		parity = 8'h00^header;
		data_in = header;
		@(negedge clock);
		detect_add = 0;
		lfd_state = 1;
		full_state = 0;
		fifo_full = 0;
		laf_state = 0;
		for(i=0;i<payload_len;i=i+1)
		begin
			@(negedge clock);
			lfd_state = 0;
			ld_state = 1;
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity^data_in;
		end
		@(negedge clock);
		pkt_valid = 0;
		data_in = parity;
		@(negedge clock);
		ld_state = 0;
	end
endtask
  
task bad_pkt();
	begin:b1
		reg [7:0]payload_data,parity,header;
		reg [5:0]payload_len;
		reg [1:0]addr;
		@(negedge clock);
		payload_len = 6'd14;
		addr = 2'b10;
		pkt_valid = 1;
		detect_add = 1;
		header = {payload_len,addr};
		parity = 8'h00^header;
		data_in = header;
		@(negedge clock);
		detect_add = 0;
		lfd_state = 1;
		full_state = 0;
		fifo_full = 0;
		laf_state = 0;
		for(i=0;i<payload_len;i=i+1)
		begin
			@(negedge clock);
			lfd_state = 1'b0;
			ld_state = 1;
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity^data_in;
		end
		@(negedge clock);
		pkt_valid = 0;
		data_in = ~parity;
		@(negedge clock); 
		ld_state = 0;
	end
endtask
  
initial
begin
	rst;
	#10;
	initialize;
	#10;
	good_pkt;
	#100;
	rst;
	#10;
	bad_pkt;
end
  
initial
	#1000 $finish;
initial
	$monitor("clock=%b,resetn=%b,pkt_valid=%b,fifo_full=%b,rst_int_reg=%b,detect_add=%b,ld_state=%b,laf_state=%b,full_state=%b,lfd_state=%b,data_in=%b,parity_done=%b,low_pkt_valid=%b,err=%b,dout=%b",clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in,parity_done,low_pkt_valid,err,dout);
endmodule
