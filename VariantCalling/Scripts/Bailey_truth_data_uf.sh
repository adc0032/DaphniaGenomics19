#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=4gb,walltime=120:00:00
##email
#PBS -M baileykhowell@gmail.com
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N TruthData_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load vcftools/v0.1.17
module load xz/5.2.2
module load java/1.8.0_91
module load gatk/4.1.2.0
#-----------------Define variables------------#
WD="/scratch/bkh0024"
SD="/home/bkh0024/DaphniaGenomics19/VariantCalling/Results"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
MDB="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_27/MD_BA_411.sorted.bam"
ref="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/our_fasta/Daphnia_pulex.indices_Jun_27/Daphnia_pulex.fa"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #
###Script is used to pre-process data for GATK
cd $WD
##commands to name product directory below using variable names
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.TruthData_$cdate"
bam2=`basename $MDB`
##commands to change directory to the product directory 
if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##place commands to create a vcf of preliminary SNPs with haplotypecaller below
gatk --java-options "-Xmx4g" HaplotypeCaller -R $ref -I $MDB -O 0_$sp.vcf;

vcftools --site-depth --vcf 0_$sp.vcf --out 0_site_depth
vcftools --site-quality --vcf 0_$sp.vcf --out 0_site_quality

#outputs site_depth.ldepth and site_quality.lqual
#then pipe this output to the script

cat 0_site_quality.lqual | /home/bkh0024/DaphniaGenomics19/vcf_cutoff_stats.R > 0_vcf_quality_summary.txt
cat 0_site_depth.ldepth | /home/bkh0024/DaphniaGenomics19/vcf_cutoff_stats.R > 0_vcf_depth_summary.txt

##place commands below to filter vcf file using vcftools
#vcftools --vcf 0_$sp.vcf --recode --recode-INFO-all --out 0_$sp.recode.vcf

##place commands to run base score recalibration below 
#gatk --java-options "-Xmx4g" BaseRecalibrator -R $ref -I $MDB -knownSites 0_$sp.recode.vcf -O 0_recal_$bam2

##place commands that run haplotypecaller again with recalibrated bam 
#gatk --java-options "-Xmx4g" HaplotypeCaller -R $ref -I 0_recal_$bam2 -O 1_$sp.recal.vcf

#vcftools --vcf 1_$sp.recal.vcf --recode --recode-INFO-all --out 1_$sp.recal.recode.vcf

#/tools/samtools-1.3.1/bin/bgzip 0_$sp.recode.vcf
#/tools/samtools-1.3.1/bin/tabix -p vcf 0_$sp.recode.vcf.gz
#/tools/samtools-1.3.1/bin/bgzip 1_$sp.recal.recode.vcf
#/tools/samtools-1.3.1/bin/tabix -p vcf 1_$sp.recal.recode.vcf.gz

#/tools/vcftools-v0.1.14-14/bin/vcf-compare 0_$sp.recode.vcf.gz 1_$sp.recal.recode.vcf.gz > compare_recode0v1_summary.txt

##repeat the commands above starting at line 49 until there is 99.9% similiarity

#cd ..

#tar -cvf $pdir.tar $pdir;

#mv $pdir.tar $SD

#cd $SD

#tar -xvf $pdir.tar
