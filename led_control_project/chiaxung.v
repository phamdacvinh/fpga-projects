Chia xung 2 tần số
module chiaxung(mode, clk, clkout); 
    input clk; 
    input mode;
    output reg clkout; 
    reg [24:0] count;
	
    initial begin
        count  <= 1;
        clkout <= 0; 
    end

    always @(posedge clk) begin
        if (mode == 0) 
			begin
				if (count == 25_000_000) 
					begin
					count  <= 1;
					clkout <= ~clkout; 
					end 
				else count <= count + 1;
			end 
		else //mode == 1
			begin
				if (count == 12_500_000) 
					begin
					count  <= 1;
					clkout <= ~clkout; 
					end 
				else count <= count + 1;
			end
    end
endmodule
