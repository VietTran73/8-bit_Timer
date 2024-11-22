`timescale 1ps/1ps

module tb_counter_set_overflow_before_underflow_clk_1 ();

reg          	clk;
reg          	rst_n;
wire          	clk_ena;

reg  [7:0]   	start_counter;
reg          	up_down;
reg          	load;
reg          	enable;
reg 	     	clr_overflow;
reg	     	clr_underflow;

wire         	overflow;
wire	     	underflow;
reg	[3:0] 	cnt_clk, cnt_clk_d1, clk_ena_t;						

parameter 	HALF_PERIOD = 5;

integer 	i;		
integer 	f;
	
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
	cnt_clk[0] = 0;
	forever #(2*HALF_PERIOD) cnt_clk[0] = ~cnt_clk[0];		
end

initial begin
        cnt_clk[1] = 0;
        forever #(4*HALF_PERIOD) cnt_clk[1] = ~cnt_clk[1];
end

initial begin
        cnt_clk[2] = 0;
        forever #(8*HALF_PERIOD) cnt_clk[2] = ~cnt_clk[2];
end

initial begin
        cnt_clk[3] = 0;
        forever #(16*HALF_PERIOD) cnt_clk[3] = ~cnt_clk[3];
end

always @ (posedge clk) begin 
	cnt_clk_d1 <= cnt_clk;
	clk_ena_t    <= cnt_clk & ~cnt_clk_d1;			
end

assign clk_ena = clk_ena_t[1]; // láy cnt_clk[0] 

initial begin 
	f = $fopen("output/tb_counter_set_overflow_before_underflow_clk_1" , "w");
	rst_n = 0;	
	repeat (5) @ (posedge clk);
	rst_n = 1;
	
	if ((tb_counter_set_overflow_before_underflow_clk_1.counter_i.reg_TCNT != 0) | (overflow != 0) | (underflow != 0 )) begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                $finish;
		
	end
	
	start_counter = 0;
	load = 1;
	up_down = 1;
	enable = 1;
	@ (posedge clk );
	load = 0;
	repeat (256) @ (posedge clk_ena);
	@ (posedge clk);
	up_down = 0;
	
end

initial begin	
	wait (load == 1);
	wait (load == 0);
	
	for (i=1; i<=256; i=i+1) begin // 255 => 0
		@ (posedge clk_ena);
		if ((overflow != 0) | (underflow != 0)) begin 
			$display ("run incorrectly\n");
			$fwrite (f, "FAIL\n");
			$fclose(f);
			#30;
			$finish;
		end
	end

	@ (posedge clk);
	        if ((overflow != 0) | (underflow != 0)) begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                #30;
                $finish;
        end

	@ (posedge clk);
	#1;
	if ((overflow != 1) | (underflow != 0)) begin 
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                $finish;
	end

//        $display ("run correctly\n");
//        $fwrite (f, "PASS\n");
//        $fclose(f);
//        $finish;

end

initial begin
	wait (overflow == 1);
        @ (posedge clk_ena); // 0 => 255
        if ((overflow != 1) | (underflow != 0)) begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                #30;
                $finish;
        end
        @ (posedge clk);
                if ((overflow != 1) | (underflow != 0)) begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                #30;
                $finish;
        end

        @ (posedge clk);
	#1;
        if ((overflow != 1) | (underflow != 1)) begin
                $display ("run incorrectly\n");
                $fwrite (f, "FAIL\n");
                $fclose(f);
                $finish;
        end

	$display ("run correctly\n");
	$fwrite (f, "PASS\n");
        $fclose(f);
        $finish;

end

endmodule 




     


