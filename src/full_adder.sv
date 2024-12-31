module full_adder (
    input  logic a, b, cin,   // Inputs: a, b, and carry-in
    output logic sum, cout    // Outputs: sum and carry-out
);

    // Sum is the XOR of a, b, and cin
    assign sum = a ^ b ^ cin;

    // Carry-out is true if any two or more inputs are true
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
