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
#PBS -N scaffolds_DpulicariaWI 
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
pdir="$sp.scaffolds_$cdate"

if [[ ! -d "$pdir" ]]; then
        mkdir $pdir
        cd $pdir
else
        cd $pdir
fi

##create variable for our depth file
depth="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results/$sp.qc2_Jun_27/$sp.DC.txt"

##commands to output the scaffolds that correspond each chromosome from supplemental material, then search for these scaffolds in our depth file, then make a file
##that demonstrates whether we have coverage >5x at a given position (0 means no, 1 means yes)
for num in {1..12}
do
	awk '{print $1}' $SD/Chr.$num.Org.txt | sort | uniq > Scaffolds.Chr.$num.txt
	grep -F -f Scaffolds.Chr.$num.txt $depth > $sp.Depth.Scaff.Chr.$num.txt
	awk 'BEGIN {OFS="\t"} { if ($3 < 5) {print $1,$2,"0"} else {print $1,$2,"1"} }' $sp.Depth.Scaff.Chr.$num.txt > $sp.Cov_Chr_$num.txt
done

##commands to move up a directory, tar pdir and move it to our save directory
cd ..

tar -cvf $pdir.tar $pdir;

mv $pdir.tar $SD
