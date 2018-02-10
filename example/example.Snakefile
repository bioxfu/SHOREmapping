configfile: "config.yaml"

rule all:
	input:
		expand('clean/{sample}_R1_paired.fastq.gz', sample=config['samples']),
		expand('clean/{sample}_R2_paired.fastq.gz', sample=config['samples']),
		expand('fastqc/raw/{sample}_R1_fastqc.html', sample=config['samples']),
		expand('fastqc/raw/{sample}_R2_fastqc.html', sample=config['samples']),
		expand('fastqc/clean/{sample}_R1_paired_fastqc.html', sample=config['samples']),
		expand('fastqc/clean/{sample}_R2_paired_fastqc.html', sample=config['samples']),
		expand('stat/fastqc_stat.tsv'),
		expand('bam/{sample}.bam', sample=config['samples']),
		expand('bam/{sample}.bam.bai', sample=config['samples']),
		expand('bam/{sample}.bamqc', sample=config['samples']),
		expand('stat/bamqc_stat.tsv'),
		expand('bam/{sample}.vcf', sample=config['samples']),
		expand('convert/{sample}/1_converted_consen.txt', sample=config['samples']),
		expand('convert/{sample}/1_converted_reference.txt', sample=config['samples']),
		expand('convert/{sample}/1_converted_variant.txt', sample=config['samples']),
		expand('extract/{foreground}/extracted_consensus_0.txt', foreground=config['foreground']),
		expand('backcross/{foreground}_{background}/SHOREmap_marker.bg_corrected', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp_1_1_30427671_peak1.txt', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp_2_1_19698289_peak1.txt', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp_3_1_23459830_peak1.txt', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp_4_1_18585056_peak1.txt', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp_5_1_26975502_peak1.txt', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/prioritized_snp.tsv', foreground=config['foreground'], background=config['background']),
		expand('annotation/{foreground}_{background}/{foreground}_{background}_prioritized_snp.tsv', foreground=config['foreground'], background=config['background']),

rule fastqc_raw_PE:
	input:
		config['path']+'/{sample}_R1.fastq.gz',
		config['path']+'/{sample}_R2.fastq.gz'
	output:
		'fastqc/raw/{sample}_R1_fastqc.html',
		'fastqc/raw/{sample}_R2_fastqc.html'
	shell:
		'fastqc -t 2 -o fastqc/raw {input}'

rule trimmomatic_PE:
	input:
		r1 = config['path']+'/{sample}_R1.fastq.gz',
		r2 = config['path']+'/{sample}_R2.fastq.gz'
	output:
		r1_paired = 'clean/{sample}_R1_paired.fastq.gz',
		r2_paired = 'clean/{sample}_R2_paired.fastq.gz',
		r1_unpaired = 'clean/{sample}_R1_unpaired.fastq.gz',
		r2_unpaired = 'clean/{sample}_R2_unpaired.fastq.gz'
	params:
		adapter = config['adapter']
	shell:
		'trimmomatic PE -threads 3 -phred33 {input.r1} {input.r2} {output.r1_paired} {output.r1_unpaired} {output.r2_paired} {output.r2_unpaired} ILLUMINACLIP:{params.adapter}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36'

rule fastqc_clean_PE:
	input:
		'clean/{sample}_R1_paired.fastq.gz',
		'clean/{sample}_R2_paired.fastq.gz'
	output:
		'fastqc/clean/{sample}_R1_paired_fastqc.html',
		'fastqc/clean/{sample}_R2_paired_fastqc.html'
	shell:
		'fastqc -t 2 -o fastqc/clean {input}'

rule fastqc_stat_PE:
	input:
		['fastqc/raw/{sample}_R1_fastqc.html'.format(sample=x) for x in config['samples']],
		['fastqc/raw/{sample}_R2_fastqc.html'.format(sample=x) for x in config['samples']],
		['fastqc/clean/{sample}_R1_paired_fastqc.html'.format(sample=x) for x in config['samples']],
		['fastqc/clean/{sample}_R2_paired_fastqc.html'.format(sample=x) for x in config['samples']]
	output:
		'stat/fastqc_stat.tsv'
	params:
		Rscript = config['Rscript_path']
	shell:
		'{params.Rscript} script/reads_stat_by_fastqcr.R'

rule bowtie2_PE:
	input:
		r1 = 'clean/{sample}_R1_paired.fastq.gz',
		r2 = 'clean/{sample}_R2_paired.fastq.gz'
	output:
		bam = 'bam/{sample}.bam'
	params:
		prefix = 'bam/{sample}',
		cpu = config['cpu'],
		index = config['index'],
	shell:
		"bowtie2 -p {params.cpu} -x {params.index} -1 {input.r1} -2 {input.r2} |samtools view -Shub|samtools sort - -T {params.prefix} -o {output.bam}"

rule bam_idx:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bai = 'bam/{sample}.bam.bai'
	shell:
		'samtools index {input.bam} {output.bai}'

rule bam_qc:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bamqc_dir = 'bam/{sample}.bamqc',
		bamqc_html = 'bam/{sample}.bamqc/qualimapReport.html'
	params:
		cpu = config['cpu']
	shell:
		"qualimap bamqc --java-mem-size=10G -nt {params.cpu} -bam {input.bam} -outdir {output.bamqc_dir}"

rule bam_qc_stat:
	input:
		['bam/{sample}.bamqc/qualimapReport.html'.format(sample=x) for x in config['samples']]
	output:
		'stat/bamqc_stat.tsv'
	params:
		Rscript = config['Rscript_path']		
	shell:
		"{params.Rscript} script/mapping_stat_by_bamqc.R"

