
/* verilator lint_off UNOPTFLAT */
module reduce(
	input logic [63:0] P,
	output logic [31:0] PRE
);
	wire [47:0] fs,fc;	//wires for intermediate full adders & carry
	wire [7:0] hs,hc; 	//wires for intermediate half adder & carry
	
	//level 1 design	

	half_adder ha0(P[33],P[40],hs[0],hc[0]);
	
	half_adder ha1(P[20],P[27],hs[1],hc[1]);
	full_adder fa0(P[34],P[41],P[48],fs[0],fc[0]);

	full_adder fa2(P[42],P[49],P[56],fs[2],fc[2]);
	full_adder fa1(P[21],P[28],P[35],fs[1],fc[1]);
	half_adder ha2(P[7],P[14],hs[2],hc[2]);
	
	full_adder fa4(P[43],P[50],P[57],fs[4],fc[4]);
	full_adder fa3(P[22],P[29],P[36],fs[3],fc[3]);
	half_adder ha3(1'b0,P[15],hs[3],hc[3]);
	
	
	full_adder fa6(P[44],P[51],P[58],fs[6],fc[6]);
	full_adder fa5(P[23],P[30],P[37],fs[5],fc[5]);
	
	full_adder fa7(P[45],P[52],P[59],fs[7],fc[7]);

	//level 2 adders
	half_adder ha4(P[24],P[17],hs[4],hc[4]);
	
	half_adder ha5(P[4],P[11],hs[5],hc[5]);
	full_adder fa8(P[18],P[25],P[32],fs[8],fc[8]);

	full_adder fa9(hs[0],P[5],P[12],fs[9],fc[9]);
	full_adder fa10(P[19],P[26],1'b0,fs[10],fc[10]);

	full_adder fa11(fs[0],hc[0],hs[1],fs[11],fc[11]);
	full_adder fa12(P[6],1'b0,P[13],fs[12],fc[12]);

	full_adder fa13(fs[1],fc[0],fs[2],fs[13],fc[13]);
	full_adder fa14(hc[1],hs[2],1'b0,fs[14],fc[14]);
	
	full_adder fa15(fs[3],fc[1],fs[4],fs[15],fc[15]);
	full_adder fa16(fc[2],hs[3],hc[2],fs[16],fc[16]);

	full_adder fa17(fs[5],fc[3],fs[6],fs[17],fc[17]);
	full_adder fa18(fc[4],1'b0,hc[3],fs[18],fc[18]);

	full_adder fa19(1'b0,fc[5],P[31],fs[19],fc[19]);
	full_adder fa20(fc[6],fs[7],P[38],fs[20],fc[20]);

	full_adder fa21(1'b0,P[39],P[46],fs[21],fc[21]);
	full_adder fa22(P[53],P[60],fc[7],fs[22],fc[22]);

	full_adder fa23(P[47],P[54],P[61],fs[23],fc[23]);

	//level 3
	
	
	half_adder ha6(P[9],P[16],hs[6],hc[6]);
	
	full_adder fa24(1'b0,P[3],P[10],fs[24],fc[24]);
	full_adder fa25(hc[4],hs[5],1'b0,fs[25],fc[25]);
	full_adder fa26(fc[8],fs[10],hc[5],fs[26],fc[26]);
	
	full_adder fa27(fc[9],fs[12],fc[10],fs[27],fc[27]);
	full_adder fa28(fc[11],fs[14],fc[12],fs[28],fc[28]);
	full_adder fa29(fc[13],fs[16],fc[14],fs[29],fc[29]);
	full_adder fa30(fc[15],fs[18],fc[16],fs[30],fc[30]);
	full_adder fa31(fc[17],fs[20],fc[18],fs[31],fc[31]);
	full_adder fa32(fc[19],fs[22],fc[20],fs[32],fc[32]);
	full_adder fa33(fc[21],1'b0,fc[22],fs[33],fc[33]);
	full_adder fa34(1'b0,P[55],P[62],fs[34],fc[34]);
		
	// level 4
	
	half_adder ha7(P[1],P[8],PRE[1],PRE[18]);
	
	// M is unused for our 8x8 Dadda multiplier; replace with constant 0
	full_adder fa35(hs[6],1'b0,P[2],PRE[2],PRE[19]);
	
	full_adder fa36(fs[24],hc[6],hs[4],PRE[3],PRE[20]);
	full_adder fa37(fs[25],fc[24],fs[8],PRE[4],PRE[21]);
	full_adder fa38(fs[26],fc[25],fs[9],PRE[5],PRE[22]);
	full_adder fa39(fs[27],fc[26],fs[11],PRE[6],PRE[23]);
	full_adder fa40(fs[28],fc[27],fs[13],PRE[7],PRE[24]);
	full_adder fa41(fs[29],fc[28],fs[15],PRE[8],PRE[25]);
	full_adder fa42(fs[30],fc[29],fs[17],PRE[9],PRE[26]);
	full_adder fa43(fs[31],fc[30],fs[19],PRE[10],PRE[27]);
	full_adder fa44(fs[32],fc[31],fs[21],PRE[11],PRE[28]);
	full_adder fa45(fs[33],fc[32],fs[23],PRE[12],PRE[29]);
	full_adder fa46(fs[34],fc[33],fc[23],PRE[13],PRE[30]);
	full_adder fa47(1'b0,fc[34],P[63],PRE[14],PRE[31]);

	// Explicitly wire remaining/preferred LSB and unused outputs to avoid
	// accidentally dropping P[0][0]. The hand-wired reduction above omitted
	// bit 0 (and a couple of PRE bits); tie them here explicitly.
	assign PRE[0] = P[0];
	assign PRE[16] = 1'b0;
	assign PRE[17] = 1'b0;
	// Ensure top-most bit of PRE[0] is zero if not produced by the tree.
	assign PRE[15] = 1'b0;
endmodule

/* verilator lint_on UNOPTFLAT */