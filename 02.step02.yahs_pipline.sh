#!/usr/bin/env bash

YaHS_DIR="/opt/software/yahs"
TEST_OUTDIR="YaHS_result"
mkdir -p ${TEST_OUTDIR}

################################ START OF YAHS SCAFFOLDING TEST ################################
#### download the EntityID data
EntityID=$1
out="${EntityID}_out"
contigs="${EntityID}.fa" # need to be indexed, i.e., ${EntityID}.contigs.fasta.gz.fai is presented
index="${EntityID}.fa.fai"
hicaln="${EntityID}.hicaln.dedup.bam" # could be .bed, .bam or .bin file
Restriction_site=$2
juicer_tools="/opt/software/juicer_tools/juicer_tools_1.19.02.jar pre"

#### run yahs scaffolding
if [ -z "$3" ]; then
(${YaHS_DIR}/yahs --file-type BAM -o ${TEST_OUTDIR}/${out} ${contigs} ${hicaln} > ${TEST_OUTDIR}/01.YaHS_scaffolding.log 2>&1) && (echo "YaHS scaffolding DONE.")
else 
(${YaHS_DIR}/yahs -e ${Restriction_site} --file-type BAM -o ${TEST_OUTDIR}/${out} ${contigs} ${hicaln} > ${TEST_OUTDIR}/01.YaHS_scaffolding.log 2>&1) && (echo "YaHS scaffolding DONE.")
fi

rm -f ${TEST_OUTDIR}/${out}_inital_break* &  rm -f ${TEST_OUTDIR}/${out}_r*

(${YaHS_DIR}/agp_to_fasta ${TEST_OUTDIR}/${out}_scaffolds_final.agp ${contigs} -o ${TEST_OUTDIR}/${out}.fa >${TEST_OUTDIR}/02.AGPtoFASTA.log 2>&1) && (echo "AGP to FASTA DONE.")

(${YaHS_DIR}/juicer pre ${TEST_OUTDIR}/${out}.bin ${TEST_OUTDIR}/${out}_scaffolds_final.agp $index >${TEST_OUTDIR}/${out}.aln.txt 2>${TEST_OUTDIR}/03.Juicer_pre.log) && (echo "Juicer pre DONE.")

(${YaHS_DIR}/juicer pre ${TEST_OUTDIR}/${out}.bin ${TEST_OUTDIR}/${out}_scaffolds_final.agp $index -a -o ${TEST_OUTDIR}/${out}.JBAT >${TEST_OUTDIR}/04.Juicer_pre-a.log 2>&1 ) && (echo "Juicer pre -a DONE.")

source /opt/software/miniconda3/bin/activate java
(java -jar ${juicer_tools} ${TEST_OUTDIR}/${out}.JBAT.txt ${TEST_OUTDIR}/${out}.JBAT.hic <(cat ${EntityID}.chrom.sizes) >${TEST_OUTDIR}/05.Generate_.hic_file.log 2>&1) && (echo "Generate .hic file Done.")

rm -f ${TEST_OUTDIR}/${out}_scaffolds_final.* & rm -f ${TEST_OUTDIR}/${out}*.txt & rm -f ${TEST_OUTDIR}/${out}*.bin & rm -f ${TEST_OUTDIR}/${out}.JBAT.assembly.agp
echo "Successful."

################################# END OF YAHS SCAFFOLDING TEST #################################
