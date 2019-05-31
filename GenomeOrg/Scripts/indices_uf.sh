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
#PBS -N indices_Dpulex
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bwa/0.7.15
module load samtools/1.6
module load xz/5.2.2
module load picard/2.4.1
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/PA42.fasta"
cdate=`date|awk 'OFS="_"{print $2,$3}'
ref="dpulex"
# ----------------Commands------------------- #

##Script is used to create indices reference genomes for bwa, samtools, and picardtools. Review 
##Script make sure to replace relevant information with your own. 

##Move to the working directory in scratch
cd $WD

##Makes variable directory from stripped sequence name (the part before the period only)
dir=`basename $Seq|awk -F. '{print $1}'

##Sets product directory variable to be named with stripped sequence name followed by date info
pdir="$dir.indices_$cdate"

##Test to see if product directory already exists, if not make it then cd into it, otherwise cd to it
if [[ ! -d "$pdir" ]]; then
	mkdir $pdir
	cd $pdir
else
	cd $pdir
fi

## command to create index reference genome
bwa index $ref -a bwtsw $Seq

## command to create index for samtools
samtools faidx $Seq

## command to create index for picard tools
java -Xms2g -Xmx14g -jar /tools/picard-tools-2.4.1/picard.jar CreateSequenceDictionary R=$Seq O=$ref.dict 
