set rpt_file "timing_maxpath1600.rpt"
set out_file "slack_distribution.rpt"
 
set awk_script {
tolower($0) ~ /slack/ {
    for (i=1; i<=NF; i++) {
        if ($i == "VIOLATED") {
            s=$(i+1)
            gsub(/[():]/, "", s)
 
            if (s < 0) {
                for (low=-1.8; low<0; low+=0.1) {
                    high=low+0.1
 
                    if (s >= low && s < high) {
                        count[low]++
                        break
                    }
                }
            }
        }
    }
}
 
END {
    for (low=-1.8; low<0; low+=0.1) {
        high=low+0.1
        printf "%6.1f to %6.1f ns : %d paths\n", low, high, count[low]+0
    }
}
}
 
set result [exec awk $awk_script $rpt_file]
 
set fp [open $out_file w]
puts $fp $result
close $fp
 
puts "=============================================="
puts "SLACK DISTRIBUTION"
puts "=============================================="
puts $result
puts "=============================================="
puts "Saved to: $out_file"
puts "=============================================="



 

