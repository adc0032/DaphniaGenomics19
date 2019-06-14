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
#PBS -N GATKvc_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #

#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
MDB="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_13/MD_BA_411.sorted.bam"
ref="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/PA42.indices_Jun_8/PA42.fasta"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #

cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.GATKvc_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##place commands to create a vcf of preliminary SNPs with haplotypecaller below
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -R $ref -T HaplotypeCaller -I $MDB -stand_call_conf 20 -o dbsnp_$sp.vcf

##place commands to run base score recalibration below 
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -T BaseRecalibrator -R $ref -I $MDB -knownSites dbsnp_BA_411.vcf -o BQSR_$sp.table

##places commands that run haplotypecaller again with vcf file 
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -R $ref -T HaplotypeCaller -I $MDB --dbsbp dbsnp_$sp.vcf -o rawvar_$sp.vcf

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
