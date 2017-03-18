#!/bin/bash
PROJECT="neurobench"
SHORTNAME=NB
BASEDIR="${HOME}/${PROJECT}"
SOURCEDIR="${BASEDIR}/matlab"
JOBSCRIPT="${BASEDIR}/scripts/myjob.sh"

#Job parameters
RUN=${1}
INPUTFILE="joblist-${1}.txt"
MAXID=$(sed -n $= ${INPUTFILE})
RUNTIME=24:00:00
MAXRT=NaN
INPUTFILE="${BASEDIR}/${INPUTFILE}"
VERBOSE=0
USEPRIOR=1
TOLFUN="1e-3"
MAXFUNMULT="[]"

NODES="1"
PPN="1"
MEM="3GB"
RESOURCES="nodes=${NODES}:ppn=${PPN},mem=${MEM},walltime=${RUNTIME}"

#if [[ -z ${1} ]]; then
        JOBLIST="1-$MAXID"
        NEWJOB=1
#else
#        JOB=${1}
#        NEWJOB=0
#        echo "JOB=${JOB}" >> ${BASEDIR}/reruns.log
#fi

#Convert from commas to spaces
JOBLIST=${JOBLIST//,/ }
echo JOBS $JOBLIST

WORKDIR="${SCRATCH}/${PROJECT}/run${RUN}"
mkdir ${WORKDIR}
cd ${WORKDIR}

JOBNAME=${SHORTNAME}${RUN}

if [ ${CLUSTER} = "Prince" ]; then
        # running on Prince
        sbatch --verbose --array=${JOBLIST} --mail-type=FAIL --mail-user=${USER}@nyu.edu --mem=${MEM} --time=${RUNTIME} --nodes=${NODES} --ntasks-per-node=${PPN} --export=PROJECT=${PROJECT},RUN=${RUN},MAXID=$MAXID,WORKDIR=$WORKDIR,USER=$USER,MAXRT=$MAXRT,INPUTFILE=${INPUTFILE},VERBOSE=${VERBOSE},USEPRIOR=${USEPRIOR},TOLFUN=${TOLFUN},MAXFUNMULT=${MAXFUNMULT} --job-name=${JOBNAME} ${JOBSCRIPT}
else
	qsub -t ${JOBLIST} -q normal -v PROJECT=${PROJECT},RUN=${RUN},MAXID=$MAXID,WORKDIR=$WORKDIR,USER=$USER,MAXRT=$MAXRT,INPUTFILE=${INPUTFILE},VERBOSE=${VERBOSE},USEPRIOR=${USEPRIOR},TOLFUN=${TOLFUN},MAXFUNMULT=${MAXFUNMULT} -l ${RESOURCES} -M ${USER}@nyu.edu -N ${JOBNAME} ${JOBSCRIPT}
fi
