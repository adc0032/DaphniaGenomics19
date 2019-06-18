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
module load vcftools/v0.1.14
module load xz/5.2.2
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
MDB="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_16/MD_BA_411.sorted.bam"
ref="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/PA42.indices_Jun_8/PA42.fasta"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #
###Script is used to call variants using GATK
cd $WD
##commands to name product directory below using variable names
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.GATKvc_$cdate"

##commands to change directory to the product directory 
if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##copying the index for bam WD (may not be necessary-test)
cp $SD/MD_BA_411.sorted.bai .

##place commands to create a vcf of preliminary SNPs with haplotypecaller below
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -R $ref -T HaplotypeCaller -I $MDB -o basevar_$sp.recode.vcf

##place commands below to filter vcf file using vcftools
vcftools --vcf basevar_$sp.vcf --recode --recode-INFO-all --out basevar_$sp.recode.vcf

##place commands to run base score recalibration below 
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -T BaseRecalibrator -R $ref -I $MDB -knownSites basevar_$sp.recode.vcf -o recal_MD_BA_411.sorted.bam

##place commands that run haplotypecaller again with filtered vcf file 
java -Xms2g -Xmx14g -jar /tools/gatk-4.0.10.1/GenomeAnalysisTK.jar -R $ref -T HaplotypeCaller -I $MDB --dbsbp basevar_$sp.recode.vcf -o recalvar_$sp.recode.vcf

/tools/samtools-1.3.1/bin/bgzip basevar_$sp.recode.vcf
/tools/samtools-1.3.1/bin/tabix -p vcf basevar_$sp.recode.vcf.gz
/tools/samtools-1.3.1/bin/bgzip recalvar_$sp.recode.vcf
/tools/samtools-1.3.1/bin/tabix -p vcf recalvar_$sp.recode.vcf.gz

/tools/vcftools-v0.1.14-14/bin/vcf-compare basevar_$sp.recode.vcf.gz recalvar_$sp.recode.vcf.gz > compare_recode1v2_summary.txt

##repeat the commands above starting at line 49 until there is 99.9% similiarity

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
