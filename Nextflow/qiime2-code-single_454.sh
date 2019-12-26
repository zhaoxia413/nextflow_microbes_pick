$find ./SEdat/*gz|wc -l
#Install qiime2
#download manully qiime2-2019.10-py36-linux-conda.txt
#rz to linux
#ref qiime manual: https://docs.qiime2.org/2019.10/tutorials/pd-mice#importing-data-into-qiime-2
#Parkinson’s Mouse Tutorial
$mv qiime2-2019.10-py36-linux-conda.txt \
qiime2-2019.10-py36-linux-conda.yml
$conda env create -n qiime2-2019.10 \
--file qiime2-2019.10-py36-linux-conda.yml
$rm qiime2-2019.10-py36-linux-conda.yml
$source activate qiime2-2019.10
$ conda-env list
$ conda activate qiime2-2019.4
$qiime tools import --show-importable-types
##为什么单端测序的samplelist用,分隔？双端用/t分隔？？
$qiime tools import \
   --type 'SampleData[SequencesWithQuality]' \
   --input-path qiime_SEfilelist_lzx \
   --input-format SingleEndFastqManifestPhred33V2 \
   --output-path ./qiime_results/single-end-demux.qza
