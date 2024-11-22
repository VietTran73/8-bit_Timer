`timescale 1ps/1ps 

module tb_apb_controller_overflow_underflow_at_the_same_time ();

reg           	clk;
reg           	rst_n;
wire           	psel;
wire           	pwrite;
wire           	penable;
wire   	[7:0] 	paddr;
wire   	[7:0] 	pwdata;

wire 	[7:0] 	prdata;
wire            pready;
wire          	pslverr;

wire    [7:0] 	start_counter;
wire          	load;
wire          	up_down;
wire          	enable;
wire    [1:0] 	clk_sel;

reg	      	overflow;
reg          	underflow;

reg 	[7:0] 	value;
integer i;
integer f_out;
reg err;

parameter TDR = 8'h00,
	  TCR = 8'h01,
	  TSR = 8'h02;

apb_controller apb_controller_i (

	.clk(clk),
	.rst_n(rst_n),
	.psel(psel),
	.pwrite(pwrite),
	.penable(penable),
	.paddr(paddr),
	.pwdata(pwdata),
	.prdata(prdata),
	.pready(pready),
	.pslverr(pslverr),
	.start_counter(start_counter),
	.load(load),
	.up_down(up_down),
	.enable(enable),
	.clk_sel(clk_sel),
	.overflow(overflow),
	.underflow(underflow)
);

CPU CPU_i (
        .clk(clk),
        .rst_n(rst_n),

        .pready(pready),
        .prdata(prdata),
        .pslverr(pslverr),

        .psel(psel),
        .pwrite(pwrite),
        .penable(penable),
        .pwdata(pwdata),
        .paddr(paddr)
	
);

initial begin 
	clk  = 0;
	forever #5 clk = ~clk;
end 
initial  begin 
	f_out = $fopen ("output/tb_apb_controller_overflow_underflow_at_the_same_time.txt", "w");

	rst_n = 0;
	#50;
	@ (posedge clk);
	rst_n = 1;
	
	@ (posedge clk);
	overflow = 1;
	underflow = 1;
	
	// wirte all bit in reg	

	tb_apb_controller_overflow_underflow_at_the_same_time.CPU_i.READ(TSR, value, err); 
	if ((value != 3) | (err == 1)) begin
		$display ("run incorrectly\n");
		$fwrite (f_out, "FAIL\n");
		$fclose (f_out);
		$finish;
	end
	
	$display ("run correctly\n");
        $fwrite (f_out, "PASS\n");
        $fclose (f_out);
        #100;
        $finish;

end
endmodule 
