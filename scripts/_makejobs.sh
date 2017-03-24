#!/bin/sh
echo "Usage: makejobs job# [file#]"

PROJECT="neurobench"
#source ${HOME}/MATLAB/setroot.sh

module purge
#. /etc/profile.d/modules.sh

# Use Intel compiler
module load matlab
source ${HOME}/MATLAB/setpath.sh
export MATLABPATH=${MATLABPATH}
WORKDIR="${SCRATCH}/${PROJECT}"

if [ -z "${2}" ]; 
	then DIRID=${1}; 
	else DIRID=${2}; 
fi

FILEID=${1}
FILENAME="joblist-${FILEID}.txt"
echo "Input #: ${1}   Output file: ${FILENAME}"

CEC14="{'sphere','ellipsoid','rotated_ellipsoid','step','ackley','griewank','rosenbrock','rastrigin'}"
CEC14_1="{'sphere','ellipsoid','rotated_ellipsoid','step'}"
CEC14_2="{'ackley','griewank','rosenbrock','rastrigin'}"

BBOB09="{'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12','f13','f14','f15','f16','f17','f18','f19','f20','f21','f22','f23','f24','f25','f26','f27'}"
BBOB09_1="{'f1','f2','f3','f4','f5','f6','f7','f8','f9'}"
BBOB09_2="{'f10','f11','f12','f13','f14','f15','f16','f17','f18'}"
BBOB09_3="{'f19','f20','f21','f22','f23','f24','f25','f26','f27'}"


# Default job list
PROBSET="'cec14'"
#DIMS="{'2D','3D','5D','10D','20D'}"
DIMS="{'3D','6D','10D','15D'}"
NOISE="'[]'"
#ALGOS="{'ga','simulannealbnd','fminsearch','fmincon','patternsearch','particleswarm','cmaes','mcs','randsearch','bipopcmaes','global'}"
ALGOS="{'ga','simulannealbnd','fminsearch','fmincon','fmincon@sqp','fmincon@actset','patternsearch','particleswarm','cmaes','mcs','randsearch','bipopcmaes','global'}"
BESTALGOS="{'ga','simulannealbnd','fminsearch','fmincon','fmincon@sqp','patternsearch','particleswarm','cmaes','mcs','global'}"
NOISEALGOS="{'ga','simulannealbnd','fminsearch','patternsearch','particleswarm','cmaes','cmaes@noisy','mcs','global','randsearch'}"
ALGOSET="'base'"
IDS="'1:30'"

BPSALGO_1="{'bps@base'}"
BPSALGO_2="{'bads@base'}"


