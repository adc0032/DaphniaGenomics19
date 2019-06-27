#! /bin/bash

#files that include information on scaffold by chromosome and scaffold size from fai index
chrfile="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome/File_S1.txt"
faifile="/home/adc0032/DaphniaGenomics19/PA42_sh.fasta.fai"

#header for outputfile
echo -e "chromosome\tchr_size" > hard_chr_size.txt

#loop through 1 - 12
for num in {1..12}
do
	echo "Calculating chromosome size for chromsome $num..." # for user
	#parsing chrfile by individual chromosome, creates temp file
	awk -v num="$num" 'NR>1 && $4==num {print}' $chrfile|awk '{print $1}'|sort|uniq > chr_$num.scafflist 
	#loop through tempfile by each scaffold
	for scaff in $(cat chr_$num.scafflist)
	do
		#look for scaffold variable in faifile and print size into temp file
		grep -w "$scaff" $faifile|awk '{print $2}' >> scaff_size_$num
	done
	#awk to sum sizes in second temp file
	chrsize=`awk '{sum+=$1}END{print sum}' scaff_size_$num`
	#add chromosome number and size to outputfile
	echo -e "chr_$num\t$chrsize" >> hard_chr_size.txt
done

#removing all temp files; may want to comment these lines out on the first pass to make sure outputs in temp files are as expected
rm scaff_size_*
rm chr_*.scafflist

echo "Size calculations complete, see file: hard_chr_size.txt for results" #for user

