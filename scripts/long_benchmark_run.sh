#!/bin/bash
NAME=BenchMark
SHORTNAME=BM
source ./setroot.sh
BASEDIR="${ROOTPATH}/${NAME}"
SOURCEDIR="${BASEDIR}/matlab"
JOBSCRIPT="${BASEDIR}/myjob.sh"

#Job parameters
RUN=${1}
INPUTFILE="joblist-${1}.txt"
MAXID=$(sed -n $= ${INPUTFILE})
RUNTIME=72:00:00
MAXRT=NaN
INPUTFILE=${BASEDIR}/${INPUTFILE}
VERBOSE=0
USEPRIOR=1
TOLFUN="1e-3"
MAXFUNMULT="5"

#RESOURCES="nodes=1:ppn=1,mem=4GB,walltime=${RUNTIME},feature=ivybridge_20p_64GB_3000MHz"
RESOURCES="nodes=1:ppn=1,mem=4GB,walltime=${RUNTIME}"

#if [[ -z ${1} ]]; then
        JOB="1-$MAXID"
        NEWJOB=1
#else
#        JOB=${1}
#        NEWJOB=0
#        echo "JOB=${JOB}" >> ${BASEDIR}/reruns.log
#fi

#Convert from commas to spaces
JOB=${JOB//,/ }
echo JOBS $JOB
WORKDIR="${ROOTPATH}/${NAME}/run${RUN}long"
mkdir ${WORKDIR}
cd ${WORKDIR}
JOBNAME=bmk${RUN}
qsub -t ${JOB} -v MAXID=$MAXID,MAXRT=$MAXRT,WORKDIR=$WORKDIR,ROOTPATH=${ROOTPATH},INPUTFILE=$INPUTFILE,VERBOSE=${VERBOSE},USEPRIOR=${USEPRIOR},TOLFUN=${TOLFUN},MAXFUNMULT=${MAXFUNMULT} -l ${RESOURCES} -N ${JOBNAME} ${JOBSCRIPT}
