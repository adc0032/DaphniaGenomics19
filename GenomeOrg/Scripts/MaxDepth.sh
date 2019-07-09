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
#PBS -N MaxDepth_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #

#-----------------Define variables------------#
WD="/scratch/bkh0024"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results"
Seq1="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
# ----------------Commands------------------- #
##change directories to working directory
cd $WD

##create variables to name product directory then change directories to product directory
dir=`basename $Seq1|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.DepthValues_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##create variable for our depth file
depth="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/$sp.qc2_Jun_27/$sp.DC.txt"

##commands to output the unique depths in our depth file and sort them so that we know the maximum depth

awk '{print $3}' $depth | sort -n | uniq > $sp.DepthValues.txt

##commands to move up a directory, tar pdir and move it to our save directory
cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
