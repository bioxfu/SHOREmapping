# Download example resequencing data for backcross analysis
# ./script/download_example_files.sh

# Download reference sequence and gene annotation of Arabidopsis thaliana
# ./script/download_reference.sh

# Start a Docker Container
# ./run_shoremap.sh

# In Docker Container

# 1. Preprocessing the reference sequence of A.thaliana
# shore preprocess -f reference/TAIR10_chr_all.fas -i indexs -x BWA

# 2. Import short reads in fastq format into SHORE analysis folders
shore import -v Fastq -e Shore -a genomic -x fastq/BC_fg_R1.fastq.gz -x fastq/BC_fg_R2.fastq.gz -i fg -o BC/fg/flowcell --rplot
shore import -v Fastq -e Shore -a genomic -x fastq/BC_bg_R1.fastq.gz -x fastq/BC_bg_R2.fastq.gz -i bg -o BC/bg/flowcell --rplot

# 3. Align reads to the reference sequence
shore mapflowcell -v bwa -f BC/fg/flowcell -i indexs/TAIR10_chr_all.fas.shore -n 10% -g 7% -c 30 -p --rplot
shore mapflowcell -v bwa -f BC/bg/flowcell -i indexs/TAIR10_chr_all.fas.shore -n 10% -g 7% -c 30 -p --rplot

# 4. Correct alignments with paired-end information
shore correct4pe -l BC/fg/flowcell/1/sample_fg -x 250 -D PE -p
shore correct4pe -l BC/bg/flowcell/1/sample_bg -x 250 -D PE -p

# 5. Merge alignments
shore merge -m BC/fg/flowcell -o BC/fg/alignment -p 
shore merge -m BC/bg/flowcell -o BC/bg/alignment -p 

# 6. Call differences between sample and reference sequence
shore consensus -n BC.fg -f indexs/TAIR10_chr_all.fas.shore -o BC/fg/consensus -m BC/fg/alignment/map.list.xz -a reference/scoring_matrix_het.txt -g 5 -v -r
shore consensus -n BC.bg -f indexs/TAIR10_chr_all.fas.shore -o BC/bg/consensus -m BC/bg/alignment/map.list.xz -a reference/scoring_matrix_het.txt -g 5 -v -r

# 7. Decompress the consensus call information of the mapping population
unxz BC/fg/consensus/ConsensusAnalysis/supplementary_data/consensus_summary.txt.xz

# 8. Extract the consensus information for candidate markers
SHOREmap extract --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis --marker BC/fg/consensus/ConsensusAnalysis/quality_variant.txt --consen BC/fg/consensus/ConsensusAnalysis/supplementary_data/consensus_summary.txt -verbose

# 9. Analysis AFs in the BCF2 population
SHOREmap backcross --chrsizes reference/chrSizes.txt --marker BC/fg/consensus/ConsensusAnalysis/quality_variant.txt --consen BC/SHOREmap_analysis/extracted_consensus_0.txt --folder BC/SHOREmap_analysis -plot-bc --marker-score 40 --marker-freq 0.0 --min-coverage 10 --max-coverage 80 --bg BC/bg/consensus/ConsensusAnalysis/quality_variant.txt --bg-cov 1 --bg-freq 0.0 --bg-score 1 -non-EMS --cluster 1 --marker-hit 1 -verbose

# 10. Annotate mutations
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis/ann --snp BC/SHOREmap_analysis/SHOREmap_marker.bg_corrected_mh1.0000_ic10_ac80_q40_f0.0_EMS --chrom 1 --start 1 --end 30427671 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis/ann --snp BC/SHOREmap_analysis/SHOREmap_marker.bg_corrected_mh1.0000_ic10_ac80_q40_f0.0_EMS --chrom 2 --start 1 --end 19698289 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis/ann --snp BC/SHOREmap_analysis/SHOREmap_marker.bg_corrected_mh1.0000_ic10_ac80_q40_f0.0_EMS --chrom 3 --start 1 --end 23459830 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis/ann --snp BC/SHOREmap_analysis/SHOREmap_marker.bg_corrected_mh1.0000_ic10_ac80_q40_f0.0_EMS --chrom 4 --start 1 --end 18585056 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder BC/SHOREmap_analysis/ann --snp BC/SHOREmap_analysis/SHOREmap_marker.bg_corrected_mh1.0000_ic10_ac80_q40_f0.0_EMS --chrom 5 --start 1 --end 26975502 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
cat BC/SHOREmap_analysis/ann/prioritized_snp*|sort -nrk6,6 -k1,1n -k2,2n|grep 'Nonsyn'|grep '1\.00'|cut -f1-7,9-10,12-16 > BC/SHOREmap_analysis/ann/prioritized_snp_Nonsyn_AF1.tsv
Rscript script/annot_gene.R BC/SHOREmap_analysis/ann/prioritized_snp_Nonsyn_AF1.tsv BC/SHOREmap_analysis/ann/prioritized_snp_Nonsyn_AF1_annot.tsv
