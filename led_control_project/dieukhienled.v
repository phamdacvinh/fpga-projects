module testbench;

	// Inputs
	reg clk;
	reg rst;
	reg freq;
	reg start;
	reg [1:0] mode;

	// Outputs
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	dieukhienled uut (
		.clk(clk), 
		.rst(rst), 
		.freq(freq), 
		.start(start), 
		.mode(mode), 
		.led(led)
	);
	initial begin
		forever #0.1 clk=~clk;
	end
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		freq = 0;
		start = 0;
		mode = 0;
		#50;
      
		// Add stimulus here
		rst  = 1;
      mode = 2'b00;
      freq = 1;
		start = 1;
      #50;          
      rst = 0;
		
		mode = 2'b00;
		#100;
		
		mode = 2'b01;
		#100;
		
		mode = 2'b10;
		#100;
		
		mode = 2'b11;
		#100;
		freq = 0;
		
	end
      
endmodule

/////////////////////////////////////////////////

module dieukhienled(
input clk,rst,freq,start,
input[1:0]mode,
output[7:0] led);
wire daynoi;
chiaxung a1(.clk(clk),.mode(freq),.clkout(daynoi));
chonmode a2(.mode(mode),.clk(daynoi),.start(start),.rst(rst),.led(led));
endmodule

//////////////////////////////////////////////////

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
				if (count == 2) 
					begin
					count  <= 1;
					clkout <= ~clkout; 
					end 
				else count <= count + 1;
			end 
		else //mode == 1
			begin
				if (count == 5) 
					begin
					count  <= 1;
					clkout <= ~clkout; 
					end 
				else count <= count + 1;
			end
    end
endmodule

//////////////////////////////////////////

module chonmode(
    input clk,
    input rst,
    input start,
    input [1:0] mode,
    output reg [7:0] led
);

