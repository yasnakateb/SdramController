module sd_controller 
    #(
    parameter [2:0] CMD_LOADMODE  = 3'd0,
    parameter [2:0] CMD_REFRESH   = 3'd1,
    parameter [2:0] CMD_PRECHARGE = 3'd2,
    parameter [2:0] CMD_ACTIVE    = 3'd3,
    parameter [2:0] CMD_WRITE     = 3'd4,
    parameter [2:0] CMD_READ      = 3'd5,
    parameter [2:0] CMD_NOP       = 3'd7
    )
    (
    clk,
    i_Read_Request,
    i_Write_Request,
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


    localparam ADDRESS_SIZE = 20;
    localparam DATA_SIZE = 16;
    localparam TOTAL_READ_LATENCY = 4;  

    input clk;

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

    assign o_Clk_Enable = 1'b1;

    reg [2:0] r_Cmd = CMD_NOP;
    reg [1:0] r_State;
    reg r_Read_Select;
    reg [19:0] r_Address;
    reg [TOTAL_READ_LATENCY-1:0] r_Read_Data_Valid_Pipe;
    reg r_DQ_Lines;  
    reg [15:0] r_Write_Data_1;
    reg [15:0] r_Write_Data_2;

    wire w_Read_Now;
    wire w_Write_Now;
    wire w_Write_Select;
    wire w_Read_Cycle;
    wire [19:0] w_Address;
    wire w_Same_Row_And_Bank;

    initial  r_State=0;
    initial r_Read_Select=0; 
    initial r_Address=0;   
    initial r_DQ_Lines = 1'b0; 
    initial r_Write_Data_1=0;  
    initial r_Write_Data_2=0;   


    assign {o_Row_Address_Strobe, o_Column_Address_Strobe, o_Write_Enable} = r_Cmd;

    // Give priority to the requests
    assign w_Read_Now  =  i_Read_Request;  
    assign w_Write_Now = ~i_Read_Request & i_Write_Request;  

    
    always @(posedge clk) 
        if(r_State==2'h0) 
            r_Read_Select <= w_Read_Now;


    assign w_Write_Select = ~r_Read_Select;
    assign w_Read_Cycle = (r_State==2'h0) ? w_Read_Now : r_Read_Select;
    assign w_Address = w_Read_Cycle ? i_Read_Address : i_Write_Address;


    always @(posedge clk) 
        r_Address <= w_Address;


    assign w_Same_Row_And_Bank = (w_Address[19:8]==r_Address[19:8]);
    assign o_Read_Grant = (r_State==2'h0 &  w_Read_Now) | (r_State==2'h1 &  r_Read_Select & i_Read_Request & w_Same_Row_And_Bank);
    assign o_Write_Grant = (r_State==2'h0 & w_Write_Now) | (r_State==2'h1 & w_Write_Select & i_Write_Request & w_Same_Row_And_Bank);


    always @(posedge clk) begin
        case(r_State)
            2'h0: begin
                if(i_Read_Request | i_Write_Request) begin  
                    r_Cmd <= CMD_ACTIVE;  
                    o_Bank_Address <= w_Address[19];  
                    o_Address_10 <= w_Address[18:8]; 
                    o_Data_Mask <= 2'b11;
                    r_State <= 2'h1;
                end

                else begin
                    r_Cmd <= CMD_NOP;  
                    o_Bank_Address <= 0;
                    o_Address_10 <= 0;
                    o_Data_Mask <= 2'b11;
                    r_State <= 2'h0;
                end
            end

            2'h1: begin
                r_Cmd <= r_Read_Select ? CMD_READ : CMD_WRITE;
                o_Bank_Address <= r_Address[19];
                o_Address_10[9:0] <= {2'b00, r_Address[7:0]};  
                o_Address_10[10] <= 1'b0;  
                o_Data_Mask <= 2'b00;
                r_State <= (r_Read_Select ? i_Read_Request : i_Write_Request) & w_Same_Row_And_Bank ? 2'h1 : 2'h2;
            end

            2'h2: begin
                r_Cmd <= CMD_PRECHARGE;  
                o_Bank_Address <= 0;
                o_Address_10 <= 11'b100_0000_0000;  
                o_Data_Mask <= 2'b11;
                r_State <= 2'h0;
            end

            2'h3: begin
                r_Cmd <= CMD_NOP;
                o_Bank_Address <= 0;
                o_Address_10 <= 0;
                o_Data_Mask <= 2'b11;
                r_State <= 2'h0;
            end

        endcase 
    end 


    always @(posedge clk) 
        r_Read_Data_Valid_Pipe <= {r_Read_Data_Valid_Pipe[TOTAL_READ_LATENCY-2:0], r_State==2'h1 & r_Read_Select};


    assign o_Read_DataValid = r_Read_Data_Valid_Pipe[TOTAL_READ_LATENCY-1];


    always @(posedge clk) begin
        o_Read_Data <= io_DQ_Lines;
        r_DQ_Lines <= (r_State==2'h1) & w_Write_Select;
        r_Write_Data_1 <= i_Write_Data;
        r_Write_Data_2 <= r_Write_Data_1;
    end 


    assign io_DQ_Lines = r_DQ_Lines ? r_Write_Data_2 : 16'hZZZZ;

endmodule 