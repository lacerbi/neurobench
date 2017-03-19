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
FILENAME="'joblist-${FILEID}.txt'"
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
BESTALGOS="{'ga','simulannealbnd','fminsearch','fmincon','fmincon@sqp','patternsearch','particleswarm','cmaes','mcs','bipopcmaes','global'}"
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
                ALGOS=$BPSALGO_2
                IDS="{'1:10','11:20','21:30'}"
                ;;
        55)     PROBSET="{'bbob09'}"
                PROBS=${BBOB09}
                ALGOS="{'fmincon@sqp'}"
                IDS="{'1:30'}"
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
                ALGOS=$BPSALGO_2
                IDS="{'1:2','3:4','5:6','7:8','9:10','11:12','13:14','15:16','17:18','19:20','21:22','23:24','25:26','27:28','29:30','31:32','33:34','35:36','37:38','39:40','41:42','43:44','45:46','47:48','49:50'}"
                ;;
        201)    PROBSET="{'ccn15'}"
                PROBS="{'aspen_wrm_fp','aspen_wrm_vpheurs','aspen_wrm_fpheurs','aspen_wrm_vp','aspen_wrm_uneqvar'}"
                DIMS="{'S1','S2','S3'}"
                IDS="{'1:25','26:50','51:75','76:100'}"
                ;;
        202)    PROBSET="{'ccn15'}"
                PROBS="{'aspen_wrm_fp','aspen_wrm_vpheurs','aspen_wrm_fpheurs','aspen_wrm_vp','aspen_wrm_uneqvar'}"
                DIMS="{'S1','S2','S3'}"
		ALGOS="{'multibayes'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
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
                ALGOS=$BPSALGO_1
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        303)    PROBSET="{'ccn17'}"
                PROBS="{'goris2014'}"
                DIMS="{'S1','S2','S3','S4','S5','S6'}"
                ALGOS=$BPSALGO_2
                IDS="{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'}"
                #IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                ;;
        501)    PROBSET="{'ccn15'}"
                PROBS="{'bas_sampling'}"
                #DIMS="{'S1','S2','S3'}"
		DIMS="{'S1','S3','S5','S10','S18'}"
		ALGOS="{'ga','simulannealbnd','fminsearch','fmincon','patternsearch','particleswarm','cmaes','mcs','bps'}"
		IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                #IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;
        502)    PROBSET="{'ccn15'}"
                PROBS="{'bas_sampling'}"
                DIMS="{'S1','S2','S3'}"
                ALGOS="{'bps'}"
                #DIMS="{'S2'}"
                #IDS="{'1:10'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                #IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;
        601)    PROBSET="{'ccn15'}"
                PROBS="{'aspen_wrm'}"
                #DIMS="{'S1','S2','S3'}"
                DIMS="{'S1','S2','S3','S4'}"
                ALGOS="{'ga','simulannealbnd','fminsearch','fmincon','patternsearch','particleswarm','cmaes','mcs','bps'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                #IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;
        602)    PROBSET="{'ccn15'}"
                PROBS="{'aspen_wrm'}"
                #DIMS="{'S1','S2','S3'}"
                DIMS="{'S1','S2','S3','S4'}"
                ALGOS="{'ga','simulannealbnd','fminsearch','fmincon','patternsearch','particleswarm','cmaes','mcs','bps'}"
                IDS="{'1:5','6:10','11:15','16:20','21:25','26:30','31:35','36:40','41:45','46:50'}"
                #IDS="{'1:10','11:20','21:30','31:40','41:50','51:60','61:70','71:80','81:90','91:100'}"
                ;;




esac

echo "Job items: ${PROBSET},${PROBS},${DIMS},${NOISE},${ALGOS},${ALGOSET},${IDS}"

cat<<EOF | matlab -nodisplay
addpath(genpath('${HOME}/${PROJECT}'));
currentDir=cd;
cd('${WORKDIR}');
benchmark_joblist(${FILENAME},'run${DIRID}',${PROBSET},${PROBS},${DIMS},${NOISE},${ALGOS},${ALGOSET},${IDS});
cd(currentDir);
EOF
