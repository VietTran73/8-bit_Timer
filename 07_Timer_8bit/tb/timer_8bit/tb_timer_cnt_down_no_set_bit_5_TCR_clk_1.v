`timescale 1ps/1ps

module tb_timer_cnt_down_no_set_bit_5_TCR_clk_1 ();

reg             clk, rst_n;
reg     [3:0]   clk_in;
reg             psel;
reg             penable;
reg             pwrite;
reg     [7:0]   paddr;
reg     [7:0]   pwdata;
wire    [7:0]   prdata;
wire            pready;
wire            pslverr;

reg 	[7:0]	value;
integer 	f;

localparam PERIOD = 10; 

timer_8bit timer_8bit_i(
	.clk (clk),
	.rst_n (rst_n),
	.clk_in (clk_in),
	.psel (psel),
	.penable (penable),
	.pwrite (pwrite),
	.paddr (paddr),
	.pwdata (pwdata),
	.prdata (prdata),
	.pready (pready),
	.pslverr (pslverr)
	
);
 
initial begin
        clk = 1;
        forever #(PERIOD/2) clk = ~clk;
end

initial begin
        clk_in[0] = 1;
        forever #(2*PERIOD/2) clk_in[0] = ~clk_in[0];
end

initial begin
        clk_in[1] = 1;
        forever #(4*PERIOD/2) clk_in[1] = ~clk_in[1];
end

initial begin
        clk_in[2] = 1;
        forever #(8*PERIOD/2) clk_in[2] = ~clk_in[2];
end

initial begin
        clk_in[3] = 1;
        forever #(16*PERIOD/2) clk_in[3] = ~clk_in[3];
end


initial begin
	rst_n = 0;
	#100;
	@ (posedge clk);
	rst_n = 1;
	
	WRITE (10,0);
	WRITE_BIT (1011_0001, 1101_1111, 1);
	WRITE_BIT (0011_0001, 1101_1111, 1); 
end 
initial begin 
	f = $fopen ("output/tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.txt ", "w");
	wait (tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit_i.apb_controller_i.reg_TCR[4]);
	repeat (11) begin 
	@ (posedge tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit_i.counter_i.clk_ena);

	wait (!tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit_i.counter_i.load);

	if (tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit_i.apb_controller_i.reg_TSR != 0)
		begin
		$display ("run incorrectly");
		$fwrite (f ," FAIL\n");
		$fclose (f);
		#500;
		$finish;
		end
	end 
	repeat (3) begin
	@ (posedge clk);
	if (tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit_i.apb_controller_i.reg_TSR != 0) 
		begin 
		$display ("run incorectly");
		$fwrite (f, "FAIL\n");
		$fclose (f) ;
		#500;
		$finish;
		end
	end
	@ (posedge clk);
/*	if (tb_timer_cnt_down_no_set_bit_5_TCR_clk_1.timer_8bit.apb_controller.reg_TSR != 2)
                begin
                $display ("run incorectly");
                $fwrite (f, "FAIL\n");
                $fclose (f) ;
		#500;
                $finish;
                end */
	READ (2, value);
	if (value == 2)
		begin 
		$display ("run corectly");
		$fwrite (f, "PASS\n");
		end
	else 
		begin 
		$display ("run incorectly");
		$fwrite (f, "FAIL\n");
		end 
	$fclose (f);
	#500;
	$finish;
end

task READ;
	input 	[7:0]	 addr;
	output 	[7:0]	 value;
	begin 
	@ (posedge clk); // IDLE
	psel 	= 0;
	penable = 0;
	pwrite 	= 0;
	paddr	= 0;
//	prdata	= 0;
	@ (posedge clk); //setup 
	psel 	= 1;
	penable = 0;
	paddr 	= addr;
	@ (posedge clk);
	penable = 1;
	paddr	= addr;
	wait (pready);
	value 	= prdata;
	@ (posedge clk);
	psel 	= 0;
	penable = 0;
	pwrite 	= 0;
	paddr	= 0;
//	prdata 	= 0;
	
	if (pslverr == 0)
                $display ("read at %d successfully\n", addr);
        else
                $display ("read at %d unsuccessfully\n", addr);
	end
endtask 

task WRITE; 
        
        input  	[7:0]   data_in;
	input 	[7:0]	addr;
        begin
        @ (posedge clk); // IDLE
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;
        @ (posedge clk); //setup
        psel    = 1;
        penable = 0;
	paddr 	= addr;
        @ (posedge clk);
        penable = 1;
        wait (pready);
        pwdata 	= data_in;
        @ (posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;
	
	if (pslverr == 0)
                $display("write %d to %d successfully\n", data_in, addr);
        else
                $display("write %d to %d unsuccessfully\n", data_in, addr);
	end
endtask

task WRITE_BIT;

   	input 	[7:0] 	data_in;
	input 	[7:0] 	mask_in;
	input  	[7:0]	addr;
	reg 	[7:0]	data_tmp_1, data_tmp_2, data_tmp;
	reg 	[7:0] 	reg_out;
		
        begin

	READ (addr, reg_out);
	data_tmp_1 = data_in & mask_in; // tao gia tri chen tai bit 1 mask_in
	data_tmp_2 = reg_out & ~mask_in; // tao vi tri de ghi de tai bit 0 mask_in
	data_tmp   = data_tmp_1 | data_tmp_2;

        @ (posedge clk); // IDLE
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;
        @ (posedge clk); //setup
        psel    = 1;
        penable = 0;
	paddr 	= addr;
        @ (posedge clk);
        penable = 1;
        wait (pready == 1);
        pwdata	= data_tmp;
        @ (posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;

	if (pslverr == 0)
		$display ("write %d to %d successfully\n", data_in, addr);
	else 
		$display ("write %d to %d unsuccessfully\n", data_in, addr);
	end
endtask


endmodule
