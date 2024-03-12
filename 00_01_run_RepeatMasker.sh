#/bin/bash
s_list_genomes=("CC090" "CC260" "Chiltepin" "CM334" "ECW" "ECW123" "I19-702-1" "LaMuyo-01" "Maor" "MR3" "Perennial" "PG1" "Takanotsume" "ThaiHot" "UCD10X" "Zhangshugang" "Zunla")

reference_dir="/data3/user/Public/JONG/02_PanGenome/00_references"
working_dir="/data3/user/Public/JONG/02_PanGenome/02_annotation"
repeatmodeler_dir="/data/user/Public/JONG/tools/RepeatModeler-2.0.2a"
repeatmasker_dir="/data/user/Public/JONG/tools/RepeatMasker"

for var in "${s_list_genomes[@]}"
do
    CMD="mkdir ${var}"
    echo ${CMD}
    eval ${CMD}
    CMD="mkdir ${var}/01_RepeatAnnotation"
    echo ${CMD}
    eval ${CMD}
    CMD="ln -s ${reference_dir}/${var}.v1.0.Genome.fasta ${working_dir}/${var}/"
    echo ${CMD}
    eval ${CMD}

## 01. Run RepeatModeler
    CMD1="${repeatmodeler_dir}/BuildDatabase -name ${working_dir}/${var}/01_RepeatAnnotation/${var} -engine ncbi ${working_dir}/${var}/${var}.v1.0.Genome.fasta"
    echo ${CMD1}
    eval ${CMD1}
    CMD1="${repeatmodeler_dir}/RepeatModeler -pa 64 -engine ncbi -database ${working_dir}/${var}/01_RepeatAnnotation/${var} 2>&1 | tee ${working_dir}/${var}/01_RepeatAnnotation/RepeatModeler.${var}.log"
    echo ${CMD1}
    eval ${CMD1}
    CMD1="mv RM_* ${var}/01_RepeatAnnotation/RepeatModeler_${var}"
    echo ${CMD1}
    eval ${CMD1}

## 02. Run RepeatMasker    
    CMD2="${repeatmasker_dir}/RepeatMasker -pa 64 -dir ${working_dir}/${var}/01_RepeatAnnotation/RepeatMasker_${var} -xsmall -lib ${var}/01_RepeatAnnotation/RepeatModeler_${var}/consensi.fa.classified ${working_dir}/${var}/${var}.v1.0.Genome.fasta"
    echo ${CMD2}
    eval ${CMD2}
done
