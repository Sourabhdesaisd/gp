# Cadence Genus(TM) Synthesis Solution, Version 17.22-s017_1, built Apr  1 2018

# Date: Wed Mar 01 21:06:17 2023
# Host: compute1-srv.nis.vivartan.com (x86_64 w/Linux 3.10.0-1160.119.1.el7.x86_64) (28cores*112cpus*2physical cpus*Intel(R) Xeon(R) Platinum 8173M CPU @ 2.00GHz 39424KB)
# OS:   CentOS Linux release 7.9.2009 (Core)

source syn_final.tcl
report_timing -from [all_registers] -to [all_registers]
check_timing_intent
report_timing -from [all_registers] -to [all_registers]
report_timing -from [all_registers] -to [all_registers] -logic_levels 1
report_timing -from [all_registers] -to [all_registers] -logic_levels -max_paths 100
report_timing -from [all_registers] -to [all_registers] -max_paths 100
report_timing -from [all_registers] -to [all_registers] -max_paths 500
report_timing -from [all_registers] -to [all_registers] -max_paths 1000
report_timing -from [all_registers] -to [all_registers] -max_paths 1100
report_timing -from [all_registers] -to [all_registers] -max_paths 1300
report_timing -from [all_registers] -to [all_registers] -max_paths 1600
help summary
help *summary*
report_timing -from [all_registers] -to [all_registers] -max_paths 1
get_db lib_cells *FA1*
report_timing -from [all_registers] -to [all_registers] -max_paths 1 -path_type full
report_timing -from [all_registers] -to [all_registers] -max_paths 1 -path_type full -nets
report_timing -from [all_registers] -to [all_registers] -max_paths 1 -path_type full -nets -f
help *fan_out*
help *fanOut*
help *fan*
report_power
report_boundary_opt
syn_opt -spatial
man syn_opt -spatial
man syn_opt
group_path -from [all_registers] -to [all_registers] -name ad -weight 100
report_timing -from [all_registers] -to [all_registers]
syn_opt_effort
report_timing -from [all_register] -to [all_register]
report_timing -from [all_register] -to [all_register] -max_paths 5
report_timing -from [all_register] -to [all_register] -max_paths 5
report_timing -from [all_register] -to [all_register] -max_paths 50
report_timing -from [all_register] -to [all_register] -max_paths 100
report_timing -from [all_register] -to [all_register] -max_paths 70
report_timing -from [all_register] -to [all_register] -max_paths 1600 > timing_maxpath1600.rpt
ls
pwd
source 1600.tcl
source 1600.tcl
ls
ls -l
ls -ll
source 1600.tcl
clear
report_timing -from [all_register] -to [all_register]
source slack_script
source slack_script
source slackScript
ls
source slackScript
