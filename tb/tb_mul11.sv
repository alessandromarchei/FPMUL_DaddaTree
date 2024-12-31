module tb_mul11 #(parameter NUM_TESTS = 1000);
    logic [10:0] A, B;
    wire [21:0] PROD;
    integer i, output_file;
    reg [21:0] exp_prod;

    multiplier_11 uut (
        .A_in(A),
        .B_in(B),
        .OUT(PROD)
    );

    initial begin
        output_file = $fopen("dadda_report.txt", "w");

        for (i = 0; i < NUM_TESTS; i++) begin
            // Randomize A and B values within the 11-bit range
            A = $random;
            B = $random;
            exp_prod = A * B;  // Expected product value
            #10;  // Wait time for product to stabilize

            // Check if the expected product matches the actual product
            if (exp_prod != PROD) begin
                $fwrite(output_file, "%d, %d, %d, %d !\n", A, B, exp_prod, PROD);
            end else begin
                $fwrite(output_file, "%d, %d, %d, %d\n", A, B, exp_prod, PROD);
            end
        end

        $fclose(output_file);
        //$finish;
    end
endmodule

