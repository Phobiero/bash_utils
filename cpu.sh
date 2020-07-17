#!/bin/bash
old_tty=$(stty --save)

# Minimum required changes to terminal.  Add -echo to avoid output to screen.
stty -icanon min 0;

function stress {
  for thread in $(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
  do
    yes > /dev/null &
  done
  while true ; do
	  if read -t 0; then # Input ready
		read -n 1 char
		if [ $char == "t" ]
		then
		  echo "Exiting stress test..."
		  killall yes   
		  break
		fi	
	   else # No input
		echo "CPU is loaded 100%"
		echo "$nproc"
		echo "press t to stop"
		echo
		lscpu | grep "Model name"
		echo -n "Mode: "
		cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
		lscpu | grep "CPU MHz"
		paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep "x86_pkg_temp"
		sleep 1
		clear
	   fi 
  done      
}

clear

while true ; do
    if read -t 0; then # Input ready
        read -n 1 char
        if [ $char == "q" ]
	then
	  echo "Exiting..."   
          break
	fi
	if [ $char == "t" ]
	then
	  echo "Start stress test? (y/n)"
	  read -n 1 ans
	  if [ $ans == "y" ]
	  then	
		stress
          fi   
	fi
    else # No input
	lscpu | grep "Model name"
	echo -n "Mode: "
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        lscpu | grep "CPU MHz"
	paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep "x86_pkg_temp"
	echo
	echo "q - quit t - stress test"
        sleep 1
	clear
    fi       
done


stty $old_tty
