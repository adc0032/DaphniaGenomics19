#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=16gb,walltime=70:00:00:00
##email
#PBS -M baileykhowell@gmail.com
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N bwa_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bwa/0.7.15
module load xz/5.2.2
module load samtools/1.6
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/"
Seq1="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
Seq2="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_2.fq"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
ref="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/PA42.indices_June_8/PA42.fasta"
# ----------------Commands------------------- #

###Script is used to run bwa on sequence files for mapping to reference. Review script, making sure to fill in your own
###variable information, and paying attention to your desired naming parameters. Assumes paired end data and will need two files.
###User may want to add readgroups to this step, but also (theoretially) can be done in picard tools.

## to be used in a different setting. 
#if [[ $# -lt 1 ]]; then
#	echo "Script requires argument for reference name made in index script. This would be the prefix provided to indices_uf.sh (ex. qsub )"
#else
#	ref="$1"

#move to working location in scratch; checks for/creates bwa product directory (pdir) to be zipped 
#and returned to your home directory (SD)

cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="$sp.bwa_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir


## -M makes it compatible with picard (downstream program), -v is level of verbosity, -t is the number of threads or ppn
##from above. name of reference needs to be given here-the same name from the index script.
## -R requires readgroups. ID, PU and LB all should be unique if reads were split across lanes-especially.
## samtools steps following the pipe : -Sb converts SAM to BAM, sorts, outputs sorted bam files

bwa mem -M  -v 3 -t 4 -R "@RG\tID:HKFJFDSXX3\tSM:BA411\tPL:illumina\tPU:HKFJFDSXX8L3\tLB:USD16091408L" $ref $Seq $Seq2 | samtools view -Sb | samtools sort > $sp.sorted.bam;

#Product/output compression and relocation

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
