#=================================================================================#
# File         run_script.gdb                                                     #
# Author       Long Dao                                                           #
# Version      1.0.6                                                              #
# Release      11-08-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      Reset the state of INTERRUPT_STATE                                 #
#=================================================================================#

# Set a breakpoint at label "GDBSCRIPT_TC_01_TP01" and start program
break GDBSCRIPT_TC_01_TP01
run

# Goto "Wait_Finish" function
break Wait_Finish
continue

# Step over 10 times in a row (Like waiting to clear the interrupt status)
next 10

# Perform manual interrupt status clearing
printf "\nThe interrupt state before clearing is: %d", INTERRUPT_STATE
set INTERRUPT_STATE = 0
printf "\nThe interrupt state after clearing is: %d\n\n", INTERRUPT_STATE

# Delete all breakpoints
delete

# Continue running until the end of the program and quit
continue
quit

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
