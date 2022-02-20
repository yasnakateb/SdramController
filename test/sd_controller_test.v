`timescale 1ns / 1ps

module sd_controller_test();

    // Inputs
    reg clk;
    reg i_Read_Request;
    reg i_Write_Request;
    reg [19:0] i_Read_Address;
    reg [19:0] i_Write_Address;
    reg [15:0] i_Write_Data;

    // Outputs
    wire [15:0] o_Read_Data;
    wire o_Read_Grant;
    wire o_Write_Grant;
    wire o_Data_Valid;
    wire o_Clk_Enable;
    wire o_Write_Enable;
    wire [1:0] o_Data_Mask;
    wire o_Bank_Address;
    wire [10:0] o_Address_10;
    wire o_Column_Address_Strobe;
    wire o_Row_Address_Strobe;

    // Bidirs
    wire [19:0] io_DQ_Lines;

    sd_controller uut (
        .clk(clk), 
        .i_Read_Request(i_Read_Request), 
        .i_Write_Request(i_Write_Request), 
        .i_Read_Address(i_Read_Address), 
        .i_Write_Address(i_Write_Address), 
        .i_Write_Data(i_Write_Data), 
        .o_Read_Data(o_Read_Data), 
        .o_Read_Grant(o_Read_Grant), 
        .o_Write_Grant(o_Write_Grant), 
        .o_Data_Valid(o_Data_Valid), 
        .o_Clk_Enable(o_Clk_Enable), 
        .o_Write_Enable(o_Write_Enable), 
        .o_Data_Mask(o_Data_Mask), 
        .o_Bank_Address(o_Bank_Address), 
        .o_Address_10(o_Address_10), 
        .o_Column_Address_Strobe(o_Column_Address_Strobe), 
        .o_Row_Address_Strobe(o_Row_Address_Strobe), 
        .io_DQ_Lines(io_DQ_Lines)
    );

    always #1 
        clk =~clk;

    initial begin
        $dumpfile("sd_controller_test.vcd");
        $dumpvars(0,sd_controller_test);
        
        clk = 0;
        i_Read_Request = 0;
        i_Write_Request = 0;
        i_Read_Address = 0;
        i_Write_Address = 0;
        i_Write_Data = 0;

        #100;
        i_Read_Request = 0;
        i_Write_Request = 1;
        i_Read_Address = 0;
        i_Write_Address = 1;
        i_Write_Data = 12;
        
        #100;
        clk = 1;
        i_Read_Request = 1;
        i_Write_Request = 0;
        i_Read_Address = 1;
        
    end
      
endmodule