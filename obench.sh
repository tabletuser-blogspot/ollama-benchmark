#!/bin/bash
# Benchmark using ollama gives rate of tokens per second
# idea taken from https://taoofmac.com/space/blog/2024/01/20/1800
# other colors
#Black      	0;30	Dark Gray   	1;30
#Red        	0;31	Light Red   	1;31
#Green      	0;32	Light Green   1;32
#Brown/Orange 0;33  	Yellow      	1;33
#Blue       	0;34	Light Blue  	1;34
#Purple     	0;35	Light Purple  1;35
#Cyan       	0;36	Light Cyan  	1;36
#Light Gray   0;37  	White       	1;37
#ANSI option
#RED='\033[0;31m'
#NC='\033[0m' # No Color
#echo -e "${red}Hello Stackoverflow${NC}"
#set -e used for troubleshooting
set -e
#colors available
borange='\e[0;33m'
yellow='\e[1;33m'
purple='\e[0;35m'
green='\e[0;32m'
red='\e[0;31m'
blue='\e[0;34m'
NC='\e[0m' # No Color
cpu_def=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo "Setting cpu governor to"
sudo echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
gpu_avail=$(sudo lshw -C display | grep product: | head -1 | cut -c17-)
cpugover=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
cpu_used=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')
echo ""
echo "Simple benchmark using ollama and"
echo "whatever local Model is installed."
echo "Does not identify if $gpu_avail is benchmarking"
echo ""
echo "How many times to run the benchmark?"
read benchmark
echo ""
echo -e "Total runs "${purple}$benchmark${NC}
echo ""
echo "Current models available locally"
echo ""
ollama list
echo ""
echo "Example enter tinyllama or dolphin-phi"
echo ""
read model
ollama show $model --system
echo ""
echo -e "Will use model: "${green}$model${NC}
echo ""
echo -e Will benchmark the tokens per second for ${cpu_used} and or ${gpu_avail}
touch "${cpu_used}".txt
echo "" > "${cpu_used}".txt
echo ""
echo -e Running benchmark ${purple}$benchmark${NC} times for ${cpu_used} and or ${gpu_avail}
echo -e with ${borange}$cpugover${NC} setting for cpu governor
echo ""
for run in $(seq 1 $benchmark);
do echo "Why is the blue sky blue?" | ollama run $model --verbose 2>&1 >/dev/null | grep "eval rate:" | tee -a "${cpu_used}".txt ;

avg=$(cat "${cpu_used}".txt | grep -v "prompt eval rate:" | awk '{print $3}' | awk 'NR>1{ tot+=$1 } END{ print tot/(NR-1) }')
done
echo ""
echo -e ${red}$avg${NC} is the average ${blue}tokens per second${NC} using ${green}$model${NC} model
echo for $cpu_used and or $gpu_avail
echo -e using ${borange}$cpugover${NC} for cpu governor.
echo ""
echo "Setting cpu governor to"
sudo echo $cpu_def | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
#comment this out if you are repeating the same model
#this clears model from Vram
sudo systemctl stop ollama; sudo systemctl start ollama
#EOF
