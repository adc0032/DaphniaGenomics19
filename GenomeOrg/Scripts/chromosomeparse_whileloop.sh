#! /bin/bash


#-----------------Define variables------------#
c=1
# ----------------Commands------------------- #


while [ $c -le 12 ]
do
	awk -v counter=$c '{ if ($4 == counter) { print } }' File_S1.txt > Chr.$c.Org.txt
	c=$[$c+1]
done
cd IndividualChrFiles 
mv ../Chr.* .
