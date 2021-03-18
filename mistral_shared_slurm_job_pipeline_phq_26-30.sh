#!/bin/bash
# mistral cpu batch job parameters
# --------------------------------
#SBATCH --account=bd1179
#SBATCH --job-name=sgl_phq_26-30_lats_lons14-16
#SBATCH --partition=shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=LOG.sgl_phq_26-30_lats_lons14-16-%j.o
#SBATCH --error=LOG.sgl_phq_26-30_lats_lons14-16-%j.o
##SBATCH --exclusive
#SBATCH --mail-type=FAIL
#SBATCH --time=30:00:00


# Paths
scriptPath=`pwd`
logPath=${scriptPath}/logs

# Scripts
pyScript=pipeline
cfgFile=cfg_${pyScript}_phq_26-30.yml

## PROCESSING
#
echo "---------- Starting $0 ----------"
echo ""

cd $scriptPath

logFile=`ls LOG.sgl_phq_26-30_lats_lons14-16-*`
cat $scriptPath/$cfgFile > $logFile

if [ ! -f ${scriptPath}/${pyScript}.py ]; then
    echo "Convert jupyter notebook into python script"
    module load python3/unstable
    jupyter nbconvert --to script ${pyScript}.ipynb
    module purge
    echo ""
fi

echo "Run PCMCI"
source /pf/b/b309172/.bashrc
conda activate tg38plus
python ${pyScript}.py -c $cfgFile

# Clean-up
rm ${pyScript}.py
if [ ! -d $logPath ]; then
    mkdir -p $logPath
fi
#mv $scriptPath/$logFile $logPath/$logFile

echo ""
echo "---------- Finished $0 ----------"