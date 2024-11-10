module router_sync_tb();
reg clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2;
reg [1:0]data_in;
wire fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
wire [2:0]write_enb;
wire vld_out_0,vld_out_1,vld_out_2;

router_sync DUT(clock,resetn,detect_add,data_in,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2,vld_out_0,vld_out_1,vld_out_2,write_enb,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2);

initial
begin
	clock = 1'b0;
	forever #5 clock = ~clock;
end

task initialize();
	begin
		{clock,resetn,detect_add,data_in,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2}=0;
	end
endtask

task rst();
	begin
		@(negedge clock);
		resetn = 1'b0;
		@(negedge clock);
		resetn = 1'b1;
	end
endtask

task det_add;
	begin
		@(negedge clock);
	  detect_add = 1'b1;
    data_in = 2'b00;
  end
endtask

task write_reg;
	begin
		write_enb_reg = 1'b1;
		#10;
		write_enb_reg = 1'b0;
	end
endtask

task full;
	begin
		full_0 = 1'b1; 
		full_1 = 1'b0;
		full_2 = 1'b0;
	end
endtask

task empty;
	begin
		empty_0 = 1'b0;
		empty_1 = 1'b1;
		empty_2 = 1'b1;
	end
endtask

task soft_reset;
	begin
		@(negedge clock);
		read_enb_0 = 1'b0;
	  read_enb_1 = 1'b1;
	  read_enb_2 = 1'b1;
	end
endtask

//process to generate stimulus

initial
begin
	initialize;
	rst;
	det_add;
	full;
	empty;
	write_reg;
	soft_reset;
	#1000 $finish;
end
endmodule
