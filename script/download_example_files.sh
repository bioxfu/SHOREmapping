mkdir fastq
cd fastq
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/BC.fg.reads1.fq.gz -O BC_fg_R1.fastq.gz
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/BC.fg.reads2.fq.gz -O BC_fg_R2.fastq.gz
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/BC.bg.reads1.fq.gz -O BC_bg_R1.fastq.gz
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/BC.bg.reads2.fq.gz -O BC_bg_R2.fastq.gz
cd -

mkdir data
cd data
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/TAIR10_chr_all.fas
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/TAIR10_GFF3_genes.gff
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/chrSizes.txt
wget -c http://bioinfo.mpipz.mpg.de/shoremap/data/software/scoring_matrix_het.txt
