#! /bin/bash

# ----------------QSUB Parameters----------------- #
##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=4,mem=16gb,walltime=120:00:00
##email
#PBS -M adc0032@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N Job_Name
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
#-----------------Define variables------------#
WD="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome"
SD=
Seq=
# ----------------Commands------------------- #

cd $WD
##files that include information on scaffold by chromosome and scaffold size from fai index
#chrfile="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome/File_S1.txt"
depthfile="/home/adc0032/DaphniaGenomics19/GenomeOrg/Results/BA_411.qc2_Jun_27/BA_411.DC.txt"

##header for outputfile
#echo -e "chromosome\tchr_size" > hard_chr_size.txt

##loop through 1 - 12
for num in {4..12}
do
	echo "Parsing for chromsome $num..." # for user
	#parsing chrfile by individual chromosome, creates temp file
	#awk -v num="$num" 'NR>1 && $4==num {print}' $chrfile|awk '{print $1}'|sort|uniq > chr_$num.scafflist 
	#loop through tempfile by each scaffold
	for scaff in $(cat chr_$num.scafflist)
	do
		#look for scaffold variable in faifile and print size into temp file
		grep -w "$scaff" $depthfile >> chr.$num.rawdepth
	done

	echo -e "Pos\tScaff\tPA42\tBA411\tWI6" > chr.$num.depthfin
	awk '$1=(FNR FS $1)' chr.$num.rawdepth|awk '{$3=1 ; print ;}'|awk '{if ($4 > 5 ) $4=0.8 ; print ;}'|awk '{if ($4 < 5 ) $4=0 ; print ;}'| \
	awk '{if ($4 == 5 ) $4=0.8 ; print ;}'|awk '{$5 = $4} 1'|awk '{if ($5 == 0.8) $5=0.6 ; print ;}' >> chr.$num.depthfin
done

##removing all temp files; may want to comment these lines out on the first pass to make sure outputs in temp files are as expected
#rm 
#rm chr_*.scafflist

echo "Depth calculations complete, see files in directory for use in plotting results" #for user


#awk '{$4 = $3} 1' chr11_deptheq > chr11_depthfin
#awk '{if ($3 == 5 ) $3=1 ; print ;}' < chr11_depthlt > chr11_deptheq
#awk '{if ($3 < 5 ) $3=0 ; print ;}' < chr11_depthgt > chr11_depthlt
#awk '{if ($3 > 5 ) $3=1 ; print ;}' < chr11_depthref > chr11_depthgt
#awk '{$2=1 ; print ;}' < chr11_depth > chr11_depthref

