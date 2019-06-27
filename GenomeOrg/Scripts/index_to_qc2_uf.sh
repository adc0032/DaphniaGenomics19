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
#PBS -N index_Dpulex_to_qc2_DpulicariaBA
##combine standard out and standard error
#PBS -j oe
# ----------------Load Modules-------------------- #
module load bwa/0.7.15
module load samtools/1.6
module load xz/5.2.2
module load picard/2.4.1
module load java/1.8.0_91
#-----------------Define variables------------#
WD="/scratch/bkh0024/"
RD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/our_fasta"
SD="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Results"
Seq="/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/our_fasta/Daphnia_pulex.scaffolds.fa"
cdate=`date|awk 'OFS="_"{print $2,$3}'`
ref="Daphnia_pulex"
Seq1="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_1.fq"
Seq2="/home/bkh0024/DaphniaGenomics19/GenomeOrg/Data/BA_411_USD16091408L_HKFJFDSXX_L3_2.fq"
# ----------------Commands------------------- #

##Script is used to create indices reference genomes for bwa, samtools, and picardtools. Review
##Script make sure to replace relevant information with your own.

##Move to the working directory in scratch
cd $WD

##Makes variable directory from stripped sequence name (the part before the period only)
dir=`basename $Seq1|awk -F. '{print $1}'`
sp=`echo $dir|awk -F_ 'OFS="_"{print $1,$2}'`


ind="$ref.indices_$cdate"
if [[ ! -d "$ind" ]]; then
        mkdir $ind
        cd $ind
else
        cd $ind
fi

## command to create index reference genome
bwa index -p $ref -a bwtsw $Seq

## command to create index for samtools
samtools faidx $Seq

## command to create index for picard tools
java -Xms2g -Xmx14g -jar /tools/picard-tools-2.4.1/picard.jar CreateSequenceDictionary R=$Seq O=$ref.dict

#Product/output compression and relocation

cd ..

tar -cvf $ind.tar $ind;

mv $ind.tar $RD

cd $RD

tar -xvf $ind.tar;

cd $ind

mv ../Daphnia_pulex.* .

###this portion is used to run bwa on sequence files for mapping to reference. Review script, making sure to fill in your own
###variable information, and paying attention to your desired naming parameters. Assumes paired end data and will need two files.
###User may want to add readgroups to this step, but also (theoretially) can be done in picard tools.

## to be used in a different setting.
#if [[ $# -lt 1 ]]; then
#	echo "Script requires argument for reference name made in index script. This would be the prefix provided to indices_uf.sh (ex. qsub )"
#else
#	ref="$1"

#move to working location in scratch; checks for/creates bwa product directory (bwa) to be zipped
#and returned to your home directory (SD)

cd $WD
bwa="$sp.BWA_$cdate"
if [[ ! -d "$bwa" ]]; then
        mkdir $bwa
        cd $bwa
else
        cd $bwa
fi

#Moving necessary files to scratch location
cp $RD/$ind/Daphnia_pulex.* .
## -M makes it compatible with picard (downstream program), -v is level of verbosity, -t is the number of threads or ppn
##from above. name of reference needs to be given here-the same name from the index script.
## -R requires readgroups. ID, PU and LB all should be unique if reads were split across lanes-especially.
## samtools steps following the pipe : -Sb converts SAM to BAM, sorts, outputs sorted bam files

bwa mem -M  -v 3 -t 4 -R "@RG\tID:HKFJFDSXX3\tSM:BA411\tPL:illumina\tPU:HKFJFDSXX8L3\tLB:USD16091408L" $ref $Seq1 $Seq2 | samtools view -Sb | samtools sort > $sp.sorted.bam;

#Product/output compression and relocation
rm Daphnia_pulex.* 
cd ..

tar -cvf $bwa.tar $bwa;

mv $bwa.tar $SD

tar -xvf $SD/$bwa.tar; 

Bam="$SD/$bwa/BA_411.sorted.bam"

###this portion is used to run samtools flagstat, index the bam file, run samtools depth, mark duplicates
###with Picard tools, and run flagstat again. Be sure to review this script, rename variables,
###and specify the appropriate paths to files.


#move to working location in scratch; checks for/creates quality check product directory (qual) for our second QC to be zipped
#and returned to your home directory (SD)
cd $WD

qual="$sp.qc2_$cdate"
if [[ ! -d "$qual" ]]; then
        mkdir $qual
        cd $qual
else
        cd $qual
fi

##place commands to create an index for the bam file below
samtools index -b $Bam $sp.bam.bai;

##place commands for samtools flagstat below
samtools flagstat $Bam > $sp.bam_flagstats;

##place commands to run samtools depth below along with code to calculate ref genome size and average coverage
genome_size=`awk '{genome_size+=$2} END {print genome_size}' $RD/$ind/Daphnia_pulex.scaffolds.fa.fai`
samtools depth -a $Bam > $sp.DC.txt
awk '{sum+=$3; sumsq+=$3*$3} END {print "Standard deviation = ",sqrt(sumsq/156418198 -(sum/156418198)**2)}' $sp.DC.txt > Avg_Stdv_$sp.txt
sum=`awk '{sum+=$3} END {print sum}' $sp.DC.txt`
AverageCov=`expr $sum / $genome_size`
echo "Average coverage = " $AverageCov >> Avg_Stdv_$sp.txt

##place commands for picard tools below
java -Xms2g -Xmx16g -jar /tools/picard-tools-2.4.1/picard.jar MarkDuplicates I=$Bam O=MD_$sp.sorted.bam M=MD_$sp.metrics.txt;

##place commands for running flagstat on marked duplicates bam file below
samtools flagstat MD_$sp.sorted.bam > MD_$sp.bam_flagstats;

##places commands below to build a bam index for our marked duplicates bam
java -jar /tools/picard-tools-2.4.1/picard.jar BuildBamIndex I=MD_$sp.sorted.bam

cd ..

tar -cvf $qual.tar $qual;

mv $qual.tar $SD
