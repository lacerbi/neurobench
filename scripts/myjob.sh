#!/bin/sh
#PBS -o localhost:${PBS_O_WORKDIR}/
#PBS -e localhost:${PBS_O_WORKDIR}/
#PBS -M la67@nyu.edu

NAME=BenchMark

module purge
#. /etc/profile.d/modules.sh

# Use Intel compiler
module load matlab/2015a
export MATLABPATH=${MATLABPATH}:/${ROOTPATH}/${NAME}/matlab:${ROOTPATH}/MATLAB
source ${ROOTPATH}/MATLAB/setpath.sh

#Check if running as an array job
if [[ ! -z "$PBS_ARRAYID" ]]; then
	IID=${PBS_ARRAYID}
fi
#Check if running as an array job
if [[ ! -z "$SGE_TASK_ID" ]]; then
        IID=${SGE_TASK_ID}
fi

# Run the program

PARAMS=$(awk "NR==${IID} {print;exit}" ${INPUTFILE})

echo ${PARAMS} ${VERBOSE} ${USEPRIOR}

cat<<EOF | matlab -nodisplay
addpath(genpath('${ROOTPATH}/MATLAB'));
cd('${WORKDIR}');
options=struct('RootDirectory','${WORKDIR}','Display',${VERBOSE},'TolFun',${TOLFUN},'MaxFunEvalMultiplier',${MAXFUNMULT},'StopSuccessfulRuns',${STOPSUCCRUNS});
${PARAMS}
benchmark_run(${PARAMS},options);
EOF
