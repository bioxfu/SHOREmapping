# Download example resequencing data for backcross analysis
# ./script/download_example_files.sh

# Download reference sequence and gene annotation of Arabidopsis thaliana
# ./script/download_reference.sh

# Add links for sample one (OC fg)
# cd fastq
# ln -s Ws2_8_15_R1.fastq.gz OC_fg_R1.fastq.gz
# ln -s Ws2_8_15_R2.fastq.gz OC_fg_R2.fastq.gz
# ln -s Col0_clf59_ld1_R1.fastq.gz OC_bg_R1.fastq.gz
# ln -s Col0_clf59_ld1_R2.fastq.gz OC_bg_R2.fastq.gz
# ln -s Ws2_clf59_ld3_R1.fastq.gz BC_bg_R1.fastq.gz
# ln -s Ws2_clf59_ld3_R2.fastq.gz BC_bg_R2.fastq.gz
# cd ..

#### sample two (OC fg)
# ln -sf Ws2_10_8_R1.fastq.gz OC_fg_R1.fastq.gz
# ln -sf Ws2_10_8_R2.fastq.gz OC_fg_R2.fastq.gz

# Start a Docker Container
# ./run_shoremap.sh

# In Docker Container

echo "# 1. Preprocessing the reference sequence of A.thaliana"
# shore preprocess -f reference/TAIR10_chr_all.fas -i indexs -x BWA

echo "# 2. Import short reads in fastq format into SHORE analysis folders"
shore import -v Fastq -e Shore -a genomic -x fastq/OC_fg_R1.fastq.gz -x fastq/OC_fg_R2.fastq.gz -i fg -o OC/fg/flowcell --rplot
#shore import -v Fastq -e Shore -a genomic -x fastq/OC_bg_R1.fastq.gz -x fastq/OC_bg_R2.fastq.gz -i bg -o OC/bg/flowcell --rplot
#shore import -v Fastq -e Shore -a genomic -x fastq/BC_bg_R1.fastq.gz -x fastq/BC_bg_R2.fastq.gz -i bg -o BC/bg/flowcell --rplot

echo "# 3. Align reads to the reference sequence"
shore mapflowcell -v bwa -f OC/fg/flowcell -i indexs/TAIR10_chr_all.fas.shore -n 10% -g 7% -c 30 -p --rplot
#shore mapflowcell -v bwa -f OC/bg/flowcell -i indexs/TAIR10_chr_all.fas.shore -n 10% -g 7% -c 30 -p --rplot
#shore mapflowcell -v bwa -f BC/bg/flowcell -i indexs/TAIR10_chr_all.fas.shore -n 10% -g 7% -c 30 -p --rplot

echo "# 4. Correct alignments with paired-end information"
shore correct4pe -l OC/fg/flowcell/1/sample_fg -x 250 -D PE -p
#shore correct4pe -l OC/bg/flowcell/1/sample_bg -x 250 -D PE -p
#shore correct4pe -l BC/bg/flowcell/1/sample_bg -x 250 -D PE -p

echo "# 5. Merge alignments"
shore merge -m OC/fg/flowcell -o OC/fg/alignment -p 
#shore merge -m OC/bg/flowcell -o OC/bg/alignment -p 
#shore merge -m BC/bg/flowcell -o BC/bg/alignment -p 

echo "# 6. Call differences between sample and reference sequence"
shore consensus -n OC.fg -f indexs/TAIR10_chr_all.fas.shore -o OC/fg/consensus -m OC/fg/alignment/map.list.xz -a reference/scoring_matrix_het.txt -g 5 -v -r
#shore consensus -n OC.bg -f indexs/TAIR10_chr_all.fas.shore -o OC/bg/consensus -m OC/bg/alignment/map.list.xz -a reference/scoring_matrix_het.txt -g 5 -v -r
#shore consensus -n BC.bg -f indexs/TAIR10_chr_all.fas.shore -o BC/bg/consensus -m BC/bg/alignment/map.list.xz -a reference/scoring_matrix_het.txt -g 5 -v -r

echo "# 7. Combine all the candidate markers according to the parental lines"
mkdir OC/marker_creation
cat OC/bg/consensus/ConsensusAnalysis/quality_variant.txt BC/bg/consensus/ConsensusAnalysis/quality_variant.txt > OC/marker_creation/parental_combined_quality_variant.txt

echo "# 8. Decompress the consensus call information of the mapping population"
unxz OC/fg/consensus/ConsensusAnalysis/supplementary_data/consensus_summary.txt.xz

