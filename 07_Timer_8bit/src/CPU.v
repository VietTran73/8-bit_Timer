`timescale 1ps/1ps

module CPU (
	input			clk,
	input			rst_n,

	output	reg		penable,
	output	reg		psel,
	output	reg		pwrite,
	output	reg	[7:0]	paddr,
	output	reg	[7:0]	pwdata,
	input		[7:0]	prdata,
	input			pready,
	input			pslverr
);

task WRITE;
	input 	[7:0] 	addr;
        input   [7:0]   data_in;
        
        begin
                @ (posedge clk);
                penable = 0;
                pwrite  = 0;
                psel    = 0;
                pwdata  = 0;
                paddr   = 0;
                @ (posedge clk);//setup
                pwrite  = 1;
                psel    = 1;
                pwdata  = data_in;
                paddr   = addr;
                @ (posedge clk);//access
                penable = 1;
                wait (pready == 1);
                if (pslverr == 0)
                        $display ("write %d to %d successfully\n", data_in, addr);
                else
                        $display ("write %d to %d unsuccessfully\n", data_in, addr);
                @ (posedge clk);
                penable = 0;
                pwrite  = 0;
                psel    = 0;
                pwdata  = 0;
                paddr   = 0;
        end
endtask

task WRITE_MASK;
	input 	[7:0] 	addr;
	input	[7:0]	data_in;
	input	[7:0]	mask_in;

	reg	[7:0]	reg_out;
	reg	[7:0]	tmp_1, tmp_2, tmp_3;
	reg		err;
	begin
		READ(addr, reg_out, err);
		tmp_1	= reg_out & ~mask_in;
		tmp_2	= data_in & mask_in;
		tmp_3	= tmp_1 | tmp_2;
		WRITE(addr, tmp_3);
	end
endtask

task READ;
        input   [7:0]   addr;
        output  [7:0]   data_out;
	output		err;
        begin
                @ (posedge clk);
                penable = 0;
                pwrite  = 0;
                psel    = 0;
                pwdata  = 0;
                paddr   = 0;
                @ (posedge clk);//setup
                psel    = 1;
                paddr   = addr;
                @ (posedge clk);//access
                penable = 1;
                wait (pready == 1);
                data_out= prdata;
		err	= pslverr;
                if (pslverr == 0)
                        $display ("read from %d successfully\n", addr);
                else
                        $display ("read from %d unsuccessfully\n", addr);
                @ (posedge clk);
                penable = 0;
                pwrite  = 0;
                psel    = 0;
                pwdata  = 0;
                paddr   = 0;
        end
endtask

endmodule
