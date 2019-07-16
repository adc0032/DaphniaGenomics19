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
MDB="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_27/MD_BA_411.sorted.bam"
ref="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/our_fasta/Daphnia_pulex.indices_Jun_27/Daphnia_pulex.fa"
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
#cp $SD/MD_BA_411.sorted.bai .

##place commands to create a gvcf of SNPs and indels with haplotypecaller below then split this vcf into SNPs and INDELs
gatk --java-options "-Xmx100g" HaplotypeCaller --reference $ref --input $MDB --ERC GVCF --output basevar_$sp.vcf;

gatk SelectVariants --reference $ref --variant basevar_$sp.vcf --select-type-to-include SNP --output baseSNPs_$sp.vcf;

gatk SelectVariants --reference $ref --variant basevar_$sp.vcf --select-type-to-include INDEL --output baseINDELs_$sp.vcf;


gatk VariantFiltration --reference $ref --variant baseSNPs_$sp.vcf \
--filter-expression "QD < 2.0" --filter-name "QD2" \
--filter-expression "QUAL < 30.0" --filter-name "QUAL30" \
--filter-expression "SOR > 3.0" --filter-name "SOR3" \
--filter-expression "FS > 60.0" --filter-name "FS60" \
--filter-expression "MQ < 40.0" --filter-name "MQ40" \
--filter-expression "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
--filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
--output filteredSNPs_$sp.vcf

gatk VariantFiltration --reference $ref --variant baseINDELs_$sp.vcf \
--filter-expression "QD < 2.0" --filter-name "QD2" \
--filter-expression "QUAL < 30.0" --filter-name "QUAL30" \
--filter-expression "FS > 200.0" --filter-name "FS200" \
--filter-expression "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
--output filteredINDELs_$sp.vcf


cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
