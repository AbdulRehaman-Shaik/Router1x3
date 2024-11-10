module router_top_tb();

reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
reg [7:0]data_in;
wire [7:0]data_out_0,data_out_1,data_out_2;
wire vld_out_0,vld_out_1,vld_out_2,error,busy;
integer i;

router_top DUT(clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy);

initial 
begin
	clock = 1'b0;
	forever #10 clock = ~clock;
end

task initialize();
	begin
		{clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in} = 0;
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

//packet_generation

task pkt_gen_16;
	reg [7:0]payload_data,parity,header;
	reg [5:0]payload_len;
	reg [1:0]addr;

      begin
	      wait(~busy)
	      @(negedge clock);
	      payload_len = 14;
	      addr = 2'b01;         //valid packet
	      header = {payload_len,addr};
	      parity = 0;
	      data_in = header;
	      pkt_valid = 1;
	      parity = parity ^ header;
	      @(negedge clock);
	      wait(~busy)
	      for(i=0;i<payload_len;i=i+1)
		      begin
			      @(negedge clock);
			      wait(~busy)
			      payload_data = {$random}%256;
			      data_in = payload_data;
			      parity = parity ^ payload_data;
		      end
		      @(negedge clock);
		      wait(~busy)
		      @(negedge clock);
		      pkt_valid = 0;
		      data_in = parity;
      end
endtask

//process to generate stimulus

initial
begin
	initialize;
	rst;
	@(negedge clock);
	pkt_gen_16;
	#50;
	read_enb_1 = 1;
	@(negedge clock);
	wait(~vld_out_1)
	@(negedge clock);
	read_enb_1 = 0;
	#1000 $finish;
end
endmodule
