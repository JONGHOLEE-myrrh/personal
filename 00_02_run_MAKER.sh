#!/bin/bash

## 00. Print usage if the number of $# is not 1.
if [ $# -ne 1 ]
then
    echo "Usage  : ${0} param1"
    echo "Example: sh 00_02_run_MAKER.sh Dempsey"
    exit 1
fi

sample=${1}

reference_dir="/data3/user/Public/JONG/02_PanGenome/00_references"
working_dir="/data3/user/Public/JONG/02_PanGenome/02_annotation"
repeatmodeler_dir="/data/user/Public/JONG/tools/RepeatModeler-2.0.2a"
repeatmasker_dir="/data/user/Public/JONG/tools/RepeatMasker"

## 01. Arrange RepeatMasker output.
CMD="${repeatmasker_dir}/util/rmOutToGFF3custom -o ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out > ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out.gff3"
echo ${CMD}
#eval ${CMD}
CMD="grep -v -e \"Satellite\" -e \"Low_complexity\" -e \"Simple_repeat\" ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out.gff3 > ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out.complex.gff3"
echo ${CMD}
#eval ${CMD}
CMD="cat ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out.complex.gff3  | perl -ane '\$id; if(!/^\#/){@F = split(/\t/, \$_); chomp \$F[-1];\$id++; \$F[-1] .= \"\;ID=\$id\"; \$_ = join(\"\t\", @F).\"/\n\"} print \$_' > ${working_dir}/${1}/01_RepeatAnnotation/RepeatMasker_${1}/${1}.v1.0.Genome.fasta.out.complex.reformat.gff3"
echo ${CMD}
#eval ${CMD}

## 01. Run the first round of MAKER.
annot_dir="${working_dir}/${1}/02_MAKER"
maker_dir="/data/user/Public/JONG/tools/maker/bin"

CMD2="mkdir ${annot_dir}"
echo ${CMD2}
#eval ${CMD2}
CMD2="cp ${working_dir}/Lam32/02_MAKER/*.ctl ${annot_dir}"
echo ${CMD2}
#eval ${CMD2}
CMD2="sed -i 's/Lam32/${1}/g' ${annot_dir}/round1_maker_opts.ctl"
echo ${CMD2}
#eval ${CMD2}

for i in {1..14}
do
    CMD2="${maker_dir}/maker -f -base ${1}_rnd1 ${annot_dir}/round1_maker_opts.ctl ${annot_dir}/maker_bopts.ctl ${annot_dir}/maker_exe.ctl 2>&1 | tee ${annot_dir}/round1.maker.${i}.log &"
    echo ${CMD2}
#    eval ${CMD2}
done

## 02. Arrange the output from the first round of MAKER.
CMD3="${maker_dir}/gff3_merge -s -d ${1}_rnd1.maker.output/${1}_rnd1_master_datastore_index.log > ${1}_rnd1.maker.output/${1}_rnd1.all.maker.gff3"
echo ${CMD3}
#eval ${CMD3}
CMD3="${maker_dir}/gff3_merge -n -s -d ${1}_rnd1.maker.output/${1}_rnd1_master_datastore_index.log > ${1}_rnd1.maker.output/${1}_rnd1.all.maker.noseq.gff3"
echo ${CMD3}
#eval ${CMD3}
CMD3="${maker_dir}/fasta_merge -d ${1}_rnd1.maker.output/${1}_rnd1_master_datastore_index.log "
echo ${CMD3}
#eval ${CMD3}
CMD3="mv ${1}_rnd1.all.maker.* ${1}_rnd1.maker.output/"
echo ${CMD3}
#eval ${CMD3}
CMD3="grep -c \">\" ${1}_rnd1.maker.output/${1}_rnd1.all.maker.proteins.fasta"
echo ${CMD3}
eval ${CMD3}

## 03. Training ab-initio gene prediction programs.
ab_initio_dir="/data3/user/Public/JONG/02_PanGenome/02_annotation/${1}_rnd1.maker.output/gene_prediction"

# 01. SNAP
snap_dir="/data/user/Public/JONG/tools/SNAP/"

CMD4="mkdir ${1}_rnd1.maker.output/gene_prediction"
echo ${CMD4}
#eval ${CMD4}
CMD4="mkdir ${1}_rnd1.maker.output/gene_prediction/snap"
echo ${CMD4}
#eval ${CMD4}
CMD4="mkdir ${1}_rnd1.maker.output/gene_prediction/snap/round1"
echo ${CMD4}
#eval ${CMD4}
CMD4="cd ./${1}_rnd1.maker.output/gene_prediction/snap/round1"
echo ${CMD4}
eval ${CMD4}
echo ${PWD}
CMD4="${maker_dir}/maker2zff -x 0.25 -l 50 -d ../../../${1}_rnd1_master_datastore_index.log"
echo ${CMD4}
#eval ${CMD4}
CMD4="rename -v genome ${1}_rnd1.zff.length50_aed25 *"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/fathom ${1}_rnd1.zff.length50_aed25.ann ${1}_rnd1.zff.length50_aed25.dna -gene-stats > gene-stats.log 2>&1"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/fathom ${1}_rnd1.zff.length50_aed25.ann ${1}_rnd1.zff.length50_aed25.dna -validate > validate.log 2>&1"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/fathom ${1}_rnd1.zff.length50_aed25.ann ${1}_rnd1.zff.length50_aed25.dna -categorize 1000 > categorize.log 2>&1"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1"
echo ${CMD4}
#eval ${CMD4}
CMD4="mkdir params"
echo ${CMD4}
#eval ${CMD4}
CMD4="cd params/"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/forge ../export.ann ../export.dna > ../forge.log 2>&1"
echo ${CMD4}
#eval ${CMD4}
CMD4="cd ../"
echo ${CMD4}
#eval ${CMD4}
CMD4="${snap_dir}/hmm-assembler.pl ${1}_rnd1.zff.length50_aed25 params > ${1}_rnd1.zff.length50_aed25.hmm"
echo ${CMD4}
#eval ${CMD4}

# 02. Augustus training
augustus_dir="/data/user/Public/JONG/tools/Augustus/"
busco_dir="/data/user/Public/JONG/tools/busco/bin/"

CMD5="mkdir ${ab_initio_dir}/augustus"
echo ${CMD5}
#eval ${CMD5}
CMD5="cd ${ab_initio_dir}/augustus"
echo ${CMD5}
eval ${CMD5}
CMD5="samtools faidx ${working_dir}/${1}/${1}.v1.0.Genome.fasta"
echo ${CMD5}
#eval ${CMD5}
CMD5="awk -v OFS=\"\t\" '{ if (\$3 == \"mRNA\") print \$1, \$4, \$5 }' ../../${1}_rnd1.all.maker.noseq.gff3 | while read rna;   do   scaffold=\`echo \${rna} | awk '{ print \$1 }'\`;   end=\`cat ${working_dir}/${1}/${1}.v1.0.Genome.fasta.fai | awk -v scaffold=\"\${scaffold}\" -v OFS=\"\t\" '{ if (\$1 == scaffold) print \$2 }'\`;   echo \${rna} | awk -v end=\"\${end}\" -v OFS=\"\t\" '{ if (\$2 < 1000 && (end - \$3) < 1000) print \$1, \"0\", end; \
     else if ((end - \$3) < 1000) print \$1, \"0\", end; \
     else if (\$2 < 1000) print \$1, \"0\", \$3+1000; \
     else print \$1, \$2-1000, \$3+1000 }';   done > test.bed"
echo ${CMD5}
#eval ${CMD5}
CMD5="bedtools getfasta -fi ${working_dir}/${1}/${1}.v1.0.Genome.fasta -bed test.bed -fo test.fasta"
echo ${CMD5}
#eval ${CMD5}
CMD5="export AUGUSTUS_CONFIG_PATH=/data/user/Public/JONG/tools/Augustus/config"
echo ${CMD5}
#eval ${CMD5}
CMD5="${busco_dir}/busco -f -i test.fasta -o ${1}_rnd1_maker -l embryophyta_odb10 -m genome -c 64 --long --augustus --augustus_species tomato --augustus_parameters='--progress=true' --config /data/user/Public/JONG/tools/busco/config/config.ini"
echo ${CMD5}
#eval ${CMD5}
CMD5="cd ${ab_initio_dir}/augustus/${1}_rnd1_maker/run_embryophyta_odb10/augustus_output/retraining_parameters/BUSCO_${1}_rnd1_maker/"
echo ${CMD5}
#eval ${CMD5}
CMD5="rename -v BUSCO_${1}_rnd1_maker ${1}_rnd1 *"
echo ${CMD5}
#eval ${CMD5}
CMD5="sed -i 's/BUSCO_${1}_rnd1_maker/${1}_rnd1/g' ${1}_rnd1_parameters.cfg "
echo ${CMD5}
#eval ${CMD5}
CMD5="mkdir ${augustus_dir}/config/species/${1}_rnd1"
echo ${CMD5}
#eval ${CMD5}
CMD5="cp -rf ${1}_rnd1_* ${augustus_dir}/config/species/${1}_rnd1/"
echo ${CMD5}
#eval ${CMD5}

# 03. GeneMark training
gmes_dir="/data/user/Public/JONG/tools/gmes_linux_64_4/"

CMD6="mkdir ${ab_initio_dir}/gmes"
echo ${CMD6}
#eval ${CMD6}
CMD6="cd ${ab_initio_dir}/gmes"
echo ${CMD6}
#eval ${CMD6}
CMD6="${gmes_dir}/gmes_petap.pl --ES --cores 64 --v -sequence ${working_dir}/${1}/${1}.v1.0.Genome.fasta"
echo ${CMD6}
#eval ${CMD6}

# 04.1. Arrange the first round MAKER output to gff 
first_maker_out_dir="${working_dir}/${1}/02_MAKER/"

CMD7="mv ${working_dir}/${1}_rnd1.maker.output ${first_maker_out_dir}"
echo ${CMD7}
#eval ${CMD7}
CMD7="cd ${first_maker_out_dir}/${1}_rnd1.maker.output/"
echo ${CMD7}
#eval ${CMD7}
CMD7="awk '{ if (\$2 == \"est2genome\") print \$0 }' ${1}_rnd1.all.maker.noseq.gff3 > ${1}_rnd1.all.maker.est2genome.gff3"
echo ${CMD7}
#eval ${CMD7}
CMD7="awk '{ if (\$2 == \"protein2genome\") print \$0 }' ${1}_rnd1.all.maker.noseq.gff3 > ${1}_rnd1.all.maker.protein2genome.gff3"
echo ${CMD7}
#eval ${CMD7}
CMD7="awk '{ if (\$2 ~ \"repeat\") print \$0 }' ${1}_rnd1.all.maker.noseq.gff3 > ${1}_rnd1.all.maker.repeats.gff3"
echo ${CMD7}
#eval ${CMD7}
# 04.2. Change MAKER ctl files.
CMD7="cd ${first_maker_out_dir}/"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|/data3/user/Public/JONG/02_PanGenome/02_annotation/Lam32/02_MAKER/Lam32_rnd1.maker.output/Lam32_rnd1.all.maker.est2genome.gff3|${first_maker_out_dir}/${1}_rnd1.maker.output/${1}_rnd1.all.maker.est2genome.gff3|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|/data3/user/Public/JONG/02_PanGenome/02_annotation/Lam32/02_MAKER/Lam32_rnd1.maker.output/Lam32_rnd1.all.maker.protein2genome.gff3|${first_maker_out_dir}/${1}_rnd1.maker.output/${1}_rnd1.all.maker.protein2genome.gff3|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|/data3/user/Public/JONG/02_PanGenome/02_annotation/Lam32/02_MAKER/Lam32_rnd1.maker.output/Lam32_rnd1.all.maker.repeats.gff3|${first_maker_out_dir}/${1}_rnd1.maker.output/${1}_rnd1.all.maker.repeats.gff3|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|snaphmm=.*|snaphmm=${first_maker_out_dir}/${1}_rnd1.maker.output/gene_prediction/snap/round1/CC090_rnd1.zff.length50_aed25.hmm|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|gmhmm=.*|gmhmm=${first_maker_out_dir}/${1}_rnd1.maker.output/gene_prediction/gmes/gmhmm.mod|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's|augustus_species=.*|augustus_species=${1}_rnd1|g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}
CMD7="sed -i 's/Lam32/${1}/g' round2_maker_opts.ctl"
echo ${CMD7}
eval ${CMD7}

# 04.3. Run 2nd round of MAKER.
for i in {1..14}
do
    CMD8="${maker_dir}/maker -f -base ${1}_rnd1 ${annot_dir}/round2_maker_opts.ctl ${annot_dir}/maker_bopts.ctl ${annot_dir}/maker_exe.ctl 2>&1 | tee ${annot_dir}/round1.maker.${i}.log &"
    echo ${CMD8}
    eval ${CMD8}
done
