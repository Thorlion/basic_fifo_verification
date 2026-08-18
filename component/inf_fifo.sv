`timescale 1ns/1ps
interface inf_fifo (
    input logic Clk,
    input logic Rst_N
);
    logic FClrN;  
    logic FInN;   //wr_en
    logic FOutN;  //rd_en
    logic [31:0] Data_In;

    logic [31:0] F_Data;
    logic F_EmptyN; 
    logic F_FirstN; // One word existence
    logic F_SLastN; // Two word left
    logic F_LastN;  // One word left
    logic F_FullN; 

    clocking driver_cb @(posedge Clk);
        default output #1;

        output Data_In;
        output FInN;
        output FOutN;
        output FClrN;
    endclocking

    clocking monitor_cb @(posedge Clk);
        default input #0;

        input  Data_In;
        input  FInN;
        input  FOutN;
        input FClrN;

        input F_Data;
        input F_EmptyN;
        input F_FirstN;
        input F_SLastN;
        input F_LastN;
        input F_FullN;

    endclocking

    modport monitor (
        clocking monitor_cb,
        input Clk, Rst_N, Data_In, FInN, FClrN, FOutN, F_Data, F_EmptyN, F_FirstN, F_SLastN, F_LastN, F_FullN 
    );

    modport driver (
        clocking driver_cb,
        input Clk, Rst_N, F_Data, F_EmptyN, F_FirstN, F_SLastN, F_LastN, F_FullN,
        output  Data_In, FInN, FClrN, FOutN
    );
endinterface