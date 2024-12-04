# Index and Alignment 
export PATH=/opt/software/miniconda3/envs/samtools/bin:$PATH
export PATH=/opt/software/miniconda3/envs/chromap/bin:$PATH

export EntityID=$1
Threads=$2
export Contigs=$3
HiC_R1=$4
HiC_R2=$5

#ln -sf $Contigs ${EntityID}.fa
#$export Contigs=${Contigs}
#export EntityID=${EntityID}
perl -e '($ENV{Contigs} =~ /.gz$/) ? (`gzip -cd $ENV{Contigs} > $ENV{EntityID}.fa`) : (`cp $ENV{Contigs} $ENV{EntityID}.fa`)'
samtools faidx ${EntityID}.fa
chromap -i -r ${EntityID}.fa -o ${EntityID}.index 2>&1 | perl -ne '(/number of bases: (\d+)\.$/) && (print "assembly $1\n")'> ${EntityID}.chrom.sizes

echo "Index Done."

chromap --preset hic -r ${EntityID}.fa -x ${EntityID}.index \
-t 20 --SAM -o aligned.sam \
-1 ${HiC_R1} \
-2 ${HiC_R2}

echo "Alilgn Done."

samtools view -@ ${Threads} -b aligned.sam | samtools sort -@ 20 -o aligned.bam
samtools view -@ ${Threads} -b -F 4 -F 2048 aligned.bam -o aligned.pair.bam

echo "Filter Done."

export PATH=/opt/software/miniconda3/envs/java/bin:$PATH
java -jar /opt/software/picard/picard.jar MarkDuplicates -I aligned.pair.bam -O ${SampleID}.hicaln.dedup.bam -REMOVE_DUPLICATES true -M dedup_metrics.txt

echo "Dedup Done."

echo "Successful."
