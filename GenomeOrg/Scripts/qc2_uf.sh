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
#PBS -N qc2_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load samtools/1.6
module load xz/5.2.2
module load picard/2.4.1
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
Bam="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/BA_411.bwa_Jun_10/BA_411.sorted.bam"
# ----------------Commands------------------- #
###Script is used to run samtools flagstat, index the bam file, run samtools depth, mark duplicates
###with Picard tools, and run flagstat again. Be sure to review this script, rename variables,
###and specify the appropriate paths to files.


#move to working location in scratch; checks for/creates quality check product directory (pdir) for our second QC to be zipped
#and returned to your home directory (SD)
cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.qc2_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##place commands to create an index for the bam file below
samtools index -b $Bam $sp.bam.bai

##place commands for samtools flagstat below
samtools flagstat $Bam > $sp.bam_flagstats

##place commands to run samtools depth below along with code to calculate ref genome size and average coverage
genome_size=`awk '{genome_size+=$2} END {print genome_size}' /home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/PA42.indices_Jun_8/PA42.fasta.fai`
samtools depth $Bam > $sp.DC.txt 
sum=`awk '{sum+=$3}' $sp.DC.txt` *
AverageCov=`expr $sum / $genome_size`
echo $AverageCov >> $sp.DC.txt *

##place commands for picard tools below
java -Xms2g -Xmx16g -jar /tools/picard-tools-2.4.1/picard.jar MarkDuplicates I=$Bam O=MD_$sp.sorted.bam M=MD_$sp.metrics.txt

##place commands for running flagstat on marked duplicates bam file below
samtools flagstat MD_$sp.sorted.bam > MD_$sp.bam_flagstats

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD

