#!/bin/bash
#REFERENCE
#https://github.com/florez/CONDOR
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_file> <output_dir> " >&2
  exit 1
fi
if ! [ -e "$1" ]; then
  echo "$1 not found" >&2
  exit 1
fi
if ! [ -d "$2" ]; then
  echo "$1 not a directory" >&2
  exit 1
fi

#------------------------------------------------
#create a directory where all the outputs will be
#stored, for different merged ntuple input files
#------------------------------------------------
file=$1
file_outputdir=$2
#voms-proxy-init --voms cms --valid 100:10
#cp /tmp/x509up_u56567 ~/"

#log="CondorLog_"
#logDir=$log${file/.txt/""}
#baseDir="/home/mikumar/t3store3/workarea/CMSSW_9_3_2/src/single_Electron_analysis/shelloutput/muon/MC/Allremaing1/log_cond"
#
localdir="$(cut -d'.' -f1 <<<"$1")" # this will spilt $1 where ever "." has been fould
baseDir="/grid_mnt/t3storage3/mikumar/Run2/SIXTEEN/minitree/condor_job/Condor_jobs_T2_$(cut -d'_' -f2 <<<"$localdir")_$(date +"%d-%m-%Y")_$(cut -d'_' -f3 <<<"$localdir")_$(cut -d'_' -f4 <<<"$localdir")"
echo $localdir
echo $baseDir 
#baseDir="/home/mikumar/tryout2/out_log_$(cut -d'_' -f2 <<<"$1")_$(date +"%d-%m-%Y")"
mkdir -p $baseDir
#$logDir
outcond="$baseDir"
#$logDir"

cp condorSetup.sub $outcond
cp runAtCondor.sh $outcond
cp $file $outcond
cd $outcond

#------------------------------------------------
#------------------------------------------------
count=0
cat $file | while read ntupleT2Path
do
  #----------------------------------------------
  #----------------------------------------------
  ((count++))
  echo -e "\033[01;32m input ntuple=\033[00m" $count": " $ntupleT2Path
 
  #----------------------------------------------
  #----------------------------------------------
  
  mkdir -p $count
  cp condorSetup.sub $count
  cp runAtCondor.sh $count
  cd $count
  #input="$ntupleT2Path Minitree_$(cut -d'/' -f11 <<<"$ntupleT2Path")_$(cut -d'/' -f10 <<<"$ntupleT2Path") $file_outputdir" #Output file name has to be modified accordingly 
  input="$ntupleT2Path Minitree_$(cut -d'/' -f9 <<<"$ntupleT2Path") $file_outputdir"
  echo $input
  sed -i "s:INPUT:$input:g" condorSetup.sub

  condor_submit condorSetup.sub
  cd ../
done
