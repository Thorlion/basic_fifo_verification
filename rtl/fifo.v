//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// $$$$  SYNTHESIZABLE FIFO MODEL   $$$                                                  //
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
// - The FIFO bits can be modified by changing the value of FDEPTH                       //
// - For this particular example, the DEPTH is 4                                         //
// - The Inputs of the FIFO are: Clk, RstN, Data_In, FinN, FClrN, FoutN                  //
// - The outputs of the FIFO are: F_Data, F_FullN, F_EmptyN, F_LastN, F_SLastN, F_FirstN //
// - Author: Zeeshan Ahmed								 //
// - Date: 5-29-2011									 //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


`define FWIDTH 32   // Width of the FIFO.
`define FDEPTH 4    // Depth of the FIFO.
`define FCWIDTH 2   // Counter Width of the FIFO 2 to power 
                    // FCWIDTH = FDEPTH
`define zero  1`b0
`define one   1`b1

module fifo ( Clk,
RstN,
Data_In,
FClrN,
FInN,
FOutN,

F_Data,
F_FullN,
F_LastN,
F_SLastN,
F_FirstN,
F_EmptyN

) ;

input                  Clk;		// CLK signal.
input                  RstN; 		// Low Asserted Reset signal.
input [(`FWIDTH-1):0]  Data_In; 	// Data into FIFO.
input                  FInN;            // Write into FIFO Signal.
input                  FClrN;           // Clear signal to FIFO.
input                  FOutN;           // Read from FIFO signal.

output [(`FWIDTH-1):0] F_Data;          // FIFO data out.
output                 F_FullN;         // FIFO full indicating signal.
output                 F_EmptyN;        // FIFO empty indicating signal.
output                 F_LastN;         // FIFO Last but one signal.
output                 F_SLastN;        // FIFO SLast but one signal.
output                 F_FirstN;        // Signal indicating one word.

reg                    F_FullN;
reg                    F_EmptyN;
reg                    F_LastN;
reg                    F_SLastN;
reg                    F_FirstN;

reg [(`FWIDTH-1):0]     fcounter; // counter indicates num of data in FlFO
reg [(`FWIDTH-1):0]     rd_ptr;   // Current read pointer.

reg [(`FWIDTH-1):0]     wr_ptr;  // Current write pointer.

wire [(`FWIDTH-1):0] FIFODataOut; // Data out from FIFO MemBlk
wire [(`FWIDTH-1):0] FIFODataIn;  // Data into FIFO MemBlk

wire ReadN = FOutN;
wire WriteN = FInN;

assign F_Data = FIFODataOut;
assign FIFODataIn = Data_In;

FIFO_MEM_BLK memblk(
	.clk(Clk),
	.writeN(WriteN),
	.rd_addr(rd_ptr),
	.wr_addr(wr_ptr),
	.data_in (FIFODataIn),
	.data_out(FIFODataOut)
);

/***********************************************************************************/
// $$$$ Control Circuitry for FIFO $$$$                                             /
// - IF RstN is asserted, The fcounter, rd_ptr and wr_ptr will be zero              /
// - If WriteN is asserted, the Write Pointer will be incremented                   /
// - If ReadN, the Read Pointer will be incremented                                 /
// - If both ReadN and WriteN, both the read and write counters will increment      /
// - The fcounter is maintaining the number of items in the FIFO. Whenever there    / 
//   is a write into the FIFO Memory, the fcounter will increment and whenever      /
//   there is a read from the FIFO memory, the fcounter will decrement              /
/***********************************************************************************/
/***********************************************************************************/

always @(posedge Clk or negedge RstN)
 begin

/******************************************************************/
/* Reset the fcounter, rd_pointer and wr_ptr if Reset is asserted */
/******************************************************************/
if (!RstN) begin
  	fcounter <= 0;
	rd_ptr <= 0;
	wr_ptr <= 0;
end
else begin
/******************************************************************/
/* If FClrN is asserted, rd_ptr, wr_ptr and fcounter is resetted  */
/******************************************************************/
if (~FClrN ) begin
	fcounter <= 0;
	rd_ptr <= 0;
	wr_ptr <= 0; 
end
/******************************************************************/
/* If WriteN is asserted, Increment the Write Pointer             */
/******************************************************************/

else begin
    if (~WriteN)
	wr_ptr <= wr_ptr + 1;
/******************************************************************/
/* If ReadN  is asserted, Increment the Read  Pointer             */
/******************************************************************/

    if (~ReadN)
	rd_ptr <= rd_ptr + 1;
/************************************************************************************/
/* If WriteN is asserted, and no ReadN and FIFO is not Full, Increment the fcounter */
/************************************************************************************/

    if (~WriteN && ReadN && F_FullN)
	fcounter <= fcounter +1 ;

/*************************************************************************************/
/* If ReadN is asserted, and no WriteN and FIFO is not Empty, Decrement the fcounter */
/*************************************************************************************/
    else if(WriteN && ~ReadN && F_EmptyN)
	fcounter <= fcounter - 1;
	end
	end
