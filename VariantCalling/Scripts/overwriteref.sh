#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=10,mem=14gb,walltime=120:00:00
##email
#PBS -M adc0032@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N BA_truthdata
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bedtools/2
module load vcftools/v0.1.14-14
module load bcftools
module load perl/5.26.0
module load xz/5.2.2
module load python/2.7.12
module load java/1.8.0_91
module load htslib
module load samtools/1.3.1
#-----------------Define variables------------#
WD="/scratch/adc0032/"
SD="/home/adc0032/DaphniaGenomics19/GenomeOrg/Results"
Seq="/home/adc0032/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
snp="path/to/snp.vcf"
ind="/path/to/indel.vcf"
ref="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome/Dpulex.scaffolds.fa"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #

###This script is used to get a consensus genome fasta from reference-mapped reads. 
###Requires: variants from sample species, indels from sample species, reference sample species was mapped to
###Outputs: fasta with variant positions updated, gaps and indels filled with Ns

#BGZIP and index snp file
/tools/samtools-1.3.1/bin/bgzip $snp
bcftools index $snp.gz

#updating variant sites on reference using sample snps
bcftools consensus -f $ref $snp.gz -o $sp.snp.fa

#masking gap and indel regions
bedtools genomecov -ibam MD_BA_411.sorted.bam -bga |awk '$4 == 0' > $sp.mdbam_zero.bed
zero="./$sp.mdbam_zero.bed"

bedtools maskfasta -fi basnp.fa -bed $ind -fo $sp.fa
bedtools maskfasta -fi $sp.fa -bed $zero -fo $sp.fin.fa
