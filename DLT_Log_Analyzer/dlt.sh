#!/bin/bash

source_log_path="/var/log/syslog" 
logfile="/Enter/Your/Path/Here/Logs" 
cp "$source_log_path" "$logfile"  
logfile1="/Enter/Your/Path/Here/Summary_Logs" 

summarize_log_level() {
  local log_level="$1" 
  local count=$(grep -c "${log_level}" "$logfile") 

  if [[ "$count" -gt 0 ]]; then 
    echo "---- $log_level Events ----" 
    grep "${log_level}" "$logfile" | head -n 5 
    echo "Total $log_level events: $count" 
    echo "" 
  fi
}

summarize_events() {
  local event_pattern="$1" 
  local event_name="$2" 
  local count=$(grep -c "$event_pattern" "$logfile") 

  if [[ "$count" -gt 0 ]]; then 
    echo "---- $event_name Events ----" 
    grep "$event_pattern" "$logfile" | head -n 5 
    echo "Total $event_name events: $count" 
    echo "" 
  fi
}

generate_summary_log() {
  echo "----- Summary -----" > "$logfile1"
  summarize_log_level "ERROR" >> "$logfile1"
  summarize_log_level "WARN" >> "$logfile1"
  summarize_log_level "WARNING" >> "$logfile1"
  summarize_log_level "INFO" >> "$logfile1"
  summarize_log_level "DEBUG" >> "$logfile1"
  summarize_events "system startup sequence initiated" "Startup" >> "$logfile1"
  summarize_events "System Health Check OK" "System Health" >> "$logfile1"
}

Choice_Selection() {
  PS3='Enter your choice: ' 
  options=("Errors" "Warnings" "Info" "Debug" "All" "Summarize" "Startup Events" "System Health" "Quit") 
  
  select opt in "${options[@]}"; do 
    case $opt in 
      "Errors")
        summarize_log_level "ERROR" 
        break 
        ;;
      "Warnings")
        summarize_log_level "WARN" 
        summarize_log_level "WARNING" 
        break
        ;;
      "Info")
        summarize_log_level "INFO" 
        break
        ;;
      "Debug")
        summarize_log_level "DEBUG" 
        break
        ;;
      "All")
        summarize_log_level "ERROR" 
        summarize_log_level "WARN"
        summarize_log_level "WARNING"
        summarize_log_level "INFO"
        summarize_log_level "DEBUG"
        break
        ;;
      "Summarize")
        echo "Total Errors: $(grep -c '*ERROR*' "$logfile")" 
        echo "Total Warnings: $(grep -c '*WARN*|*WARNING*' "$logfile")" 
        echo "Total Info: $(grep -c '*INFO*' "$logfile")" 
        echo "Total Debug: $(grep -c '*DEBUG*' "$logfile")" 
        break
        ;;
      "Startup Events")
        summarize_events "system startup sequence initiated" "Startup" 
        break
        ;;
      "System Health")
        summarize_events "System Health Check OK" "System Health" 
        break
        ;;
      "Quit")
        echo "Exiting..."
        generate_summary_log 
        echo "----- Full Log -----" >> "$logfile1"
        cat "$logfile" >> "$logfile1" 
        exit 0
        ;;
      *)
        echo "Invalid option. Please try again." 
        ;;
    esac
  done
}

while true; do
  echo "Select log categories to generate:" 
  Choice_Selection 

  echo "Categorization complete." 
done
