#!/bin/bash
# Benchmark using ollama gives rate of tokens per second
# taken from https://taoofmac.com/space/blog/2024/01/20/1800
# will not install models use standard install command
# ollama run tinydolphin
# sudo lshw -C display | grep product: | head -1 | cut -c17-
# add color
# v5 show installed gpu
# missing cpu_scaling

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37
#ANSI option
#RED='\033[0;31m'
#NC='\033[0m' # No Color

#v6 added switching to performance and returning to default
#sudo echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
#sudo echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
#cpugover=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
set -e
red='\e[0;31m'
blue='\e[0;34m'
NC='\e[0m' # No Color
#echo -e "${red}Hello Stackoverflow${NC}"
cpu_def=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo Set cpu governor to
sudo echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
gpu_avail=$(sudo lshw -C display | grep product: | head -1 | cut -c17-)
cpugover=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
cpu_used=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')

echo
echo Simple benchmark using ollama and
echo "whatever model is installed."
echo "Does not identify if $gpu_avail is benchmarking"
echo ""
echo "How many times to run the benchmark?"
read benchmark
echo ""
echo "Total runs "$benchmark
echo ""
echo "Current models available locally"
echo ""
ollama list
echo ""
echo "Example enter tinyllama or dolphin-phi"
echo ""
read model
#echo ""
ollama show $model --system
echo "Will use model: "$model
echo ""

echo "Will benchmark the tokens per second for "$cpu_used
touch "${cpu_used}".txt
echo "" > "${cpu_used}".txt
#echo ""
#echo Using ${model} to benchmark.
echo ""
echo Running benchmark ${benchmark} times for ${cpu_used}
echo with $cpugover setting for cpu governor
#echo Running benchmark ${benchmark} times for ${cpu_used} or ${gpu_avail}
echo ""

for run in $(seq 1 $benchmark);
do echo "Why is the sky blue?" | ollama run $model --verbose 2>&1 >/dev/null | grep "eval rate:" | tee -a "${cpu_used}".txt ;

avg=$(cat "${cpu_used}".txt | grep -v "prompt eval rate:" | awk '{print $3}' | awk 'NR>1{ tot+=$1 } END{ print tot/(NR-1) }')
done

echo ""
# removed quotes and added model
echo -e ${red}$avg${NC} is the average ${blue}tokens per second${NC} using $model model
echo for $cpu_used or $gpu_avail
echo using $cpugover for cpu governor.
echo
echo Setting cpu governor back to
sudo echo $cpu_def | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
#EOF
