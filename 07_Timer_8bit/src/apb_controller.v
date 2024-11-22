`timescale 1ps/1ps

module apb_controller (
	input			clk,
	input			rst_n,
	input			psel,
	input			pwrite,
	input			penable,
	input	[7:0]		paddr,
	input	[7:0]		pwdata,
	output	reg [7:0]	prdata,
	output	reg 		pready,
	output	reg 		pslverr,

	output	[7:0]		start_counter,
	output			load,
	output			up_down,
	output			enable,
	output	[1:0]		clk_sel,
	input			overflow,
	input			underflow,
	output	reg		clr_overflow,
	output	reg		clr_underflow
);

//IDLE, SETUP, ACCESS
localparam		IDLE 	= 0,
			SETUP	= 1,
			ACCESS	= 2;

reg	[1:0]		state;//sequential logic
reg	[1:0]		next_state;//combinational logic
reg	[7:0]		reg_TDR, reg_TCR, reg_TSR;

always @ (*) begin
	case (state)
	IDLE: begin
		if (psel & !penable)
			next_state	= SETUP;
		else
			next_state	= IDLE;
	end
	SETUP: begin
		if (psel & penable)
			next_state	= ACCESS;
		else
                        next_state	= IDLE;
	end
	ACCESS:
		next_state		= IDLE;
	default:
		next_state		= IDLE;
	endcase
end

always @ (posedge clk) begin
	if (!rst_n)
		state			<= IDLE;
	else
		state			<= next_state;
end

//write
always @ (posedge clk) begin
	if (!rst_n) begin
		reg_TDR			<= 0;
		reg_TCR			<= 0;
		reg_TSR			<= 0;
		clr_overflow		<= 0;
		clr_underflow		<= 0;
	end
	else begin
		if ((state == ACCESS) & psel & penable & pwrite) begin//write by SW
			reg_TDR		<= (paddr == 0)? pwdata : reg_TDR;
                        reg_TCR         <= (paddr == 1)? pwdata & 8'hb3: reg_TCR;
		end
		else begin
                        reg_TDR         <= reg_TDR;
                        reg_TCR         <= reg_TCR;
		end

                if ((state == ACCESS) & psel & penable & pwrite) begin//write by SW
                        reg_TSR         <= (paddr == 2)? pwdata & 8'h00 : reg_TSR;
                end
                else begin
                        reg_TSR         <= {6'b0, underflow, overflow};
                end

		if ((state == ACCESS) & psel & penable & pwrite & (paddr == 2) & (pwdata[0] == 1))
			clr_overflow	<= 1;
		else
			clr_overflow	<= 0;

                if ((state == ACCESS) & psel & penable & pwrite & (paddr == 2) & (pwdata[1] == 1)) // note pwdata [1] == 1
                        clr_underflow    <= 1;
                else
                        clr_underflow    <= 0;
	end
end

//read
always @ (posedge clk) begin
	if (!rst_n)
		prdata			<= 0;
	else begin
		if ((state == ACCESS) & psel & penable & !pwrite) begin
			case (paddr)
			0: prdata	<= reg_TDR;
			1: prdata	<= reg_TCR;
                        2: prdata       <= reg_TSR;
			default: prdata	<= 0;
			endcase
		end
		else
			prdata		<= prdata;
	end
end

//ready, error
always @ (posedge clk) begin
	if (!rst_n) begin
		pready			<= 0;
		pslverr			<= 0;
	end
	else begin
		pready			<= (state == ACCESS);
		pslverr			<= (state == ACCESS) & psel & penable & (paddr > 2);
	end
end

assign	start_counter			= reg_TDR;
assign	load				= reg_TCR[7];
assign	up_down				= reg_TCR[5];
assign	enable				= reg_TCR[4];
assign	clk_sel				= reg_TCR[1:0];

endmodule
