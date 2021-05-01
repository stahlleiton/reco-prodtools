#!/bin/bash
export XRD_NETWORKSTACK=IPv4

## External vars
clusterid=${1}
procid=${2}
curDir=${3}
outDir=${4}
cfgFileGSD=${5}
cfgFileRECO=${6}
cfgFileNTUP=${7}
localFlag=${8}
eosArea=${9}
dataTier=${10}
keepDQMfile=${11}

##setup environment
cd  ${curDir}
eval `scramv1 runtime -sh`
cd -
echo "CMSSW_BASE=$CMSSW_BASE and pwd=`pwd`"

## Execute job and retrieve the outputs
echo "Job running on `hostname` at `date` from `pwd`"

cfgDir=${curDir}/${outDir}/cfg
cmsRun ${cfgDir}/${cfgFileGSD}
if [ $dataTier = "ALL" ]; then
  cmsRun ${cfgDir}/${cfgFileRECO}
  cmsRun ${cfgDir}/${cfgFileNTUP}
  dataTier="NTUP"
fi

# copy to outDir in curDir or at given EOS area
if [ ${localFlag} == "True" ]
  then
    cp *${dataTier}*.root ${curDir}/${outDir}/${dataTier}/
    if [ ${keepDQMfile} == "True" ]
        then
        cp *DQM*.root ${curDir}/${outDir}/DQM/
    fi
  else
    a=`ls *.root`
    echo "Will copy ${a} to output directory in EOS root://eoscms.cern.ch/${eosArea}/${outDir}/${dataTier}/"
    xrdcp -N -v ${a} root://eoscms.cern.ch/${eosArea}/${outDir}/${dataTier}/Events_${clusterid}_${procid}.root
    if [ ${keepDQMfile} == "True" ]
        then
	echo "Will copy DQM-like ${a} to output directory in EOS"
        xrdcp -N -v *DQM*.root root://eoscms.cern.ch/${eosArea}/${outDir}/DQM/
    fi
    echo "Will copy DQM-like ${a} to output directory in EOS"
fi
