/*=============================================*/
// Altera DE0 Top:
// NIOS II CPU + SDRAM
//	SpaceWire Shimafujigit
//
// Author: Tiago da Costa Rodrigues
// E-mail: tiagofee@gmail.com
/*=============================================*/


module SpW_JAXA_DE0(
		CLOCK,
		RESETn,
		////////////////////////	LED		////////////////////////
		LEDG,							//	LED Green[9:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0_D,							//	Seven Segment Digit 0
		HEX0_DP,						//	Seven Segment Digit DP 0
		HEX1_D,							//	Seven Segment Digit 1
		HEX1_DP,						//	Seven Segment Digit DP 1
		HEX2_D,							//	Seven Segment Digit 2
		HEX2_DP,						//	Seven Segment Digit DP 2
		HEX3_D,							//	Seven Segment Digit 3
		HEX3_DP,						//	Seven Segment Digit DP 3
		
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 13 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 1
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		Din, 
		Sin,
		Dout,
		Sout
);
input CLOCK;
input RESETn;
////////////////////////////	LED		////////////////////////////
output	[9:0]	LEDG;					//	LED Green[9:0]

////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output			HEX0_DP;				//	Seven Segment Digit DP 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output			HEX1_DP;				//	Seven Segment Digit DP 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 2
output			HEX2_DP;				//	Seven Segment Digit DP 2
output	[6:0]	HEX3_D;					//	Seven Segment Digit 3
output			HEX3_DP;				//	Seven Segment Digit DP 3

///////////////////////		SDRAM Interface	////////////////////////
inout		[15:0]		DRAM_DQ;				//	SDRAM Data bus 16 Bits
output	[12:0]		DRAM_ADDR;				//	SDRAM Address bus 13 Bits
output					DRAM_LDQM;				//	SDRAM Low-byte Data Mask
output					DRAM_UDQM;				//	SDRAM High-byte Data Mask
output					DRAM_WE_N;				//	SDRAM Write Enable
output					DRAM_CAS_N;				//	SDRAM Column Address Strobe
output					DRAM_RAS_N;				//	SDRAM Row Address Strobe
output					DRAM_CS_N;				//	SDRAM Chip Select
output					DRAM_BA_0;				//	SDRAM Bank Address 0
output					DRAM_BA_1;				//	SDRAM Bank Address 1
output					DRAM_CLK;				//	SDRAM Clock
output					DRAM_CKE;				//	SDRAM Clock Enable

input 					Din; 
input 					Sin;
output logic 			Dout;
output logic 			Sout;

logic 			TICK_OUT;
logic [7:0] 	TIME_OUT;
logic				TX_FULL;
logic				RX_EMPTY;
logic [8:0]		DATA_O;
logic [2:0] 	CURRENTSTATE;
logic  			LINK_START;
logic  			LINK_DISABLE;
logic  			AUTOSTART;
logic  [8:0]	DATA_I;
logic 			WR_DATA;
logic 			RD_DATA;
logic 			WR_DATA_p;
logic 			RD_DATA_p;
logic 			TICK_IN;
logic [7:0]		TIME_IN;
logic [6:0]		TX_CLK_DIV;
logic 			CLOCK_SPW;
logic				RESET_SPW;
logic 			CLOCK_NIOS;
logic				receiveClock;

//assign CLOCK_SPW = CLOCK_NIOS;

DE0_PLL TOP_PLL (
		.inclk0(CLOCK),	//clock in, 50 MHz
		.c0(DRAM_CLK),		//SDRAM clock , 50 MHz, phase -3
		.c1(CLOCK_NIOS),		// CPU CLK, 50 MHz
		.c2(CLOCK_SPW),		// 100 MHz
		.c3(receiveClock)			// 166.6 MHz
	);
	
CPU CPU_NIOS(
		.clk_clk(CLOCK_NIOS),             //          clk.clk
		.reset_reset_n(RESETn),       //        reset.reset_n
		.sdram_addr(DRAM_ADDR),          //        sdram.addr
		.sdram_ba({DRAM_BA_1,DRAM_BA_0}),            //             .ba
		.sdram_cas_n(DRAM_CAS_N),         //             .cas_n
		.sdram_cke(DRAM_CKE),           //             .cke
		.sdram_cs_n(DRAM_CS_N),          //             .cs_n
		.sdram_dq(DRAM_DQ),            //             .dq
		.sdram_dqm({DRAM_UDQM,DRAM_LDQM}),           //             .dqm
		.sdram_ras_n(DRAM_RAS_N),         //             .ras_n
		.sdram_we_n(DRAM_WE_N),          //             .we_n		
		
		.spw_tx_div_export(TX_CLK_DIV),   //   spw_tx_div.export
		.spw_config_export({LINK_DISABLE, AUTOSTART, LINK_START}),   //   spw_config.export
		.spw_tick_in_export(TICK_IN),  //  spw_tick_in.export
		.spw_time_in_export(TIME_IN),  //  spw_time_in.export
		.spw_reset_export(RESET_SPW),    //    spw_reset.export
		.spw_state_export(CURRENTSTATE),    //    spw_state.export
		.spw_tick_o_export(TICK_OUT),   //   spw_tick_o.export
		.spw_time_o_export(TIME_OUT),   //   spw_time_o.export
		.spw_data_i_export(DATA_O),   //   spw_data_i.export
		.spw_tx_full_export(TX_FULL),  //  spw_tx_full.export
		.spw_rx_empty_export(RX_EMPTY), // spw_rx_empty.export
		.spw_data_rd_export(RD_DATA),  //  spw_data_rd.export
		.spw_data_wr_export(WR_DATA),  //  spw_data_wr.export
		.spw_data_o_export(DATA_I),    //   spw_data_o.export
		.display7seg_export({HEX3_DP, HEX3_D,HEX2_DP, HEX2_D,HEX1_DP, HEX1_D, HEX0_DP, HEX0_D}),
		.led_export(LEDG)
		
	);

edge_detect EDGE_DET (.CLOCK(CLOCK_NIOS), .RESETn(RESETn), .wr(WR_DATA), .rd(RD_DATA),.wr_p(WR_DATA_p), .rd_p(RD_DATA_p));

SpaceWireCODECIP SPW_JAXA (
        .clock (CLOCK_NIOS),                       // in  std_logic;
        .transmitClock (CLOCK_SPW),               // in  std_logic;
        .receiveClock (receiveClock),                // in  std_logic;
        .reset (!RESET_SPW),                       // in  std_logic;
        .transmitFIFOWriteEnable (WR_DATA_p),     // in  std_logic;
        .transmitFIFODataIn (DATA_I),          // in  std_logic_vector(8 downto 0);
        .transmitFIFOFull (TX_FULL),            // out std_logic;
        .transmitFIFODataCount (),       // out std_logic_vector(5 downto 0);
        .receiveFIFOReadEnable (RD_DATA_p),       // in  std_logic;
        .receiveFIFODataOut (DATA_O),          // out std_logic_vector(8 downto 0);
        .receiveFIFOFull  (),            // out std_logic;
        .receiveFIFOEmpty (RX_EMPTY),            // out std_logic;
        .receiveFIFODataCount (),        // out std_logic_vector(5 downto 0);

        .tickIn (TICK_IN),                      // in  std_logic;
        .timeIn (TIME_IN[5:0]),                      // in  std_logic_vector(5 downto 0);
        .controlFlagsIn (TIME_IN[7:6]),              // in  std_logic_vector(1 downto 0);
        .tickOut (TICK_OUT),                     // out std_logic;
        .timeOut (TIME_OUT[5:0]),                     // out std_logic_vector(5 downto 0);
        .controlFlagsOut (TIME_OUT[7:6]),             // out std_logic_vector(1 downto 0);
		  
        .linkStart (LINK_START),                   // in  std_logic;
        .linkDisable (LINK_DISABLE),                 // in  std_logic;
        .autoStart (AUTOSTART),                   // in  std_logic;
        .linkStatus (),                  // out std_logic_vector(15 downto 0);
        .errorStatus (),                 // out std_logic_vector(7 downto 0);
        .transmitClockDivideValue (TX_CLK_DIV[5:0]),    // in  std_logic_vector(5 downto 0);
        .creditCount (),                 // out std_logic_vector(5 downto 0);
        .outstandingCount (),            // out std_logic_vector(5 downto 0);
        .transmitActivity (),            // out std_logic;
        .receiveActivity (),             // out std_logic;
        .spaceWireDataOut (Dout),            // out std_logic;
        .spaceWireStrobeOut (Sout),          // out std_logic;
        .spaceWireDataIn (Din),             // in  std_logic;
        .spaceWireStrobeIn (Sin),           // in  std_logic;       
        .statisticalInformationClear (1'b1), // in  std_logic;
        .statisticalInformation (),      // out bit32X8Array

        );


endmodule