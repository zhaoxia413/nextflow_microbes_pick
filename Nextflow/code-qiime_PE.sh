$find ./PEdat/*gz|wc -l
#sevever ***.120.75
# $PWD=/data/zhaoxia/Immunotheray_Microboime/qiime_results
#import data
##为什么单端测序的samplelist用,分隔？双端用/t分隔？？
$conda activate qiime2-2019.4
$qiime tools import \
   --type 'SampleData[PairedEndSequencesWithQuality]' \
   --input-path qiime_PEfilelist_lzx \
   --output-path ./qiime_results/paired-end-demux.qza  \
   --input-format PairedEndFastqManifestPhred33
# 转化不同类型的qza为qzv有不同的方法，这里对于单纯的序列
$ qiime demux summarize \
    --i-data ./qiime_results/paired-end-demux.qza \
    --o-visualization ./paired-end-demux.qzv
#join pair-end及summary
(qiime2-2019.4) [zxia@moon qiime]$ qiime vsearch join-pairs \
   --i-demultiplexed-seqs paired-end-demux.qza \
   --o-joined-sequences joined.qza
##类似于上面的可视化
(qiime2-2019.4) [zxia@moon qiime]$ qiime demux summarize \
   --i-data joined.qza \
   --o-visualization joined.qzv
#质控以及质控前后序列数量比较的table的输出
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime quality-filter q-score-joined \
  --i-demux joined.qza \
  --o-filtered-sequences joined-filtered.qza \
  --o-filter-stats joined-filtered-stats.qza
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime metadata tabulate \
  --m-input-file joined-filtered-stats.qza \
  --o-visualization joined-filtered-stats.qzv

(qiime2-2019.4) [zxia@moon 16S_results]$ qiime deblur denoise-16S \
  --i-demultiplexed-seqs joined-filtered.qza \
  --p-trim-length 240 \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --p-sample-stats \
  --o-stats deblur-stats.qza
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime deblur visualize-stats \
  --i-deblur-stats deblur-stats.qza \
  --o-visualization delbur-stats.qzv
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file metadata.tsv
 #各个sOTU的代表序列及系统发育树的构建
 (qiime2-2019.4) [zxia@moon 16S_results]$ qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
  
 (qiime2-2019.4) [zxia@moon 16S_results]$ qiime alignment mafft \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seq.qza 
  
  (qiime2-2019.4) [zxia@moon 16S_results]$ qiime alignment mask \
  --i-alignment aligned-rep-seq.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
 
 (qiime2-2019.4) [zxia@moon 16S_results]$ qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza

(qiime2-2019.4) [zxia@moon 16S_results]$ qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

#alpha & beta diversity
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 4000 \
  --m-metadata-file metadata.tsv \
  --output-dir metrics
##警告信息
#Plugin error from diversity:

#Provided max_depth of 10000 is greater than the maximum sample total frequency of the feature_table (6176).

#Debug info has been saved to /tmp/qiime2-q2cli-err-wte35yfn.log

# 用以下两个命令可以根据metrics中的各项diversity table制图，并判断significance levels。
# （不截图了，真的很丑，建议自己画）
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime diversity alpha-group-significance \
  --i-alpha-diversity metrics/faith_pd_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/faith_pd_vector.qzv

(qiime2-2019.4) [zxia@moon 16S_results]$ qiime emperor plot \
  --i-pcoa metrics/weighted_unifrac_pcoa_results.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/weighted_unifrac_emperor.qzv   
  
 # 生成rarefaction curve.这里是按照meta data分组的，如果想看所有samples的，则去掉--m-metadata-file即可
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --p-max-depth 10000 \
  --i-phylogeny rooted-tree.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization rare.qzv
 
 # 生成所有samples的rarefaction curve.

(qiime2-2019.4) [zxia@moon 16S_results]$ qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --p-max-depth 5000 \
  --i-phylogeny rooted-tree.qza \
  --o-visualization rare-allsamples.qzv
#物种注释
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime feature-classifier classify-sklearn \
 --i-classifier gg-13-8-99-nb-classifier.qza \
 --i-reads rep-seqs.qza \
 --o-classification taxonomy.qza

(qiime2-2019.4) [zxia@moon 16S_results]$ qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
# 这是一个可以观察物种组成（优势物种）的bar图，可以选择不同的物种levels绘制。
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime taxa barplot \
 --i-table table.qza \
 --m-metadata-file metadata.tsv \
 --i-taxonomy taxonomy.qza \
 --o-visualization taxa-bar.qzv
# Beta Diversity Ordination
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime emperor plot \
  --i-pcoa metrics/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization metrics/unweighted_unifrac_emperor-bydayssinece.qzv
#Practicum: Beta Diversity Group Significance
(qiime2-2019.4) [zxia@moon 16S_results]$ qiime diversity beta-group-significance \
  --i-distance-matrix metrics/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column group \
  --p-pairwise \
  --o-visualization metrics/unweighted_unifrac_significance.qzv





