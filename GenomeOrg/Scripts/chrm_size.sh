#! /bin/bash


chrfile="/home/adc0032/DaphniaGenomics19/GenomeOrg/ReferenceGenome/File_S1.txt"
faifile="/home/adc0032/DaphniaGenomics19/PA42_sh.fasta.fai"

echo -e "chromosome\tchr_size" > hard_chr_size.txt

for num in {1..12}
do
	echo "Calculating chromosome size for chromsome $num..."
	awk -v num="$num" 'NR>1 && $4==num {print}' $chrfile|awk '{print $1}'|sort|uniq > chr_$num.scafflist
	for scaff in $(cat chr_$num.scafflist)
	do
		grep -w "$scaff" $faifile|awk '{print $2}' >> scaff_size_$num
	done
	chrsize=`awk '{sum+=$1}END{print sum}' scaff_size_$num`
	echo -e "chr_$num\t$chrsize" >> hard_chr_size.txt
done

echo "Size calculations complete, see file: hard_chr_size.txt for results"

