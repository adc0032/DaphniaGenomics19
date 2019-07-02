# bin/bash

echo -e "Chr_num\tChr_size" > chromosome_size.txt

for file in $(ls ./Chr.*.Org.txt)
do
	chr_size=`awk '{print $3 - $2}' $file | sed 's/-//g' | awk '{sum+=$1} END {print sum}'`
	chr_num=`awk '{print $4}' $file | uniq`
	echo -e "$chr_num\t$chr_size" >> chromosome_size.txt
done
