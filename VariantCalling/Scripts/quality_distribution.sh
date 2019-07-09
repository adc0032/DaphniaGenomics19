#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=16gb,walltime=120:00:00
##email
#PBS -M baileykhowell@gmail.com
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N SQ_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
#-----------------Define variables------------#
WD="/scratch/bkh0024/BA_411.TruthData_Jul_8/"
SD="/home/bkh0024/DaphniaGenomics19/"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #
###Script is used to call variants using GATK
cd $WD
##commands to name product directory below using variable names
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.sitequal_$cdate"

##commands to change directory to the product directory 
if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

cat ../0_site_quality.lqual | /home/bkh0024/DaphniaGenomics19/quality_distribution.R

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
