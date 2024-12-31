module tb_fpnew_top ();

   parameter fpnew_pkg::fpu_features_t       Features       = fpnew_pkg::RV16F;   
   parameter fpnew_pkg::fpu_implementation_t Implementation = fpnew_pkg::ISA_PIPE;
   parameter type                            TagType        = logic;
   localparam int unsigned WIDTH        = Features.Width;
   localparam int unsigned NUM_OPERANDS = 3;
   
   wire clk_i;
   wire rst_ni;
   wire [NUM_OPERANDS-1:0][WIDTH-1:0] operands_i;
   var fpnew_pkg::roundmode_e rnd_mode_i;
   var fpnew_pkg::operation_e op_i;
   var logic op_mod_i;
   var fpnew_pkg::fp_format_e src_fmt_i;
   var fpnew_pkg::fp_format_e dst_fmt_i;
   var fpnew_pkg::int_format_e int_fmt_i;
   var logic vectorial_op_i;
   var TagType tag_i;
   wire in_valid_i;
   wire in_ready_o;
   var logic flush_i;
   wire [WIDTH-1:0] result_o;
   wire 	    status_o_NV_;
   wire 	    status_o_DZ_;
   wire 	    status_o_OF_;
   wire 	    status_o_UF_;
   wire 	    status_o_NX_;
   wire tag_o;
   wire out_valid_o;
   var logic out_ready_i;
   wire busy_o;
   wire end_sim;

   assign rnd_mode_i = fpnew_pkg::RNE;
   assign op_i = fpnew_pkg::MUL;
   assign src_fmt_i = fpnew_pkg::FP16;
   assign dst_fmt_i = fpnew_pkg::FP16;
   assign int_fmt_i = fpnew_pkg::INT16;      
   assign vectorial_op_i = 0;
   assign tag_i = 0;
   assign flush_i = 0;
   assign op_mod_i = 0;
   assign out_ready_i = out_valid_o;
      		     
   clk_gen CG(.END_SIM(end_sim),
              .CLK(clk_i),
              .RST_n(rst_ni));

   data_gen16 DG(.CLK(clk_i),
	       .RST_n(rst_ni),
	       .D0(operands_i[0]),
	       .D1(operands_i[1]),
	       .D2(operands_i[2]),
	       .VOUT(in_valid_i),
	       .END_SIM(end_sim));  		       
	       
   fpnew_top UUT(
                 .clk_i,
                 .rst_ni,
		 .operands_i,
		 .rnd_mode_i,
		 .op_i,
		 .op_mod_i,
		 .src_fmt_i,
		 .dst_fmt_i,
		 .int_fmt_i,
		 .vectorial_op_i,
		 .tag_i,
		 .in_valid_i,
		 .in_ready_o,
		 .flush_i,
		 .result_o,
		 .status_o_NV_,
		 .status_o_DZ_,
		 .status_o_OF_, 
		 .status_o_UF_, 
		 .status_o_NX_,		 
		 .tag_o,
		 .out_valid_o,
		 .out_ready_i,
		 .busy_o);		 
   
endmodule
   
