#======================================================================
#                    GENUS SYNTHESIS FLOW
#                    PROJECT : PINAKA
#======================================================================


set DESIGN_NAME "pinaka"
set GEN_EFF high
set MAP_EFF high
set OPT_EFF high
 
set_db tns_opt true


set DATE [clock format [clock seconds] -format "%b%d-%T"] 

set REPORT_DIR  "./reports"

# Create directories if they don't exist
file mkdir $REPORT_DIR
file mkdir "$REPORT_DIR/pre_synth"
file mkdir "$REPORT_DIR/post_synth"


#======================================================================
# 1. Technology / Library setup
#======================================================================

set_db / .init_lib_search_path {.} 
set_db / .init_hdl_search_path {.} 

set_db / .lp_insert_clock_gating true 
set_db / .information_level 10

#set_db max_cpus_per_server  16
set_db super_thread_servers localhost

read_libs /home/train41/Desktop/Adarsh/tcbn65lpwc.lib
#======================================================================
# 2. RTL file list and Read RTL
#====================================================================== 

source /home/train41/Desktop/Adarsh/26August_Synth_trial/rtl_flist.tcl

#======================================================================
# 4. Elaborate
#======================================================================
puts "========================================"
puts "ELABORATION START"
puts "========================================"

set elab_start [clock seconds]

elaborate $DESIGN_NAME

set elab_end [clock seconds]

puts "========================================"
puts "ELABORATION END"
puts "ELABORATION RUNTIME = [expr {$elab_end - $elab_start}] seconds"
puts "ELABORATION RUNTIME = [expr {($elab_end - $elab_start) / 60.0}] minutes"
puts "========================================"
 
#======================================================================
# 5. Set current design
#======================================================================

current_design $DESIGN_NAME


#======================================================================
# 6. Basic design checks
#======================================================================

puts "=============================================="
puts "CHECK DESIGN"
puts "=============================================="

check_design > $REPORT_DIR/pre_synth/check_design.rpt

check_design -unresolved > \
    $REPORT_DIR/pre_synth/check_design_unresolved.rpt


#======================================================================
# 8. Save elaborated database
#======================================================================

write_db -to_file pinaka_elaborated.db

######################################################
#Dont use cells D0 & D1
######################################################
#
set_db [get_db lib_cells *D0*] .dont_use true
set_db [get_db lib_cells *D1*] .dont_use true



#======================================================================
# 9. Read SDC
#======================================================================

puts "=============================================="
puts "READING SDC"
puts "=============================================="

read_sdc -echo ./TOP.sdc


#======================================================================
# 10. Check timing constraints
#======================================================================

puts "=============================================="
puts "CHECKING CONSTRAINTS"
puts "=============================================="

check_timing_intent -verbose > $REPORT_DIR/pre_synth/check_timing_intent.rpt


#======================================================================
# 11. Constraint reports
#======================================================================

report_clocks > \
    $REPORT_DIR/pre_synth/clocks.rpt

report_timing -lint > \
    $REPORT_DIR/pre_synth/timing_lint.rpt



#========================================================
# Cost Groups
#========================================================

# Input -> Register
define_cost_group -name I2R -design [current_design]
path_group -from [all_inputs] \
           -to [all_registers] \
           -group I2R -name I2R

# Register -> Output
define_cost_group -name R2O -design [current_design]
path_group -from [all_registers] \
           -to [all_outputs] \
           -group R2O -name R2O

# Input -> Output
define_cost_group -name I2O -design [current_design]
path_group -from [all_inputs] \
           -to [all_outputs] \
           -group I2O -name I2O



#======================================================================
# 13. Pre-synthesis area
#======================================================================

report_area > \
    $REPORT_DIR/pre_synth/area.rpt



#======================================================================
# 14. Generic synthesis
#======================================================================

puts "=============================================="
puts "STARTING GENERIC SYNTHESIS"
puts "=============================================="

set_db / .syn_generic_effort $GEN_EFF
syn_generic
puts "Runtime & Memory after 'syn_generic'"

write_db -to_file pinaka_syn_gen.db

write_hdl  > pinaka_generic.v

#======================================================================
#                    AFTER SYN_GENERIC
#======================================================================

puts ""
puts "===================================================="
puts "           POST SYN_GENERIC REPORTS"
puts "===================================================="

# Design check
check_design > \
    $REPORT_DIR/post_syn_generic_check_design.rpt

# Unresolved objects
check_design -unresolved > \
    $REPORT_DIR/post_syn_generic_unresolved.rpt

# Timing constraint check
check_timing_intent > \
    $REPORT_DIR/post_syn_generic_check_timing_intent.rpt

# Area
report_area > \
    $REPORT_DIR/post_syn_generic_area.rpt

