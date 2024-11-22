`timescale 1ps/1ps

module counter (
	input		clk,
	input		rst_n,
	input		clk_ena,

	input	[7:0]	start_counter,
	input		up_down,
	input		load,
	input		enable,

	input		clr_overflow,
	input		clr_underflow,

	output	reg	overflow,
	output	reg	underflow
);

reg	[7:0]		reg_TCNT;
reg	[7:0]		reg_TCNT_d1;
reg 			load_d1;

always @ (posedge clk) begin
	if (!rst_n) begin
		reg_TCNT			<= 0;
		overflow			<= 0;
		underflow			<= 0;
		reg_TCNT_d1			<= 0;
		load_d1				<= 0;
	end
	else begin
		if (load)
			reg_TCNT		<= start_counter;
		else if (enable & clk_ena) begin
			if (up_down)
				reg_TCNT	<= reg_TCNT + 1;
			else
				reg_TCNT	<= reg_TCNT - 1;
		end
		
		load_d1				<= load;
		reg_TCNT_d1			<= reg_TCNT;

		if (clr_overflow)
			overflow		<= 0;
		else if ((reg_TCNT == 0) & (reg_TCNT_d1 == 255) & !load_d1)
			overflow		<= 1;

		if (clr_underflow)
			underflow		<= 0;
		else if ((reg_TCNT == 255) & (reg_TCNT_d1 == 0) & !load_d1)
			underflow		<= 1;
	end
end

endmodule