case "${1}" in
	0)      PROBS="{'sphere'}"
		ALGOS="{'cmaes','bps'}"
		DIMS="{'2D'}"
		IDS="{'1'}"
		;;
	1)	PROBS=${CEC14_1}
		;;
	2)	PROBS=${CEC14_2}
		;;
        3)      PROBS=${CEC14}
                ALGOS="{'bps'}"
                IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
		;;
        4)      PROBS=${CEC14}
                ALGOS="{'bps@mads8es4eih'}"
		#DIMS="{'2D','3D','5D'}"
                IDS="{'1:5','6:10','11:15','16:20'}"
                ;;
        5)      PROBS=${CEC14}
                ALGOS="{'bps@mads'}"
                #DIMS="{'2D','3D','5D'}"
                IDS="{'1:10','11:20','21:30','31:40','41:50'}"
                ;;
        6)      PROBS=${CEC14}
                ALGOS="{'bps@mads8es2'}"
                #DIMS="{'2D','3D','5D'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
	11)	PROBS=${CEC14}
		NOISE="{'me'}"
		;;
        12)     PROBS=${CEC14}
                NOISE="{'hi'}"
                ;;
	13)	PROBS=${CEC14}
                ALGOS="{'bps'}"
		NOISE="{'me'}"
                IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;
        14)     PROBS=${CEC14}
                ALGOS="{'bps'}"
                NOISE="{'hi'}"
                IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;
        50)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09_1}
                IDS="{'1:30'}"
                ;;
	51)     PROBSET="{'bbob09'}"
		PROBS=${BBOB09_2}
		IDS="{'1:30'}"
		;;
        52)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09_3}
                IDS="{'1:30'}"
                ;;
        53)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
		ALGOS=$BPSALGO_1
                IDS="{'1:10','11:20','21:30'}"
                ;;
        54)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'bads'}"
                IDS="{'1:10','11:20','21:30'}"
                ;;
        55)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'fmincon@sqp'}"
                IDS="{'1:30'}"
                ;;
        56)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'bads@x2'}"
                IDS="{'1:10','11:20','21:30'}"
                ;;
        60)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09_1}
                IDS="{'1:30'}"
                NOISE="{'me'}"
                ;;
        61)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09_2}
                IDS="{'1:30'}"
		NOISE="{'me'}"
                ;;
        62)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09_3}
                IDS="{'1:30'}"
		NOISE="{'me'}"
                ;;
        63)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS=$BPSALGO_1
                IDS="{'1:10','11:20','21:30'}"
		NOISE="{'me'}"
                ;;
        64)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'bads'}"
                IDS="{'1:10','11:20','21:30'}"
		NOISE="{'me'}"
                ;;
        65)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'cmaes@noisy'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30'}"
                NOISE="{'me'}"
                ;;
        66)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'bads'}"
                IDS="{'1:10','11:20','21:30'}"
                NOISE="{'me'}"
                ;;
        67)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'bads@x2'}"
                IDS="{'1:10','11:20','21:30'}"
                NOISE="{'me'}"
                ;;
        101)    PROBSET="{'ccn17'}"
                PROBS="{'visvest_joint'}"
		ALGOS=$BESTALGOS
                DIMS="{'S1','S2','S3','S15','S16','S17'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        102)    PROBSET="{'ccn17'}"
                PROBS="{'visvest_joint'}"
                DIMS="{'S1','S2','S3','S15','S16','S17'}"
                ALGOS=$BPSALGO_1
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20','21:22','23:24','25:26','27:28','29:30','31:32','33:34','35:36','37:38','39:40','41:42','43:44','45:46','47:48','49:50'}"
		;;
       	103)    PROBSET="{'ccn17'}"
                PROBS="{'visvest_joint'}"
                DIMS="{'S1','S2','S3','S15','S16','S17'}"
                ALGOS="{'bads'}"
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20','21:22','23:24','25:26','27:28','29:30','31:32','33:34','35:36','37:38','39:40','41:42','43:44','45:46','47:48','49:50'}"
                ;;
       	104)    PROBSET="{'ccn17'}"
                PROBS="{'visvest_joint'}"
                DIMS="{'S1','S2','S3','S15','S16','S17'}"
                ALGOS="{'bads@x2'}"
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20','21:22','23:24','25:26','27:28','29:30','31:32','33:34','35:36','37:38','39:40','41:42','43:44','45:46','47:48','49:50'}"
                ;;
	201)    PROBSET="{'ccn17'}"
                PROBS="{'vandenberg2016'}"
                DIMS="{'S2101','S2102','S2103','S3104','S3105','S3106'}"
		ALGOS=$NOISEALGOS
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"
                ;;
        202)    PROBSET="{'ccn17'}"
                PROBS="{'vandenberg2016'}"
                DIMS="{'S2101','S2102','S2103','S3104','S3105','S3106'}"
                ALGOS="{'bads@x2'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                ;;
        203)    PROBSET="{'ccn17'}"
                PROBS="{'vandenberg2016'}"
                DIMS="{'S1107','S1108','S1109'}"
                ALGOS=$NOISEALGOS
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"
                ;;
        204)    PROBSET="{'ccn17'}"
                PROBS="{'vandenberg2016'}"
                DIMS="{'S1107','S1108','S1109'}"
                ALGOS="{'bads@x2'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                ;;
        301)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
		ALGOS=$BESTALGOS
		#IDS="{'1','2','3','4','5','6','7','8','9','10'}"
		IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"	
                ;;
        302)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS="{'bads@x2'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        303)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS="{'bads'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
       	311)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S7','S8','S9','S10','S11','S12'}"
                ALGOS=$BESTALGOS
                #IDS="{'1','2','3','4','5','6','7','8','9','10'}"
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"
                ;;
        312)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S7','S8','S9','S10','S11','S12'}"
                ALGOS="{'bads@x2'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        313)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S7','S8','S9','S10','S11','S12'}"
                ALGOS="{'bads'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        401)    PROBSET="{'ccn17'}"
                PROBS="{'adler2016'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS=$ALGOS
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"
                ;;
        402)    PROBSET="{'ccn17'}"
                PROBS="{'adler2016'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS="{'bads'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        501)    PROBSET="{'ccn17'}"
                PROBS="{'vanopheusden2016'}"
		DIMS="{'S10','S11','S12','S13','S14','S15'}"
		ALGOS="{'mcs'}"
		IDS="{'1','2','3','4','5','6','7','8','9','10'}" 
                ;;
       	502)    PROBSET="{'ccn17'}"
                PROBS="{'vanopheusden2016'}"
                DIMS="{'S10','S11','S12','S13','S14','S15'}"
                ALGOS="{'bads'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10'}"
                ;;
        503)    PROBSET="{'ccn17'}"
                PROBS="{'vanopheusden2016'}"
                DIMS="{'S10','S11','S12','S13','S14','S15'}"
                ALGOS="{'cmaes'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10'}"
                ;;
        601)    PROBSET="{'ccn17'}"
                PROBS="{'targetloc'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS=$NOISEALGOS
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20'}"
                ;;
        602)    PROBSET="{'ccn17'}"
                PROBS="{'targetloc'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS="{'bads'}"
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                ;;

esac

echo "Job items: ${PROBSET},${PROBS},${DIMS},${NOISE},${ALGOS},${ALGOSET},${IDS}"

cat<<EOF | matlab -nodisplay
addpath(genpath('${HOME}/${PROJECT}'));
currentDir=cd;
cd('${WORKDIR}');
benchmark_joblist('${FILENAME}','run${DIRID}',${PROBSET},${PROBS},${DIMS},${NOISE},${ALGOS},${ALGOSET},${IDS});
cd(currentDir);
EOF

cat ${WORKDIR}/${FILENAME} | wc
