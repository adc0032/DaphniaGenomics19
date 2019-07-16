#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=20,mem=100gb,walltime=120:00:00
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
module load samtools/1.3.1
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
pdir="3SD_$sp.TruthData_$cdate"
bam2=`basename $MDB`
##commands to change directory to the product directory 
if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##place commands to create a vcf of preliminary SNPs with haplotypecaller below
#gatk --java-options "-Xmx100g" HaplotypeCaller --reference $ref --input $MDB --output 0_$sp.vcf;

#vcftools --site-depth --vcf 0_$sp.vcf --out 0_site_depth
#vcftools --site-quality --vcf 0_$sp.vcf --out 0_site_quality

#outputs site_depth.ldepth and site_quality.lqual
#then pipe this output to the script

#cat 0_site_quality.lqual | /home/bkh0024/DaphniaGenomics19/vcf_cutoff_stats.R > 0_vcf_quality_summary.txt
#cat 0_site_depth.ldepth | /home/bkh0024/DaphniaGenomics19/vcf_cutoff_stats.R > 0_vcf_depth_summary.txt

##place commands below to filter vcf file using vcftools
vcftools --vcf 0_$sp.vcf --minQ 100 --minDP 30 --maxDP 183 --minGQ 90 --min-alleles 2 --max-missing 1 --recode --recode-INFO-all --out 0_$sp

##place commands below to index the recoded vcf
gatk IndexFeatureFile -F 0_$sp.recode.vcf 

##place commands to run base score recalibration below 
gatk --java-options "-Xmx100g" BaseRecalibrator --reference $ref --input $MDB --known-sites 0_$sp.recode.vcf --output 0_recal_$sp.table
gatk ApplyBQSR -R $ref -I $MDB --bqsr-recal-file 0_recal_$sp.table -O 0_recal_$bam2

##place commands that run haplotypecaller again with recalibrated bam 
gatk --java-options "-Xmx100g" HaplotypeCaller --reference $ref --input 0_recal_$bam2 --output 1_$sp.recal.vcf

vcftools --vcf 1_$sp.recal.vcf --minQ 100 --minDP 30 --maxDP 183 --minGQ 90 --min-alleles 2 --max-missing 1 --recode --recode-INFO-all --out 1_$sp.recal

##place commands below to index the recoded vcf
gatk IndexFeatureFile -F 1_$sp.recal.recode.vcf

gatk --java-options "-Xmx100g" BaseRecalibrator --reference $ref --input 0_recal_$bam2 --known-sites 1_$sp.recal.recode.vcf --output 1_recal_$sp.table;
gatk AnalyzeCovariates -before 0_recal_$sp.table -after 1_recal_$sp.table -plots 0_1_$sp.AnalyzeCovariates.pdf

/tools/samtools-1.3.1/bin/bgzip 0_$sp.recode.vcf 
/tools/samtools-1.3.1/bin/tabix -p vcf 0_$sp.recode.vcf.gz
/tools/samtools-1.3.1/bin/bgzip 1_$sp.recal.recode.vcf 
/tools/samtools-1.3.1/bin/tabix -p vcf 1_$sp.recal.recode.vcf.gz

/tools/vcftools-v0.1.14-14/bin/vcf-compare 0_$sp.recode.vcf.gz 1_$sp.recal.recode.vcf.gz > compare_recode0v1_summary.txt

##repeat the commands above starting at line 49 until there is 99.9% similiarity

#cd ..

#tar -cvf $pdir.tar $pdir;

#mv $pdir.tar $SD

#cd $SD

#tar -xvf $pdir.tar
