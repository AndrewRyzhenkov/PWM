create_project PWM ./PWM -part xc7a35ticsg324-1L

add_files -norecurse ./sources/PWM.v
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./sources/PWM_TB.v
update_compile_order -fileset sim_1

add_files -fileset constrs_1 -norecurse ./constraint/PWM.xdc