reg [1:0] mode_prev;
reg [4:0] step;         
reg [1:0] cycle_cnt;   
always @(posedge clk) 
begin
    if (rst) 
    begin
        led <= 8'b00000000;
        mode_prev <= 2'bxx;
        step <= 0;
        cycle_cnt <= 0;
    end
	 else if (start) 
    begin
        if (mode != mode_prev) 
		  begin
            case(mode)
                2'b00: led <= 8'b00000000;  // MODE 1
                2'b01: led <= 8'b10101010;  // MODE 2
                2'b10: led <= 8'b11111111;  // MODE 3
                2'b11: led <= 8'b00000000;  // MODE 4
            endcase
            step <= 0;
            cycle_cnt <= 0;
				mode_prev <= mode;
        end
		  else 
        begin
            // ---------------- MODE 1 ----------------
            if(mode==2'b00) 
            begin
                if (cycle_cnt < 2) 
                begin
                    if (step < 8) 
						  begin
                        led <= led | (8'b10000000 >> step);
                        step <= step + 1;
                    end
                    else if (step < 16) 
						  begin
                        led <= led & ~(8'b00000001 << (step - 8));
                        step <= step + 1;
                    end
                    else 
                    begin
                        step <= 0;
                        cycle_cnt <= cycle_cnt + 1;
						  end
                end
            end

            // ---------------- MODE 2 ----------------
				 else if(mode==2'b01) 
            begin
                if (led == 8'b10101010) 
                    led <= 8'b01010101;
                else 
                    led <= 8'b10101010;
            end
				// ---------------- MODE 3 ----------------
				else if (mode == 2'b10) 
				begin
					 if (step < 9) 
					 begin
						  led <= 8'b11111111 >> step;
						  step <= step + 1;
					 end
					 else 
					 begin
						  led <= 8'b11111111;
						  step <= step;
					 end
				end
				// ---------------- MODE 4 ----------------
            else if (mode == 2'b11) 
            begin
                case (step)
                    0: led <= 8'b00000000;
                    1: led <= 8'b10000001;
                    2: led <= 8'b11000011;
                    3: led <= 8'b11100111;
						  4: led <= 8'b11111111;
                endcase

                if (step < 4)
                    step <= step + 1;
                else
                    step <= 0;
            end
        end
    end
    else 
    begin
        led <= led; // giữ nguyên khi start = 0
    end
end
endmodule

///////////////////////////////////

module top(
    input  wire clk,
    input  wire rst,
    input  wire freq, 
    input  wire start,
    input  wire [1:0] mode,
    output wire [7:0] led,
	 output wire lcd_rs,
    output wire lcd_rw,
    output wire lcd_e,
    output wire lcd_4,
    output wire lcd_5,
    output wire lcd_6,
    output wire lcd_7
);
	 // Gọi module LCDtest
    LCDtest u_lcd (
        .clk(clk),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_e(lcd_e),
        .lcd_4(lcd_4),
        .lcd_5(lcd_5),
        .lcd_6(lcd_6),
        .lcd_7(lcd_7)
    );
	 // Gọi module dieukhienled
    dieukhienled u_led (
        .clk(clk),
        .rst(rst),
        .freq(freq),
        .start(start),
        .mode(mode),
        .led(led)
    );

endmodule

////////////////////////////////////////////////

module LCDtest(
    input wire clk,
    output wire lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7
);
    wire [255:0] chars; 
    reg blink;
    reg [24:0] blink_cnt;
	 
    LCD lcd(
        clk,
        chars,
        lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7
		   );

    assign chars[255:128] = "PHAM DAC VINH   "; 
    assign chars[127:8]   = "23161363        ";
    assign chars[7:0]     = (blink) ? ">" : " ";


	 always @(posedge clk) begin
        if (blink_cnt == 12_000_000) begin 
            blink_cnt <= 0;
            blink <= ~blink;
        end else begin
            blink_cnt <= blink_cnt + 1;
        end
    end

endmodule

/////////////////////////////////////////////

module LCD(
    clk,
    chars,
    lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7
);
    input clk;
    input [256:0] chars;

    output lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7;

    wire [256:0] chars;
    reg lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7;
    reg [5:0] lcd_code;
    reg [1:0] write = 2'b10; 
	 // delays
    reg [1:0] before_delay = 3;      // time before on
    reg [3:0] on_delay     = 13;     // time on
    reg [23:0] off_delay   = 750_001; // time off

    // states and counters
    reg [6:0] Cs = 0;
    reg [19:0] count = 0;
    reg [1:0] delay_state = 0;

    // character data
    reg [256:0] chars_hold = " ";
    wire [3:0] chars_data [63:0]; // array of characters
	 // redirects characters data to an array
    generate
        genvar i;
        for (i = 64; i > 0; i = i - 1)
        begin : for_name
            assign chars_data[64 - i] = chars_hold[i*4 - 1 : i*4 - 4];
        end
    endgenerate

    always @ (posedge clk) begin
        // store character data
        if (Cs == 10 && count == 0) begin
            chars_hold <= chars;
        end
		  // set time when enable is off
        if (Cs < 3) begin
            case (Cs)
                0: off_delay <= 750_001; // 15ms delay
                1: off_delay <= 250_001; // 5ms delay
                2: off_delay <= 5_001;   // 0.1ms delay
            endcase
        end else begin
            if (Cs > 12) begin
                off_delay <= 2_001; // 40us delay
            end else begin
                off_delay <= 250_001; // 5ms delay
            end
        end
		  if (Cs < 80) begin
            case (delay_state)
                0: begin
                    // enable is off
                    lcd_e <= 0;
                    {lcd_rs, lcd_rw, lcd_7, lcd_6, lcd_5, lcd_4} <= lcd_code;
                    if (count == off_delay) begin
                        count <= 0;
                        delay_state <= delay_state + 1;
                    end else begin
                        count <= count + 1;
                    end
                end
					 1: begin
                    // data set before enable is on
                    lcd_e <= 0;
                    if (count == before_delay) begin
                        count <= 0;
                        delay_state <= delay_state + 1;
                    end else begin
                        count <= count + 1;
                    end
                end

                2: begin
                    // enable on
                    lcd_e <= 1;
						  if (count == on_delay) begin
                        count <= 0;
                        delay_state <= delay_state + 1;
                    end else begin
                        count <= count + 1;
                    end
                end

                3: begin
                    // enable off with data set
                    lcd_e <= 0;
                    if (count == before_delay) begin
                        count <= 0;
								delay_state <= 0;
                        Cs <= Cs + 1; // next case
                    end else begin
                        count <= count + 1;
                    end
                end
            endcase
        end
		  if (Cs < 12) begin
            // initialize LCD
            case (Cs)
                0:  lcd_code <= 6'h03; // power-on initialization
                1:  lcd_code <= 6'h03;
                2:  lcd_code <= 6'h03;
                3:  lcd_code <= 6'h02;
                4:  lcd_code <= 6'h02; // function set
                5:  lcd_code <= 6'h08;
                6:  lcd_code <= 6'h00; // entry mode set
                7:  lcd_code <= 6'h06;
                8:  lcd_code <= 6'h00;
					 9:  lcd_code <= 6'h0C;
                10: lcd_code <= 6'h00; // display clear
                11: lcd_code <= 6'h01;
                default: lcd_code <= 6'h10;
            endcase
        end else begin
		  if (Cs == 44) begin
                // change address at end of first line
                lcd_code <= {2'b00, 4'b1100}; // 0100 0000 address change
            end else if (Cs == 45) begin
                lcd_code <= {2'b00, 4'b0000};
            end else begin
                if (Cs < 44) begin
                    lcd_code <= {write, chars_data[Cs - 12]};
					 end else begin
                    lcd_code <= {write, chars_data[Cs - 14]};
                end
            end
        end

        // hold and loop back
        if (Cs == 80) begin
            lcd_e <= 0;
            if (count == off_delay) begin
                Cs <= 10;
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

/////////////////////////////////////////////////////////

NET "clk" LOC = "C9" | IOSTANDARD = LVCMOS33 ;

NET "led<0>" LOC = "F12" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<1>" LOC = "E12" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<2>" LOC = "E11" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<3>" LOC = "F11" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<4>" LOC = "C11" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<5>" LOC = "D11" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<6>" LOC = "E9" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;
NET "led<7>" LOC = "F9" | IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 8 ;

NET "mode<0>" LOC = "L13" | IOSTANDARD = LVTTL | PULLUP;
NET "mode<1>" LOC = "L14" | IOSTANDARD = LVTTL | PULLUP;
NET "start" LOC = "H18" | IOSTANDARD = LVTTL | PULLUP;
NET "freq" LOC = "N17" | IOSTANDARD = LVTTL | PULLUP;

NET "rst" LOC = "V4" | IOSTANDARD = LVTTL | PULLDOWN;

NET "lcd_e"  LOC = M18 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_rs" LOC = L18 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_rw" LOC = L17 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_4" LOC = R15 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_5" LOC = R16 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_6" LOC = P17 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;
NET "lcd_7" LOC = M15 | IOSTANDARD = LVCMOS33 | DRIVE = 4 | SLEW = SLOW ;