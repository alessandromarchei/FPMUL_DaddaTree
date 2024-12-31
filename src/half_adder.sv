module half_adder (
    input  logic a, b,         // Inputs
    output logic sum, cout     // Outputs
);

    assign sum = a ^ b;         // Sum is the XOR of a and b
    assign cout = a & b;       // Carry is the AND of a and b

endmodule
