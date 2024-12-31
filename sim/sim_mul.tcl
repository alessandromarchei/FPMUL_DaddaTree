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
set rtl_files {
    half_adder.sv
    full_adder.sv
    dadda_tree_11.sv
    partial_gen_11.sv
    multiplier_11.sv
}

# Compile each RTL file
foreach file $rtl_files {
    vlog -work work "$src_dir/$file"
}

# Compile the selected testbench
vlog -work work "$tb_dir/tb_mul11.sv"

# Load the testbench
vsim -voptargs="+acc" work.tb_mul11

#set all the waves in decimal view
add wave -radix unsigned -color green sim:/tb_mul11/A
add wave -radix unsigned -color green sim:/tb_mul11/B
add wave -radix unsigned -color blue -label OUTPUT sim:/tb_mul11/PROD
add wave -radix unsigned -color red -label GROUND_TRUTH sim:/tb_mul11/exp_prod
add wave -radix unsigned -color white -label iteration sim:/tb_mul11/i


set runTime 10ns

# Run simulation
run $runTime

