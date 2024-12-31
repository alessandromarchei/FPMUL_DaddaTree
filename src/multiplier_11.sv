module multiplier_11 (
    input  logic [10:0] A_in,         
    input  logic [10:0] B_in,
    output logic [21:0] OUT
);


    //WIRE DECLARATIONS
    wire [21:0] part [5:0];     //vector of partial products
    wire [21:0] adds [1:0];   //outputs of the DADDA tree to feed the final adder


    //INSTANTIATION THE PARTIAL PRODUCT GENERATOR
    partial_gen_11 pp(
        .A(A_in),
        .B(B_in),
        .P0(part[0]),
        .P1(part[1]),
        .P2(part[2]),
        .P3(part[3]),
        .P4(part[4]),
        .P5(part[5])
    );

    //INSTANTIATION THE DADDA TREE
    dadda_tree_11 dadda(
        .pp(part),         
        .addends(adds)          
    );

    //FINAL ADDITION
    assign OUT = adds[1] + adds[0];

endmodule
