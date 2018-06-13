source activate gmatic
conda env export > doc/environment.yml

if [ ! -d fastqc ]; then
	mkdir fastqc clean bam stat table convert extract backcross annotation doc

fi
