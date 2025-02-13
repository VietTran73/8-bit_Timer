`timescale 1ps/1ps 

module tb_apb_controller_clear_underflow_TSR ();

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

wire 		clr_overflow;
wire 		clr_underflow;

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
	.underflow(underflow),

	.clr_overflow(clr_overflow),
	.clr_underflow(clr_underflow)
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
	f_out = $fopen ("output/tb_apb_controller_clear_underflow_TSR.txt", "w");

	rst_n = 0;
	#50;
	@ (posedge clk);
	rst_n = 1;
	
	@ (posedge clk);
	wait (underflow == 1);
		
	// wirte all bit in reg	

	tb_apb_controller_clear_underflow_TSR.CPU_i.READ(TSR, value, err); 
	if ((value != 2) | (err == 1)) begin
		$display ("run incorrectly\n");
		$fwrite (f_out, "FAIL\n");
		$fclose (f_out);
		$finish;
	end
	
	tb_apb_controller_clear_underflow_TSR.CPU_i.WRITE_MASK(TSR, 8'hff, 8'h02); // note 
	if (clr_underflow != 1) begin 
		$display ("run incorrectly");
		$fwrite (f_out, "FAIL\n");
		$fclose (f_out);
		#100;
		$finish;
	end	

        tb_apb_controller_clear_underflow_TSR.CPU_i.READ(TSR, value, err);
        if ((value != 0) | (err == 1)) begin
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

initial begin  // this is block counter actively send signal
	overflow = 0;
	underflow = 0;

	wait (rst_n == 1);
	repeat (10) @ (posedge clk);
	underflow = 1;
	overflow = 0;
	
	wait (clr_underflow == 1);
	underflow = 0;
end
endmodule 