rule bam2vcf:
	input:
		bam = 'bam/{sample}.bam'
	output:
		vcf = 'bam/{sample}.vcf'
	params:
		fas = config['index']+'.fa',
		samtools = config['samtools'],
		bcftools = config['bcftools']
	shell:
		"{params.samtools} mpileup -uD -f {params.fas} {input}|{params.bcftools} view -vcg - > {output}"

rule shoremap_convert:
	input:
		vcf = 'bam/{sample}.vcf'
	output:
		folder = 'convert/{sample}',
		consen = 'convert/{sample}/1_converted_consen.txt',
		reference = 'convert/{sample}/1_converted_reference.txt',
		variant = 'convert/{sample}/1_converted_variant.txt'
	params:
		shoremap = config['shoremap']
	shell:
		"{params.shoremap} convert --marker {input.vcf} --folder {output.folder}"

rule shoremap_extract:
	input:
		marker = 'convert/{foreground}/1_converted_variant.txt',
		consen = 'convert/{foreground}/1_converted_consen.txt'
	output:
		folder = 'extract/{foreground}',
		consen = 'extract/{foreground}/extracted_consensus_0.txt'
	params:
		shoremap = config['shoremap'],
		chrsize = config['chrSizes']
	shell:
		"{params.shoremap} extract --chrsizes {params.chrsize} --folder {output.folder} --marker {input.marker} --consen {input.consen}"

rule shoremap_backcross:
	input:
		marker = 'convert/{foreground}/1_converted_variant.txt',
		consen = 'extract/{foreground}/extracted_consensus_0.txt',
		bg = 'convert/{background}/1_converted_variant.txt'
	output:
		folder = 'backcross/{foreground}_{background}',
		marker = 'backcross/{foreground}_{background}/SHOREmap_marker.bg_corrected'
	params:
		shoremap = config['shoremap'],
		chrsize = config['chrSizes']
	shell:
		"{params.shoremap} backcross --chrsizes {params.chrsize} --marker {input.marker} --consen {input.consen} --folder {output.folder} --marker-score 40 --marker-freq 0.0 --min-coverage 10 --max-coverage 80 --bg {input.bg} --bg-cov 1 --bg-freq 0.0 --bg-score 1 --cluster 1 --marker-hit 1 -plot-bc"

rule shoremap_annotate:
	input:
		snp = 'backcross/{foreground}_{background}/SHOREmap_marker.bg_corrected'
	output:
		folder = 'annotation/{foreground}_{background}',
		snp_2 = 'backcross/{foreground}_{background}/SHOREmap_marker.bg_corrected.2',
		anno1 = 'annotation/{foreground}_{background}/prioritized_snp_1_1_30427671_peak1.txt',
		anno2 = 'annotation/{foreground}_{background}/prioritized_snp_2_1_19698289_peak1.txt',
		anno3 = 'annotation/{foreground}_{background}/prioritized_snp_3_1_23459830_peak1.txt',
		anno4 = 'annotation/{foreground}_{background}/prioritized_snp_4_1_18585056_peak1.txt',
		anno5 = 'annotation/{foreground}_{background}/prioritized_snp_5_1_26975502_peak1.txt'
	params:
		shoremap = config['shoremap'],
		chrsize = config['chrSizes'],
		genome = config['genome'],
		gff = config['gff']
	shell:
		"cat {input.snp}|sed 's/Chr//' > {output.snp_2}; {params.shoremap} annotate --chrsizes {params.chrsize} --snp {output.snp_2} --chrom 1 --start 1 --end 30427671 --folder {output.folder} --genome {params.genome} --gff {params.gff}; {params.shoremap} annotate --chrsizes {params.chrsize} --snp {output.snp_2} --chrom 2 --start 1 --end 19698289 --folder {output.folder} --genome {params.genome} --gff {params.gff};{params.shoremap} annotate --chrsizes {params.chrsize} --snp {output.snp_2} --chrom 3 --start 1 --end 23459830 --folder {output.folder} --genome {params.genome} --gff {params.gff};{params.shoremap} annotate --chrsizes {params.chrsize} --snp {output.snp_2} --chrom 4 --start 1 --end 18585056 --folder {output.folder} --genome {params.genome} --gff {params.gff};{params.shoremap} annotate --chrsizes {params.chrsize} --snp {output.snp_2} --chrom 5 --start 1 --end 26975502 --folder {output.folder} --genome {params.genome} --gff {params.gff}"

rule shoremap_annotate_combine:
	input:
		anno1 = 'annotation/{foreground}_{background}/prioritized_snp_1_1_30427671_peak1.txt',
		anno2 = 'annotation/{foreground}_{background}/prioritized_snp_2_1_19698289_peak1.txt',
		anno3 = 'annotation/{foreground}_{background}/prioritized_snp_3_1_23459830_peak1.txt',
		anno4 = 'annotation/{foreground}_{background}/prioritized_snp_4_1_18585056_peak1.txt',
		anno5 = 'annotation/{foreground}_{background}/prioritized_snp_5_1_26975502_peak1.txt'
	output:
		'annotation/{foreground}_{background}/prioritized_snp.tsv'
	shell:
		"cat {input.anno1} {input.anno2} {input.anno3} {input.anno4} {input.anno5}|cut -f1-7,9,10,12-16|sort -k1,1n -k2,2n|uniq|sed -r 's/$/\t\t\t\t\t\t/'|cut -f1-14 > {output}"

rule shoremap_annotate_annot:
	input:
		'annotation/{foreground}_{background}/prioritized_snp.tsv'
	output:
		'annotation/{foreground}_{background}/{foreground}_{background}_prioritized_snp.tsv'
	params:
		Rscript = config['Rscript_path']		
	shell:
		"{params.Rscript} script/annot_gene.R {input} {output}"
