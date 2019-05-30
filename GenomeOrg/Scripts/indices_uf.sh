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
#PBS -N indices_{Organism}
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bwa/0.7.15
module load samtools/1.6
module load xz/5.2.2
module load picard/2.4.1
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/userdirectory/"
SD="/pathto/savedirectory"
Seq="pathto/sequenceanalysis.fasta"
# ----------------Commands------------------- #

cd $WD

## command to create index reference genome
bwa index $ref -a bwtsw $Seq

## command to create index for samtools
samtools faidx $Seq

## command to create index for picard tools
java -Xms2g -Xmx14g -jar /tools/picard-tools-2.4.1/picard.jar CreateSequenceDictionary R=$Seq O=$ref.dict 