# Timing
report_timing \
    -max_paths 50 \
    > $REPORT_DIR/post_syn_generic_timing.rpt

# QoR
report_qor > \
    $REPORT_DIR/post_syn_generic_qor.rpt

# Power
report_power > \
    $REPORT_DIR/post_syn_generic_power.rpt


#======================================================================
# 15. Mapping
#======================================================================

puts "=============================================="
puts "STARTING TECHNOLOGY MAPPING"
puts "=============================================="

set_db / .syn_map_effort $MAP_EFF
syn_map
puts "Runtime & Memory after 'syn_map'"

write_db -to_file pinaka_syn_map.db

write_hdl  > pinaka_mapping.v


#======================================================================
#                       AFTER SYN_MAP
#======================================================================

puts ""
puts "===================================================="
puts "             POST SYN_MAP REPORTS"
puts "===================================================="

# Design check
check_design > \
    $REPORT_DIR/post_syn_map_check_design.rpt

# Unresolved objects
check_design -unresolved > \
    $REPORT_DIR/post_syn_map_unresolved.rpt

# Timing constraint check
check_timing_intent > \
    $REPORT_DIR/post_syn_map_check_timing_intent.rpt

# Area
report_area > \
    $REPORT_DIR/post_syn_map_area.rpt

# Timing
report_timing \
    -max_paths 50 \
    > $REPORT_DIR/post_syn_map_timing.rpt


# QoR
report_qor > \
    $REPORT_DIR/post_syn_map_qor.rpt

# Power
report_power > \
    $REPORT_DIR/post_syn_map_power.rpt

#======================================================================
# 16. Optimization
#======================================================================

puts "=============================================="
puts "STARTING SYNTHESIS OPTIMIZATION"
puts "=============================================="

set_db / .syn_opt_effort $OPT_EFF

syn_opt

puts "Runtime & Memory after 'syn_opt'"
time_info OPT

write_db -to_file pinaka_syn_opt.db


#======================================================================
#                       AFTER SYN_OPT
#======================================================================

puts ""
puts "===================================================="
puts "             POST SYN_OPT REPORTS"
puts "===================================================="

# Design check
check_design > \
    $REPORT_DIR/post_syn_opt_check_design.rpt

# Unresolved objects
check_design -unresolved > \
    $REPORT_DIR/post_syn_opt_unresolved.rpt

# Timing constraint check
check_timing_intent > \
    $REPORT_DIR/post_syn_opt_check_timing_intent.rpt

# Area
report_area > \
    $REPORT_DIR/post_syn_opt_area.rpt

# Timing
report_timing \
    -max_paths 100 \
    > $REPORT_DIR/post_syn_opt_timing.rpt


# QoR
report_qor > \
    $REPORT_DIR/post_syn_opt_qor.rpt

# Power
report_power > \
    $REPORT_DIR/post_syn_opt_power.rpt


#======================================================================
# 17. Post-synthesis design checks
#======================================================================

puts "=============================================="
puts "POST SYNTHESIS CHECKS"
puts "=============================================="

check_design > \
    $REPORT_DIR/post_synth/check_design.rpt

check_design -unresolved > \
    $REPORT_DIR/post_synth/check_design_unresolved.rpt

check_timing_intent > \
    $REPORT_DIR/post_synth/check_timing_intent.rpt


#======================================================================
# 18. Area report
#======================================================================

puts "=============================================="
puts "AREA REPORT"
puts "=============================================="

report_area \
    > $REPORT_DIR/post_synth/area.rpt


#======================================================================
# 19. Timing reports
#======================================================================

puts "=============================================="
puts "TIMING REPORT"
puts "=============================================="

report_timing \
    -max_paths 50 \
    > $REPORT_DIR/post_synth/timing.rpt



#======================================================================
# 22. QoR report
#======================================================================

report_qor > \
    $REPORT_DIR/post_synth/qor.rpt


#======================================================================
# 23. Power report
#======================================================================

report_power > \
    $REPORT_DIR/post_synth/power.rpt




#======================================================================
# 25. Write synthesized netlist
#======================================================================

puts "=============================================="
puts "WRITING NETLIST"
puts "=============================================="

write_hdl \
    > pinaka_m.v


#======================================================================
# 26. Write synthesized SDC
#======================================================================

write_sdc \
    > pinaka_m.sdc








check_design
check_timing_intent




##set_db / .delete_unloaded_insts false 
##set_db / .delete_unloaded_seqs false  
##set_db / .optimize_merge_flops false  
##set_db / .optimize_merge_latches false 

##set_db / .optimize_constant_0_flops false 
##set_db / .optimize_constant_1_flops false
##set_db / .optimize_constant_feedback_seqs false
##set_db / .optimize_constant_latches false

##set_db / .remove_assigns true
##set_db / .use_tiehilo_for_const duplicate
