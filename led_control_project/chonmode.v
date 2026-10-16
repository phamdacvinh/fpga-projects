
=================
module chiaxung(mode, clk, clkout);
input clk;
input [1:0] mode;
output reg clkout;
reg [24:0] count;
initial
	begin
	count <= 1;
	clkout <=0;
	end
always @(posedge clk)
	if(mode == 2'b00) 
		if(count == 125)
			begin
			count <= 1;
			clkout <= ~ clkout;
			end
		else count <= count + 1;
	else if(mode == 2'b01)
		if(count == 13)
			begin
			count <= 1;
			clkout <= ~ clkout;
			end
		else count <= count + 1;
	else if(mode == 2'b10)
		if(count == 5)
			begin
			count <= 1;
			clkout <= ~ clkout;
			end
		else count <= count + 1;
	else if(mode == 2'b11)
		if(count == 3)
			begin
			count <= 1;
			clkout <= ~ clkout;
			end
		else count <= count + 1;
endmodule
=======================================
module chonmode(
    input clk,
    input rst,
    input [1:0] mode,
    output reg [7:0] led
);

reg [1:0] mode_prev; // nhớ mode cũ

always @(posedge clk) 
begin
    if (rst) 
    begin
        led <= 8'b00000000;
        mode_prev <= 2'b11;   // ép khác mode đầu để buộc reset LED khi chạy
    end
    else 
	 begin
        // Khi đổi mode thì LED quay về trạng thái đầu tiên
        if (mode != mode_prev) 
        begin
            case(mode)
                2'b00: led <= 8'b00000000;   // bắt đầu từ 0 (đếm nhị phân)
                2'b01: led <= 8'b00000001;   // bắt đầu từ led0 sáng
                2'b10: led <= 8'b10000000;   // bắt đầu từ led7 sáng
                default: led <= 8'b00000000;
            endcase
            mode_prev <= mode;
        end
        else 
		  begin
            if(mode==2'b00) 
            begin
                if(led==8'b00111111) led <= led;
                else led <= led + 1;
            end
            else if(mode==2'b01) 
            begin
                if(led==8'b11111111) led <= led;
                else led <= (led << 1) | 1'b1;
            end
            else if(mode==2'b10) 
            begin
                if(led==8'b11111111) led <= led;
					 else if(led==8'b00000001) led <= 8'b11111111;
                else led <= led >> 1;
            end
        end
    end
end

endmodule
========================================
module dieukhienled(
input clk,rst,
input[1:0]mode,freq,
output[7:0] led);
wire daynoi;
chiaxung a1(.clk(clk),.mode(freq),.clkout(daynoi));
chonmode a2(.mode(mode),.clk(daynoi),.rst(rst),.led(led));
endmodule
==========
module test;

	// Inputs
	reg clk;
	reg rst;
	reg [1:0] mode;
	reg [1:0] freq;

	// Outputs
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	dieukhienled uut (
		.clk(clk), 
		.rst(rst), 
		.mode(mode), 
		.freq(freq), 
		.led(led)
	);
	initial begin
		forever #0.1 clk=~clk;
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		mode = 0;
		freq = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        rst  = 1;
        mode = 2'b00;
        freq = 2'b11;   // chọn tần số nhanh nhất để dễ thấy LED đổi
        #20;            // giữ reset 1 chút

        rst = 0;

        // --- Test Mode 00: Đếm nhị phân từ 0 -> 63 ---
        mode = 2'b00;
        #50;

        // --- Test Mode 01: Sáng dồn từ trái qua phải ---
        mode = 2'b01;
        #50;
		  
		  // --- Test Mode 10: Sáng dịch từ trái qua phải ---
        mode = 2'b10;
        #50;

        // --- Test Mode 11: không định nghĩa, LED giữ nguyên ---
        mode = 2'b11;
        #50;

    end
	endmodule