end

/******************************************************************/
/*  $$$ FIFO STATUS SIGNALS $$$                                   */
/* - All the FIFO status signals are dependent on fcounter value  */
/* - If the fcounter is equal to "afdepth", FIFO is FULL          */
/* - If the fcounter is equal to zero, FIFO is EMPTY              */
/* - F_EmptyN signal indicates FIFO EMPTY status. By default, it is
     asserted, indicating the FIFO is empty. After the first data is
     written into the FIFO, the F_EmptyN is deasserted            */
/******************************************************************/

always @(posedge Clk or negedge RstN)
begin
if (!RstN)
	F_EmptyN <= 1'b0 ;

else begin
        if(FClrN==1'b1) begin

	    if(F_EmptyN==1'b0 && WriteN==1'b0)
		F_EmptyN <=  1'b1;

             else if(F_FirstN==1'b0 && ReadN==1'b0 && WriteN==1'b1)

		F_EmptyN <= 1'b0;
		end
		else
		F_EmptyN <= 1'b0;
	end
end

/********************************************************************/
/* If F_FirstN signal indicates that there is only 1'b1 datum sitting
   in the FIF0. When the FIFO is empty and a write to FIFO occurs,
   this signal gets asserted */
/********************************************************************/
always @(posedge Clk or negedge RstN)
begin

	if (!RstN)
	F_FirstN <= 1'b1;

	else begin
	if (FClrN==1'b1) begin

	if((F_EmptyN==1'b0 && WriteN==1'b0) ||	(fcounter==2 && ReadN==1'b0 && WriteN==1'b1))

	F_FirstN <= 1'b0;
	
	else if (F_FirstN==1'b0 && (WriteN ^ ReadN))
	F_FirstN <= 1'b0;
	end

	else begin
	
	F_FirstN <= 1'b1;
	end
     end
end

/************************************************************************************/
/* F_SLastN indicates that there is space for only two data words in       the FIFO */
/************************************************************************************/

always @(posedge Clk or negedge RstN) begin

	if( !RstN)
	F_SLastN <= 1'b1;

   else begin

	if (FClrN==1'b1) 
        begin
	
        if( (F_LastN==1'b0 && ReadN==1'b0 && WriteN==1'b1) || (fcounter == (`FDEPTH-3) && WriteN==1'b0 && ReadN==1'b1))

	F_SLastN <= 1'b0;
        else if(F_SLastN==1'b0 && (ReadN ^ WriteN))
        F_SLastN <= 1'b1;

	end
	else
	F_SLastN <= 1'b1;
    end
end

/********************************************************************************/
/* F_LastN indicates that there is one space for only one data word in the FIFO */
/********************************************************************************/

always @(posedge Clk or negedge RstN) begin

	if (!RstN)
	F_LastN <= 1'b1;

	else begin
	if(FClrN==1'b1) begin

	if ((F_FullN==1'b0 && ReadN==1'b0) ||
	(fcounter== (`FDEPTH-2) && WriteN==1'b0 && ReadN==1'b1))

	F_LastN <= 1'b0;
	
	else if(F_LastN==1'b0 && (ReadN ^ WriteN))
	F_LastN 	<= 1'b1;
    end
    else	
    F_LastN <= 1'b1;
   end
end

/*********************************************************************/
/* F_FullN indicates that the FIF0 is full                           */
/*********************************************************************/

always @(posedge Clk or negedge RstN) begin

	if( !RstN)
	F_FullN <= 1'b1;

	else begin
	if(FClrN==1'b1) begin
	
	if (F_LastN==1'b0 && WriteN==1'b0 && ReadN==1'b1)
	F_FullN <= 1'b0;

	else if(F_FullN==1'b0 && ReadN==1'b0)
	F_FullN <= 1'b1;
	end

	else
	F_FullN <= 1'b1;
    end
end

endmodule

/***************************************************************/
/* Configurable memory block for fifo                          */
/* The width of the item block is configured via FWIDTH        */
/* All the data into fifo is done synchronous to block         */
/* Author: Zeeshan Ahmed                                       */
/* Date: 5/29/2011                                             */
/***************************************************************/

module FIFO_MEM_BLK( clk,
writeN,
wr_addr,
rd_addr,
data_in,
data_out
);

input clk; // input clk

input writeN;                   //Write Signalto putdata into fifo.
input [(`FWIDTH-1):0] wr_addr;  // Write Address.
input [(`FWIDTH-1):0] rd_addr;  // Read Address.
input [(`FWIDTH-1):0] data_in; // Dataln in to Memory Block
output [(`FWIDTH-1):0] data_out ; // Data Out from the Memory
						// Block(FIFO)
wire [(`FWIDTH-1):0] data_out;

reg [(`FWIDTH-1):0] FIFO[0:(`FDEPTH-1)];

assign data_out = FIFO[rd_addr];
always @(posedge clk)
begin
if (writeN==1'b0)
FIFO[wr_addr] <= data_in;
end
endmodule 
