#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=16gb,walltime=120:00:00
##email
#PBS -M adc0032@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N BA_truthdata
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load vcftools/v0.1.17
module load xz/5.2.2
module load java/1.8.0_91
module load gatk/4.1.2.0
#-----------------Define variables------------#
WD="/scratch/adc0032/"
SD="/home/adc0032/DaphniaGenomics19/GenomeOrg/Results"
Seq="/home/adc0032/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
MDB="/home/adc0032/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_27/MD_BA_411.sorted.bam"
ref="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome/Dpulex.scaffolds.fa"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #


###Script is used to create truth dataset for BQSR

cd $WD

##commands to name product directory below using variable names
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.Truth_$cdate"

##commands to change directory to the product directory 
if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi


##place commands to create a vcf of preliminary SNPs with haplotypecaller below
gatk --java-options "-Xmx14G" HaplotypeCaller -R $ref -I $MDB -o 0_$sp.vcf

##determining filtering parameters using r-script
/tools/vcftools-v0.1.17/bin/vcftools --site-depth --vcf 0_$sp.vcf --out site_depth_$sp
cat site_depth_$sp.ldepth | /home/adc0032/UsefulBioinformaticScripts/vcf_cutoff_stats.R > vcf_depth_summary_$sp.txt
/tools/vcftools-v0.1.17/bin/vcftools --site-quality --vcf SRR330100.vcf --out site_quality_$sp
cat site_quality_$sp.lqual | /home/adc0032/UsefulBioinformaticScripts/vcf_cutoff_stats.R > vcf_quality_summary_$sp.txt


##filtering 1st vcf file using vcftools
#vcftools --vcf 0_$sp.vcf --recode --recode-INFO-all --out 0_$sp.recode.vcf

##place commands to run base score recalibration below 
#gatk --java-options "-Xmx14G" BaseRecalibrator -R $ref -I $MDB -knownSites 0_$sp.recode.vcf -o 0_recal_$sp.bam

##running haplotypecaller on the recalibrated bam from bqsr 
#gatk --java-options "-Xmx14G" HaplotypeCaller -R $ref -I 0_recal_$sp.bam -o 1_$sp.vcf

##filtering vcf from 1st recal run
#vcftools --vcf 0_$sp.vcf --recode --recode-INFO-all --out 1_$sp.recode.vcf

##file prep for vcf compare
#/tools/samtools-1.3.1/bin/bgzip 0_$sp.recode.vcf
#/tools/samtools-1.3.1/bin/tabix -p vcf 0_$sp.recode.vcf.gz
#/tools/samtools-1.3.1/bin/bgzip 1_$sp.recode.vcf
#/tools/samtools-1.3.1/bin/tabix -p vcf 1_$sp.recode.vcf.gz

#/tools/vcftools-v0.1.17/bin/vcf-compare 0_$sp.recode.vcf.gz 1_$sp.recode.vcf.gz > compare_recode0v1_summary.txt

##repeat the commands above starting at line 49 until there is 99.9% similiarity

#cd ..

#tar -cvf $pdir.tar $pdir;

#mv $pdir.tar $SD
