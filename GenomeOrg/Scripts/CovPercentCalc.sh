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
#PBS -N CoveragePercent
##combine standard out and standard error
#PBS -j oe

WD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/ChromosomeOrg/IndividualChrFiles/CovMapData_Jul_18"
totalgenomesize=0
WI_6_0_cov_sites=0
BA_411_0_cov_sites=0

for num in {1..12}
do 
	chrmsizetemp=$(wc -l $WD/chr.$num.depthfin | awk '{print $1}')
	awk '{ if ($4==0) {print} }' $WD/chr.$num.depthfin > WI_6.chrm_$num.temp
	WI_6_chrm=$(wc -l WI_6.chrm_$num.temp | awk '{print $1}')
	echo "WI-6: The number of sites with less than 5x coverage for chromosome $num is $WI_6_chrm" 
	awk '{ if ($5==0) {print} }' $WD/chr.$num.depthfin > BA_411.chrm_$num.temp
	BA_411_chrm=$(wc -l BA_411.chrm_$num.temp | awk '{print $1}')
	echo "BA-411: The number of sites with less than 5x coverage for chromosome $num is $BA_411_chrm" 
	WI_6_chrm_percent_cov=`expr $WI_6_chrm \* 100 / $chrmsizetemp`
	echo "WI-6: The percentage of chromosome $num for which we have less than 5x coverage is $WI_6_chrm_percent_cov %"
	BA_411_chrm_percent_cov=`expr $BA_411_chrm \* 100 / $chrmsizetemp`
	echo "BA-411: The percentage of chromosome $num for which we have less than 5x coverage is $BA_411_chrm_percent_cov %"
	totalgenomesize=`expr $totalgenomesize + $chrmsizetemp`
	WI_6_0_cov_sites=`expr $WI_6_0_cov_sites + $WI_6_chrm`
	BA_411_0_cov_sites=`expr $BA_411_0_cov_sites + $BA_411_chrm` 
done

total_WI_6_percent_cov=`expr $WI_6_0_cov_sites \* 100 / $totalgenomesize` 
echo "WI-6: The percentage of the genome for which we have less than 5x coverage is $total_WI_6_percent_cov %"
total_BA_411_percent_cov=`expr $BA_411_0_cov_sites \* 100 / $totalgenomesize`
echo "BA-411: The percentage of the genome for which have less than 5x coverage is $total_BA_411_percent_cov %"