echo "# 9. Extract the consensus base calls for all the candidate markers"
SHOREmap extract --chrsizes reference/chrSizes.txt --folder OC/marker_creation --marker OC/marker_creation/parental_combined_quality_variant.txt --consen OC/fg/consensus/ConsensusAnalysis/supplementary_data/consensus_summary.txt -verbose

echo "# 10. Decompress the quality-reference calls of the parental lines"
unxz BC/bg/consensus/ConsensusAnalysis/quality_reference.txt.xz
unxz OC/bg/consensus/ConsensusAnalysis/quality_reference.txt.xz

echo "# 11. Extract quality-reference bases of one parent respective to quality-variants that have been called in the other background"
SHOREmap extract --chrsizes reference/chrSizes.txt --folder OC/marker_creation --marker OC/bg/consensus/ConsensusAnalysis/quality_variant.txt --extract-bg-ref --consen BC/bg/consensus/ConsensusAnalysis/quality_reference.txt --row-first 15 -verbose
SHOREmap extract --chrsizes reference/chrSizes.txt --folder OC/marker_creation --marker BC/bg/consensus/ConsensusAnalysis/quality_variant.txt --extract-bg-ref --consen OC/bg/consensus/ConsensusAnalysis/quality_reference.txt --row-first 51 -verbose

echo "# 12. Create markers with resequencing information of the parental lines"
SHOREmap create --chrsizes reference/chrSizes.txt --folder OC/marker_creation --marker OC/fg/consensus/ConsensusAnalysis/quality_variant.txt \
--marker-pa OC/bg/consensus/ConsensusAnalysis/quality_variant.txt --marker-pb BC/bg/consensus/ConsensusAnalysis/quality_variant.txt \
--bg-ref-base-pb OC/marker_creation/extracted_quality_ref_base_15.txt --bg-ref-base-pa OC/marker_creation/extracted_quality_ref_base_51.txt \
--pmarker-score 40 --pmarker-min-cov 20 --pmarker-max-cov 75 --pmarker-min-freq 0.6 --bg-ref-score 40 --bg-ref-cov 20 --bg-ref-cov-max 75 --bg-ref-freq 0.6 -verbose

echo "# 13. Analysis AFs in the OCF2 population"
SHOREmap outcross --chrsizes reference/chrSizes.txt --folder OC/SHOREmap_analysis --marker OC/marker_creation/SHOREmap_created_F2Pab_specific.txt --consen OC/marker_creation/extracted_consensus_0.txt \
--min-marker 5 -plot-boost -plot-scale --window-step 5000 --window-size 200000 --interval-min-mean 0.997 --interval-max-cvar 0.01 --min-coverage 20 --max-coverage 80 --marker-score 25 --fg-INDEL-cov 0 \
--marker-hit 1 --fg-N-cov 0 -plot-win --cluster 1 -rab -background2 -verbose

echo "# 14. Annotate mutations"
cat OC/SHOREmap_analysis/SHOREmap_stat_single_marker.txt|awk '{if($3==1)print}'
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder OC/SHOREmap_analysis/annotation --snp OC/fg/consensus/ConsensusAnalysis/quality_variant.txt --chrom 5 --start 4100000 --end 4700000 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
cat OC/SHOREmap_analysis/annotation/prioritized_snp*|grep 'Nonsyn'|awk '{if($6>=0.9 && $7>=30)print}'|cut -f1-7,9-10,12-16 > OC/SHOREmap_analysis/annotation/prioritized_snp_Nonsyn_AF.tsv
Rscript script/annot_gene.R OC/SHOREmap_analysis/annotation/prioritized_snp_Nonsyn_AF.tsv OC/SHOREmap_analysis/annotation/prioritized_snp_Nonsyn_AF_annot.tsv


# To make it easier.....
# remove OC_bg and BC_bg from OC_fg
python remove_bg_snp.py OC/marker_creation_8_15/parental_combined_quality_variant.txt OC/fg_8_15/consensus/ConsensusAnalysis/quality_variant.txt > OC_fg_8_15_q30_n10_r0.9
python remove_bg_snp.py OC/marker_creation_10_8/parental_combined_quality_variant.txt OC/fg_10_8/consensus/ConsensusAnalysis/quality_variant.txt > OC_fg_10_8_q30_n10_r0.9

./annotation.sh OC_fg_8_15_q30_n10_r0.9 OC_fg_8_15_q30_n10_r0.9_anno
./annotation.sh OC_fg_10_8_q30_n10_r0.9 OC_fg_10_8_q30_n10_r0.9_anno
