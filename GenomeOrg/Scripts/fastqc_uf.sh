#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=4gb,walltime=10:00:00
##email
#PBS -M adc0032@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N fastqc_{Organism}
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load fastqc/11.5
#-----------------Define variables------------#
WD="/scratch/userdirectory/"
SD="/pathto/savedirectory/"
Seq="pathto/sequenceforanalysis.fasta"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
# ----------------Commands------------------- #

###Script is used to run fastqc on sequence files for quality statistics and information. Review script, making sure to fill in your own 
###variable information, and paying attention to the two options of feeding data to fastqc (zcat compressed option is commented out)

#move to working location in scratch; checks for/creates fastqc product directory (pdir) to be zipped and returned to your home directory (SD) 

cd $WD
dir=`basename $Seq|awk -F. '{print $1}'`
pdir="$dir.fastqc_$cdate"

if [[ ! -d "$pdir" ]]; then
	mkdir $pdir
	cd $pdir
else
	cd $pdir
fi

##seq file will need to be decompressed before feeding it to fastqc using the code below
#fastqc analysis, option 1, can list multiple sequences (ex fastqc -t 4 $Seq $Seq2 $Seq3)

fastqc -t 4 $Seq;


##if you plan to leave the file compressed, you will need to use the following syntax
#fastqc analysis, option 2, not tested with multiple files

# zcat $Seq|fastqc -t 4 stdin;

#Product/output compression and relocation

cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
