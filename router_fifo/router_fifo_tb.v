module router_fifo_tb();
reg clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
reg [7:0]data_in;
wire [7:0]data_out;
wire full,empty;
integer i;

	router_fifo DUT(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,data_out,full,empty);

initial
begin
	clock = 1'b0;
	forever #5 clock = ~clock;
end

task initialize();
	begin
		{clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in}=0;
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

task soft_rst();
	begin
		@(negedge clock);
		soft_reset = 1'b1;
		@(negedge clock);
		soft_reset = 1'b0;
	end
endtask

task packet_gen();

		reg [7:0]header,payload_data,parity;
		reg [5:0]payload_length;
	        reg [1:0]address;
begin

//header logic

       begin
	       @(negedge clock);
              write_enb = 1'b1;
	      lfd_state = 1'b1;
	      payload_length = 6'd14;
	      address = 2'b00;
	      header = {payload_length,address};
	      data_in = header;
      end

//payload logic

      for(i=0;i<payload_length;i=i+1)
       begin
	       @(negedge clock);
	       write_enb = 1'b1;
	       lfd_state = 1'b0;
	       payload_data ={$random}%256;
	       data_in = payload_data;
       end

//parity logic

      begin
	      @(negedge clock);
	      write_enb = 1'b1;
	      lfd_state = 1'b0;
	      parity = {$random}%256;
	      data_in = parity;
      end
end
endtask

task read(input r,s);
	begin
		@(negedge clock);
		read_enb = r;
		write_enb = s;
	end
endtask

//process to generate stimulus

initial
begin
	initialize;
	rst;
	soft_rst;
	packet_gen;#10;
	read(1'b1,1'b0);
	#200 $finish;
end
initial
	$monitor("clock=%b,resetn=%b,soft_reset=%b,write_enb=%b,read_enb=%b,lfd_state=%b,data_in=%b,data_out=%b,full=%b,empty=%b",clock,resetn,soft_state,write_enb,read_enb,lfd_state,data_in,data_out,full,empty);
endmodule
