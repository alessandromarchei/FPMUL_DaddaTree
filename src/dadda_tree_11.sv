module dadda_tree_11 (
    input  logic [21:0] pp [5:0],         // Inputs containing the partial products
    output logic [21:0] addends[1:0]          // 2 addends to feed the final adder
);

    wire [21:0] l3 [3:0];
    wire [21:0] l2 [2:0];
    wire [22:0] l1 [1:0];           //1 bit more to store the last carry bit -> discard it



//COMPRESSING 4TH LAYER -> 3TH LAYER (MAX 4 OPERANDS)

//HA0-3
generate
    genvar i;
    genvar j;


  for (i=6; i<=9; i=i+1) begin
    half_adder ha_i0 (
        .a(pp[0][i]),
        .b(pp[1][i]),
        .sum(l3[0][i]),
        .cout(l3[1][i+1])
    );
  end


   for (i=8; i<=9; i=i+1) begin
    full_adder fa_i0 (
        .a(pp[2][i]),
        .b(pp[3][i]),
        .cin(pp[4][i]),
        .sum(l3[2][i]),
        .cout(l3[3][i+1])
    );
  end


  for (i=10; i<=14; i=i+1) begin
    full_adder fa_i1 (
        .a(pp[0][i]),
        .b(pp[1][i]),
        .cin(pp[2][i]),
        .sum(l3[0][i]),
        .cout(l3[1][i+1])
    );
  end

  for (i=10; i<=14; i=i+1) begin
    full_adder fa_i2 (
        .a(pp[3][i]),
        .b(pp[4][i]),
        .cin(pp[5][i]),
        .sum(l3[2][i]),
        .cout(l3[3][i+1])
    );
  end


  //propagating from bit 0 to 5 onto next level

  //B0
    for (i=0; i<=5; i=i+1) begin
        for(j = 0; j <= 3; j = j+1) begin
            assign l3[j][i] = pp[j][i];
        end
    end
endgenerate

    full_adder fa_0 (
        .a(pp[1][15]),
        .b(pp[2][15]),
        .cin(pp[3][15]),
        .sum(l3[0][15]),
        .cout(l3[1][16])
    );


    full_adder fa_1 (
        .a(pp[2][16]),
        .b(pp[3][16]),
        .cin(pp[4][16]),
        .sum(l3[0][16]),
        .cout(l3[1][17])
    );

    half_adder ha4 (
        .a(pp[4][15]),
        .b(pp[5][15]),
        .sum(l3[2][15]),
        .cout(l3[3][16])
    );

    half_adder ha5 (
        .a(pp[2][17]),
        .b(pp[3][17]),
        .sum(l3[0][17]),
        .cout(l3[1][18])
    );


//propagating bits to next level

//B1
assign l3[1][6] = pp[2][6];
assign l3[2][6] = pp[3][6];
assign l3[3][6] = pp[4][6];


//B2
assign l3[2][7] = pp[2][7];
assign l3[3][7] = pp[3][7];

//B3
assign l3[3][8] = pp[5][8];

//B4
assign l3[0][21:18] = pp[5][21:18];

//B5
assign l3[2][17:16] = pp[5][17:16];

//B6
assign l3[3][18:17] = pp[4][18:17];

//B7
assign l3[1][21:19] = pp[4][21:19];

//B8
assign l3[2][19:18] = pp[3][19:18];

//FILLING THE NOT USED CELLS TO '0'
assign l3[3][21:19] = 3'b0;
assign l3[2][21:20] = 2'b0;

//COMPRESSING 3RD LAYER -> 2ND LAYER (MAX 3 OPERANDS)

//HA6-7
generate
  for (i=4; i<=5; i=i+1) begin
    half_adder ha_i1 (
        .a(l3[0][i]),
        .b(l3[1][i]),
        .sum(l2[0][i]),
        .cout(l2[1][i+1])
    );
  end

  for (i=6; i<=18; i=i+1) begin
    full_adder fa_i3 (
        .a(l3[0][i]),
        .b(l3[1][i]),
        .cin(l3[2][i]),
        .sum(l2[0][i]),
        .cout(l2[1][i+1])
    );
  end

  //B9
    for (i=0; i<=3; i=i+1) begin
        for(j = 0; j <= 2; j = j+1) begin
            assign l2[j][i] = l3[j][i];
        end
    end

endgenerate

half_adder ha_8 (
        .a(l3[0][19]),
        .b(l3[1][19]),
        .sum(l2[0][19]),
        .cout(l2[1][20])
    );

//propagating bits to next level
//B10
assign l2[1][4] = l3[2][4];
assign l2[2][4] = l3[3][4];

//B11
assign l2[2][5] = l3[2][5];

//B12
assign l2[2][18:6] = l3[3][18:6];

//B13
assign l2[2][19] = l3[2][19];

//B14
assign l2[0][21:20] = l3[0][21:20];

//B15
assign l2[1][21] = l3[1][21];

//B16
assign l2[2][20] = l3[1][20];

//FILLING THE NOT USED CELLS TO '0'
assign l2[2][21] = 1'b0;


//COMPRESSING 2ND LAYER -> 1ST LAYER (MAX 2 OPERANDS)
//HA 9-10
generate
  for (i=2; i<=3; i=i+1) begin
    half_adder ha_i2 (
        .a(l2[0][i]),
        .b(l2[1][i]),
        .sum(l1[0][i]),
        .cout(l1[1][i+1])
    );
  end

  for (i=4; i<=20; i=i+1) begin
    full_adder fa_i4 (
        .a(l2[0][i]),
        .b(l2[1][i]),
        .cin(l2[2][i]),
        .sum(l1[0][i]),
        .cout(l1[1][i+1])
    );
  end

  //B17
    for (i=0; i<=1; i=i+1) begin
        for(j = 0; j <= 1; j = j+1) begin
            assign l1[j][i] = l2[j][i];
        end
    end

endgenerate

half_adder ha_11 (
        .a(l2[0][21]),
        .b(l2[1][21]),
        .sum(l1[0][21]),
        .cout(l1[1][22])
    );

//propagating bits to next level
//B18
assign l1[1][2] = l2[2][2];

//FILLING THE NOT USED CELLS TO '0'
assign l1[0][22] = 1'b0;

//CONNECTING LEVEL 1 TO THE OUTPUT OF THE DADDA TREE
assign addends[1] = l1[1][21:0];
assign addends[0] = l1[0][21:0];

endmodule