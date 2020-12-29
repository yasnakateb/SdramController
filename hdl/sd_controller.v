module sd_controller(
    clk,
    reset,
    i_Read_Request,
    i_Write_Request,
    i_Read_Address,
    i_Write_Address,
    i_Read_Address,
    i_Write_Address,
    i_Write_Data,
    o_Read_Data,
    o_Read_Grant,
    o_Write_Grant,
    o_Data_Valid,
    o_Clk_Enable,
    o_Write_Enable,
    o_Data_Mask,
    o_Bank_Address,
    o_Address_10,
    o_Column_Address_Strobe,
    o_Row_Address_Strobe,
    io_DQ_Lines
    );

    parameter ADDRESS_SIZE = 20;
    parameter DATA_SIZE = 16;

    input clk;
    input reset;

    input i_Read_Request;
    input i_Write_Request;

    input [ADDRESS_SIZE - 1:0] i_Read_Address;
    input [ADDRESS_SIZE - 1:0] i_Write_Address;

    input [DATA_SIZE - 1:0] i_Write_Data;

    output reg [DATA_SIZE - 1:0] o_Read_Data;

    output o_Read_Grant;
    output o_Write_Grant;
    output o_Data_Valid;
    
    output o_Clk_Enable;
    output o_Write_Enable;

    output reg [1:0] o_Data_Mask;

    output reg o_Bank_Address;
    output reg [10:0] o_Address_10;

    output o_Column_Address_Strobe;
    output o_Row_Address_Strobe;

    inout [ADDRESS_SIZE - 1:0] io_DQ_Lines;

endmodule 