# Set the working directory
set work_dir "work"
set src_dir "../src"
set tb_dir "../tb"

# Create the work library if it does not exist
if {[file exists $work_dir]} {
    vdel -lib $work_dir -all
}
vlib $work_dir

# Compile the design files
vmap work $work_dir

# List of RTL files to compile
set dadda_src {
    half_adder.sv
    full_adder.sv
    dadda_tree_11.sv
    partial_gen_11.sv
    multiplier_11.sv
}

# Compile each file for the dadda multiplier
foreach file $dadda_src {
    vlog -work work "$src_dir/$file"
}

set fp_src {
    cf_math_pkg.sv
    lzc.sv
    rr_arb_tree.sv
    fpnew_pkg.sv
    fpnew_classifier.sv
    fpnew_rounding.sv
    fpnew_fma.sv
    fpnew_opgroup_fmt_slice.sv
    fpnew_opgroup_block.sv
    fpnew_top.sv


}
# Compile each RTL file
foreach file $fp_src {
    vlog -work work "$src_dir/$file"
}



#compile testbench

vcom -work work "$tb_dir/clk_gen.vhd"
vcom -work work "$tb_dir/data_gen16.vhd"
vlog -work work "$tb_dir/tb_fpnew_top_rtl.sv"


# Load the testbench
vsim -voptargs="+acc" work.tb_fpnew_top


# Adding waves
add wave *

set runTime 1000ns

# Run simulation
run $runTime

