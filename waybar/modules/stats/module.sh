#!/usr/bin/env bash
STATE=/tmp/waybar-stats-expanded

cpu=$(awk -v FS=" " '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u;t1=t} else print int(100*(u-u1)/(t-t1))}' <(grep '^cpu ' /proc/stat; sleep 0.3; grep '^cpu ' /proc/stat))
mem=$(free -m | awk '/^Mem:/ {printf "%d", $3*100/$2}')
temp=$(sensors 2>/dev/null | awk '/Tctl|Package/ {gsub("[+]|°C",""); print int($2); exit}')
disk=$(df -h / | awk 'NR==2 {print $5}')

if [ -f "$STATE" ]; then
    text="  ${cpu}%   ${mem}% "
    class="expanded"
else
    text="  ${cpu}%"
    class="compact"
fi
printf '{"text":"%s","class":"%s","tooltip":"CPU %s%% · RAM %s%% · Temp %s°C · Disk %s"}\n'     "$text" "$class" "$cpu" "$mem"
