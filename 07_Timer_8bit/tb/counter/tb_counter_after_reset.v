`timescale 1ps/1ps

module tb_counter_after_reset ();

reg          clk;
reg          rst_n;
reg          clk_ena;

reg  [7:0]   start_counter;
reg          up_down;
reg          load;
reg          enable;
reg 	     clr_overflow;
reg	     clr_underflow;

wire         overflow;
wire	     underflow;


integer f;
	
counter counter_i (
	.clk(clk),
	.rst_n(rst_n),
	.clk_ena(clk_ena),
	.start_counter(start_counter),
	.up_down(up_down),
	.load(load),
	.enable(enable),
	.clr_overflow(clr_overflow),
	.clr_underflow(clr_underflow),
	.overflow(overflow),
	.underflow(underflow)
		
);

initial begin 
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin 
	f = $fopen ("output/tb_counter_after_reset" , "w");
	rst_n = 0;	
	repeat (5) @ (posedge clk);
	rst_n = 1;
	
	if (tb_counter_after_reset.counter_i.reg_TCNT != 0)begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose (f);
                $finish;
		
	end
		
	if (overflow != 0 | underflow != 0) begin 
		$display ("run incorrectly\n");
		$fwrite (f, "FAIL\n");
		$fclose (f);
		$finish;
	end
	$display ("run correctly\n");
	$fwrite (f, "PASS\n");
        $fclose (f);
        $finish;

end
endmodule 




     


