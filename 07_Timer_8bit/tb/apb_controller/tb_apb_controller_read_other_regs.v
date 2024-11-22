`timescale 1ps/1ps 

module tb_apb_controller_read_other_regs ();


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
reg 	err;
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
	f_out = $fopen ("output/tb_apb_controller_read_other_regs.txt", "w");

	rst_n = 0;
	#50;
	@ (posedge clk);
	rst_n = 1;
	
	@ (posedge clk);
	
	for (i=3;i<=255;i=i+1)
	begin
		tb_apb_controller_read_other_regs.CPU_i.READ(i, value, err);
		if ((value != 0) | (err == 0)) begin
			$display ("run incorrectly\n");
			$fwrite (f_out, "FAIL\n");
			$fclose (f_out);
			$finish;
		end
	end
	$display ("run correctly\n");
        $fwrite (f_out, "PASS\n");
        $fclose (f_out);
        #100;
        $finish;

end
endmodule 
