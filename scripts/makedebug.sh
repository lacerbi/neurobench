#!/bin/sh
#PBS -o localhost:${PBS_O_WORKDIR}/
#PBS -e localhost:${PBS_O_WORKDIR}/
#PBS -M la67@nyu.edu

NAME=BenchMark
module purge
#. /etc/profile.d/modules.sh

# Use Intel compiler
module load matlab
source /home/la67/MATLAB/setpath.sh

export MATLABPATH=${MATLABPATH}

#Check if running as an array job
if [[ ! -z "$PBS_ARRAYID" ]]; then
	IID=${PBS_ARRAYID}
fi
#Check if running as an array job
if [[ ! -z "$SGE_TASK_ID" ]]; then
        IID=${SGE_TASK_ID}
fi

FILENAME="'${1}'"

# Run the program
PROBS="{1}"
DIMS="{2,3,5,10,20}"
NOISE="'[]'"
ALGOS="{'fmincon','patternsearch'}"
IDS="'1:10'"

cat<<EOF | matlab -nodisplay
parlist=combcell('cec14',${PROBS},${DIMS},${NOISE},${ALGOS},'base',${IDS});
fout=fopen(${FILENAME},'w+');
for i=1:length(parlist)
	fprintf(fout,'''%s'',''%d'',''%d'',''%s'',''%s'',''%s'',''%s''\n',parlist{i}{1},parlist{i}{2},parlist{i}{3},parlist{i}{4},parlist{i}{5},parlist{i}{6},parlist{i}{7});
end
fclose(fout);
EOF
