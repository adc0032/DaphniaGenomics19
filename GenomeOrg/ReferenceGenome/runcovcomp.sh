#! /bin/bash

module load R/3.4.3

R --vanilla < coverage_comp.R

for num in {2..12}
do
	prv=`expr $num - 1`
	sed -ie "s/chr.$prv/chr.$num/g" "coverage_comp.R"
	R --vanilla <coverage_comp.R
done
