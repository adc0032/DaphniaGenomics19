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
#PBS -N bwa_{Organism}
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bwa/0.7.15
module load xz/5.2.2
module load samtools/1.6
#-----------------Define variables------------#
WD="/scratch/userdirectory/"
SD="/pathto/savedirectory/"
Seq1="pathto/sequenceR1analysis.fastq"
Seq2="pathto/sequenceR2analysis.fastq"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #

###Script is used to run bwa on sequence files for mapping to reference. Review script, making sure to fill in your own
###variable information, and paying attention to your desired naming parameters. Assumes paired end data and will need two files.
###User will want to run the fastqc script again to determine how trimming improved (or not) starting material

#move to working location in scratch; checks for/creates bwa product directory (pdir) to be zipped 
#and returned to your home directory (SD)

if [[ $# -lt 1 ]]; then
	echo "Script requires argument for reference name made in index script."
else
	ref="$1"

cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
pdir="$dir.bwa_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir


## -M makes it compatible with picard (downstream program), -v is level of verbosity, -t is the number of threads or ppn
##from above. name of reference needs to be given here-the same name from the index script.
## -R requires readgroups. ID, PU and LB all should be unique if reads were split across lanes-especially.
## samtools steps following the pipe : -Sb converts SAM to BAM, sorts, outputs sorted bam files

bwa mem -M  -v 2 -t 10 -R "@RG\tID:uniqueID\tSM:samplegroup\tPL:illumina\tPU:uniquereadid\tLB:uniquelibraryname" $ref \
$Seq | samtools view -Sb | samtools sort > $dir.sorted.bam;

#Product/output compression and relocation

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
