#!/bin/bash
# mistral cpu batch job parameters
# --------------------------------
#SBATCH --account=bd1179
#SBATCH --job-name=s3Dq
#SBATCH --partition=shared
#SBATCH --ntasks=30
#SBATCH --cpus-per-task=1
#SBATCH --output=LOG.s3Dq-out_%j
#SBATCH --error=LOG.s3Dq-out_%j
#SBATCH --mail-type=FAIL
#SBATCH --time=7-00:00:00
# --------------------------------
# Run the script.
# From the main repository directory:
#    $> sbatch slurm_dkrz/<script>.sh
# --------------------------------

logFile=`ls LOG.s3Dq-out_*`

# Variables & Levels
#variables_3D=" tphystnd "
variables_3D=" phq "
#variables_3D=""
levels=" 3.643 7.595 14.357 24.612 38.268 54.6 72.012 87.821 103.317 121.547 142.994 168.225 197.908 232.829 273.911 322.242 379.101 445.993 524.687 609.779 691.389 763.404 820.858 859.535 887.020 912.645 936.198 957.485 976.325 992.556 "
#levels=" 54.6 "

#variables_2D=" fsns flns fsnt flnt prect "
variables_2D=""


# Paths
scriptPath=`pwd`
logPath=logs
cfgPath=nn_config
cfgPath_parallel=$cfgPath/srun_parallel


# Scripts
pyScript=pipeline


## PROCESSING
#
echo "---------- Starting $0 ----------"
echo ""

cfgFile_tmp=cfg_pipeline_srun_parallel.yml

if [ ! -f ${pyScript}.py ]; then
    echo "Convert jupyter notebook into python script"
    module load python3/unstable
    jupyter nbconvert --to script ${pyScript}.ipynb
    module purge
fi
echo ""

echo "Run PCMCI for Rasp et al."
source /pf/b/b309172/.bashrc
conda activate causalnncam

count=1
if [ -n "$variables_3D" ]; then
    for iVar in $variables_3D; do
	for iLev in $levels; do
	    cfgFile=cfg_pipeline_${iVar}_${iLev}.yml
	    if test -f "./${cfgPath_parallel}/$cfgFile"; then
		echo "$cfgFile exists"
	    else
		echo "create ${cfgFile}..."
		cp ./$cfgPath/$cfgFile_tmp ./$cfgPath_parallel/$cfgFile
		sed -i -- "s/variable/${iVar}/g" ./$cfgPath_parallel/$cfgFile
		sed -i -- "s/level_to_be_analysed/[${iLev}]/g" ./$cfgPath_parallel/$cfgFile
	    fi
	    echo $count
#	cat ./$cfgPath_parallel/$cfgFile > $logFile
	    srun --ntasks=1 -c 1 python ${pyScript}.py -c ./$cfgPath_parallel/$cfgFile &
	    let count++
	done
    done  
fi

if [ -n "$variables_2D" ]; then
    for iVar in $variables_2D; do
	cfgFile=cfg_pipeline_${iVar}_False.yml
	if test -f "./${cfgPath_parallel}/$cfgFile"; then
	    echo "$cfgFile exists."
	else
	    echo "create ${cfgFile}..."
	    cp ./$cfgPath/$cfgFile_tmp ./$cfgPath_parallel/$cfgFile
	    sed -i -- "s/variable/${iVar}/g" ./$cfgPath_parallel/$cfgFile
	    sed -i -- "s/level_to_be_analysed/False/g" ./$cfgPath_parallel/$cfgFile
	fi
	echo $count
#	cat ./$cfgPath_parallel/$cfgFile > $logFile
	srun --ntasks=1 -c 1 python ${pyScript}.py -c ./$cfgPath_parallel/$cfgFile &
	let count++
    done  
fi

wait

# Clean-up
rm ${pyScript}.py
rm ./$cfgPath_parallel/*.yml
if [ ! -d $logPath ]; then
    mkdir -p $logPath
fi
mv $logFile $logPath/$logFile


echo ""
echo "---------- Finished $0 ----------"