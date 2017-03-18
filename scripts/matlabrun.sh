#!/bin/bash
module purge
module load matlab/2015a
source setroot.sh
BASEPATH="${ROOTPATH}/MATLAB"
source ${BASEPATH}/setpath.sh
matlab -nodisplay
