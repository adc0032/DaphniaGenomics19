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
#PBS -N Job Name
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #

#-----------------Define variables------------#
WD=
SD=
Seq=
# ----------------Commands------------------- #

cd $WD

mv *.o* ~/2019_Bioinformatics/dotOjob
