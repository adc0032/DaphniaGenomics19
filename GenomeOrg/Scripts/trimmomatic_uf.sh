#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=10,mem=100gb,walltime=96:00:00
##email
#PBS -M adc0032@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N trimmomatic_{Organism}
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load trimmomatic/0.36
#-----------------Define variables------------#
WD="/scratch/userdirectory/"
SD="/pathto/savedirectory/"
Seq1="pathto/sequenceR1analysis.fastq"
Seq2="pathto/sequenceR2analysis.fastq"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #

###Script is used to run trimmomatic on sequence files for removing low quality/adaptor regions. Review script, making sure to fill in your own
###variable information, and paying attention to your desired trimming parameters. Assumes paired end data and will need two files.
###User will want to run the fastqc script again to determine how trimming improved (or not) starting material

#move to working location in scratch; checks for/creates fastqc product directory (pdir) to be zipped and returned to your home directory (SD)

cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
pdir="$dir.trimmomatic_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir

java -jar /tools/trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 10 -phred33 -trimlog trim_$dir $Seq1 $Seq2  -baseout trim_$dir.fastq  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 HEADCROP:5 LEADING:28 TRAILING:28 SLIDINGWINDOW:6:28 MINLEN:35;

#Product/output compression and relocation

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
