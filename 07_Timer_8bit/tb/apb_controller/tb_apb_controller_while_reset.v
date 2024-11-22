`timescale 1ps/1ps 

module tb_apb_controller_while_reset ();


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
reg             underflow;

integer f_out;

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
	f_out = $fopen ("output/tb_apb_controller_while_reset.txt", "w");

	rst_n = 0;
	repeat (10) @ (posedge clk);
	if ((load != 0) | (start_counter != 0) | (up_down != 0) | (enable != 0) | (clk_sel != 0) | (prdata != 0) | (pready != 0) | (pslverr != 0))  
      	begin 
		$display ("run incorrectly\n");
                $fwrite (f_out, "FAIL\n");
		$fclose(f_out);
		$finish;
  	end
	if ((tb_apb_controller_while_reset.apb_controller_i.reg_TDR != 0) | (tb_apb_controller_while_reset.apb_controller_i.reg_TCR != 0) | (tb_apb_controller_while_reset.apb_controller_i.reg_TSR != 0)) 
	begin
                $display ("run incorrectly\n");
                $fwrite (f_out, "FAIL\n");
                $fclose(f_out);
                $finish;

	end
			
       	$display ("run correctly\n");
       	$fwrite (f_out, "PASS\n");
	$fclose(f_out);
	$finish;
end	
endmodule 
