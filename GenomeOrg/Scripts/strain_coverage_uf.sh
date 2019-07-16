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
#PBS -N coverage_Dpulicaria 
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #

#-----------------Define variables------------#
WD="/scratch/bkh0024"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/ChromosomeOrg/IndividualChrFiles"
Seq1="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/WI_6_USD16091409L_HKFJFDSXX_L3_1.fq"
# ----------------Commands------------------- #
##change directories to working directory
cd $WD

##create variables to name product directory then change directories to product directory
dir=`basename $Seq1|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`
pdir="coverage_map_data_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##making a file that demonstrates whether we have coverage >5x at a given position (0 means no, 1 means yes) for both strains, for each chromosome
for num in {1..12}
do
	awk '{print $3}' $SD/$sp.scaffolds_$cdate/$sp.Cov_Chr_$num.txt > temp1.$num
	awk '{print $3}' $SD/BA_411.scaffolds_$cdate/BA_411.Cov_Chr_$num.txt > temp2.$num
	paste temp1.$num temp2.$num > Cov_Chr_$num.txt
done

##command to remove all of the temp files created
rm temp*

##commands to move up a directory, tar pdir and move it to our save directory
cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
