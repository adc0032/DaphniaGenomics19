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
#PBS -N depth_DpulicariaWI
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load samtools/1.6
module load xz/5.2.2
#module load picard/2.4.1
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/WI_6_USD16091409L_HKFJFDSXX_L3_1.fq"
Bam="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/WI_6.BWA_Jun_27/WI_6.sorted.bam"
# ----------------Commands------------------- #
###Script is used to run samtools flagstat, index the bam file, run samtools depth, mark duplicates
###with Picard tools, and run flagstat again. Be sure to review this script, rename variables,
###and specify the appropriate paths to files.


#move to working location in scratch; checks for/creates quality check product directory (pdir) for our second QC to be zipped
#and returned to your home directory (SD)
cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.newdepth_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

samtools depth -aa $Bam > $sp.DC.txt

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD

