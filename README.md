# BingleSeq
BingleSeq - A user-friendly R package for Bulk and Single-cell RNA-Seq data analyses.

Manuscript available as a [PeerJ publication](https://doi.org/10.7717/peerj.10469).


### Installation

BingleSeq can be installed directly from GitHub using the following code:

```
library("devtools")
install_github("dbdimitrov/BingleSeq")

# Start the application
library(BingleSeq)
startBingleSeq()
```


### Prerequisites

BingleSeq requires R>= 3.6.3


## About
BingleSeq provides a comprehesnive solution to both Bulk and scRNA-Seq analyses, as such it is best to look at BingleSeq as two separate parts.


### Bulk RNA-Seq
The Bulk RNA-Seq part follows the structure of a typical pipeline used for the DE analysis of Bulk RNA-Seq count data and it makes use of differential expression packages DESeq2 (Love, Huber, and Anders, 2014), edgeR (Robinson et al., 2010), and Limma (Ritchie et al., 2015).

![BingleSeq Bulk RNA-Seq pipeline](/figures/Bulk.png)


#### Input

BingleSeq's Bulk RNA-Seq pipeline accepts count tables in the following format:

![BingleSeq Bulk RNA-Seq format](/figures/Bulk_format.jpg)

**Note that a metadata table must also be provided for the Bulk RNA-Seq pipeline.**

#### Metadata table format
A metadata table is also required and its appropriate formating is key for the acquisition of correct results using the Bulk RNA-Seq part of the application. Metadata tables must be in this specific format:

![BingleSeq Bulk meta format](/figures/meta_format.jpg)

*The use of metadata tables was insipired by similar applications preceding BingleSeq - DEapp and DEBrowser (Li and Andrade, 2017; Kucukural et al., 2019).*



### scRNA-Seq
The scRNA-Seq part is based on Seurat’s pipeline (Satija et al., 2015) and follows a typical scRNA-Seq count analysis structure. Furthermore, clustering can be performed with monocle and SC3 packages (Trapnell et al., 2014; Kiselev et al., 2017). 

![BingleSeq Single-Cell RNA-Seq pipeline](/figures/sc.jpg)


#### Input

BingleSeq's scRNA-Seq pipeline accepts 10x genomics data as well as count tables in the following format:

![BingleSeq Bulk RNA-Seq format](/figures/sc_format.jpg)



## Typical Workflow

### Bulk RNA-Seq Data analysis typical workflow.

#### 0. Data used
For the purpose of representation, a simulated two-group dataset with 4 replicates was generated with compcodeR package (Soneson, 2014).

#### 1.	Load Count Table and Metadata Table
To begin DE analysis of Bulk RNA-Seq data, first a count table with a specific format (shown above) must be loaded. BingleSeq allows some flexibility in terms of the ‘separator’ used. Once a count table is loaded, it is displayed to allow the user to check whether it was loaded appropriately. A metadata table is also required in a specific format (shown above).

![BingleSeq Bulk RNA-Seq Load Data](/figures/bulk_loadData.PNG)




#### 2.	Quality Control
When a count table is uploaded the ‘Quality Control’ tab is generated. This tab enables the user to filter genes below certain counts per million (CPM), Max, or Median thresholds. The results of the filtering and the raw data are displayed as summary tables, alongside histograms.

![BingleSeq Bulk RNA-Seq QC Data](/figures/bulk_qcData.PNG)

Moreover, if required Batch effect correction is available with Harman and ComBat packages (Leek et al. 2016; Oytam et al., 2019).

![BingleSeq Bulk RNA-Seq Batch Correction](/figures/batchCorrected.jpg)
*Batch effect corrected using Harman package on example data acquired from HarmanData package (Bowden, Ross, Oytam, 2019).*


#### 3.	Differential Expression 
Subsequent to filtering is the ‘Differential Expression’ tab, where the user is given the option to run DESeq2, edgeR, and limma pipelines. Upon DE pipeline completion, the results are displayed as a table that contains the log2 expression fold-change (logFC), package specific test statistics, p-value, and multiple-testing adjusted p-value (FDR).

![BingleSeq Bulk RNA-Seq de Data](/figures/bulk_deData.PNG)

*Note that normalization between samples is done automatically with DE analysis using the package-specific methods for DESeq2 and edgeR, while limma also uses edgeR’s TMM normalization approach.*



#### 4.	Visualization
In a typical DE analysis workflow, the next stage following DE analysis would be to proceed to the various visualization techniques. BingleSeq offers this functionality within the ‘Visualize Data’ tab, which allows users to pick from several key plotting techniques. Including A) Barchart plot presenting the number of up- and downregulated genes B) PCA plot, C) Volcano plot, and D) MA plot. Note that these results were generated with limma using real data taken from McFarlane et al., 2019.

![BingleSeq Bulk RNA-Seq de Data](/figures/bulk_visData.PNG)


BingleSeq's visualization techniques were implemented with customization in mind, as users can specify parameters such as p-value threshold, fold-change threshold, and contrast of interest. Due to their versatility, heatmaps were designed as BingleSeq’s most customizable plotting component. Furthemore, users can download the genes displayed in the heatmap.

![BingleSeq Bulk RNA-Seq heat Data](/figures/bulk_heatmap.PNG)

#### Functional Annotation
##### 5a.	Over-representation Analysis
Following DE analysis, BingleSeq enables the Functional Annotation analysis of DE results within the ‘Functional Annotation’ tab via GOseq package (Young et al., 2010). The GOseq pipeline enables users to obtain results from KEGG pathway analysis and three types of GO categories, including ‘Cellular Component’, ‘Molecular Function’, and ‘Biological Function’. To run the pipeline users are first prompted to filter the DEGs according to logFC and adjusted p-value (FDR). Users can then select several parameters before running the pipeline with the previously obtained subset of DEGs. These parameters include the GO category, multiple-testing corrected or uncorrected p-value, gene symbol type, and genome of interest.

Users can also generate GO term histograms with the top 10 GO terms and to choose whether to display their GO identifiers (GO:IDs) or their corresponding terms.

![BingleSeq Bulk RNA-Seq bulkGO hist](/figures/bulk_GOhist.jpg)

Moreover, users can obtain further information about a given GO term by querying its GO:ID using the ‘GO.db’ package (Carlson et al., 2019). 

![BingleSeq Bulk RNA-Seq bulkGO query](/figures/bulk_GOquery.PNG)

##### As of v3.6, BingleSeq implements the following GOSeq Model organisms:
Homo sapiens, Mus musculus, Danio rerio, Drosophila melanogaster, E. coli K12.
Please do not hesitate to contact us or open a GitHub issue if you want us to include additional model organism.
However, it should be noted that GOSeq requires gene lengths for its usual functions and not all model organisms' genomes have such available.
Refer to the GOSeq manual for further information as well as a way to obtain 

![BingleSeq Bulk RNA-Seq bulkGO Tab](/figures/bulk_GOtab.PNG)

Once the GOseq pipeline is run and completed, a table with results is returned.

![BingleSeq Bulk RNA-Seq bulkGO Results](/figures/bulk_GOresults.PNG)

##### 5b.	Footprint Analysis
BingleSeq also enables the use of footprint analysis tools DoRothEA and PROGENy
(Schubert et al., 2018; Garcia-Alonso, et al., 2019; Holland et al., 2019,
Holland et al., 2020). These tools are used infer the activity of TFs and
pathways, respectively. Footprint-based strategies such as the aforementioned
packages infer TF/pathway activity from the expression of molecules considered
to be downstream of a given TF or pathway (in the case of these tools).

DoRothEA is a gene set resource containing signed TF-target interactions that 
can be coupled with different statistical methods to estimate TF activity.
In BingleSeq, DoRothEA is coupled to the statistical method VIPER
(Alvarez et al., 2016).
PROGENy is based on downstream gene signatures observed to be consistently
deregulated in pertrubation experiments. PROGENy estimates the activity of 14
signalling pathways from gene expression using a linear model.
For more information, please refer to the cited publications.
DoRothEA and PROGENy are available for mouse and human data.

![BingleSeq Bulk RNA-Seq Footprint Analysis Results](/figures/footprint.PNG)
A) TF activities (using DE method statistic - e.g. t-value) and B) TF activities per sample (using normalized gene counts) estimated with DoRothEA and viper.
Pathway activity estimation with PROGENy showing C) the Normalized Enrichment Scores (NES) for each pathway and D) PROGENy pathway scores per sample.

*Note that these results were generated using real data taken from McFarlane et al., 2019.*  

#### 6.	DE Package Comparison
BingleSeq supplies users with an option to assess the agreement between the different DE analysis packages. This is done using a Venn diagram which represents the overlap of DE analysis results obtained using DESeq2, edgeR, and limma on the same dataset. Moreover, users can download the genes from the different intersects of the Venn Diagram. 

![BingleSeq Bulk RNA-Seq compVenn Data](/figures/bulk_compVenn.PNG)

Furthermore, the DE results from the same packages are used to generate a **Rank-based consensus**. The Rank-based consensus is displayed as a table, alongside adjusted p-values and the ranks for each gene as calculated by the different packages.

![BingleSeq Bulk RNA-Seq compRank Data](/figures/bulk_compRank.PNG)




### Single-Cell RNA-Seq Data analysis typical workflow.

#### 0. Data used
For the purpose of representation, a 10x genomics dataset was utilized (https://bit.ly/2Z3IUUk), which is also used in the Seurat package tutorial (https://bit.ly/2HlBfKx).
  
  
#### 1.	Load Count Data
To begin the analysis of scRNA-Seq data, users can supply gene count data in two input types. The first input type is ‘10x Genomics data’ in the form of a directory containing 10x Genomics protocol output files. These files include a matrix.mtx, barcodes.tsv, and genes.tsv files which represent the expression matrix, cell barcodes, and gene symbols, respectively. The second input type is a count table which must follow a specific format (shown above).
  
  
#### 2.	Quality Control
Once the data is loaded, the ‘Quality Control’ tab is generated which enables users to filter unwanted cells and features. Users can filter genes detected below a certain number of cells and cells with less than a certain number of expressed genes. These parameters are used when creating the initial Seurat object. Cell outliers can then be filtered according to the number of expressed features (i.e. genes) per cell. Visual aid is provided for filtering in terms of Violin plots which represent the number of genes (nFeature) and unique molecules (nCount_RNA) per cell.

![BingleSeq Bulk RNA-Seq sc qcData](/figures/sc_qcData.PNG)
  
  
#### 3.	Normalization
After excluding unwanted cells and features from the dataset, the next step is to normalize the data. BingleSeq provides two Seurat-based global-scaling normalization options. The first one is the “LogNormalize” method in which gene counts for each cell are divided by the total counts for that cell, multiplied by a ‘scale factor’, and then natural-log transformed. The second method is “Relative Counts” which follows the same procedure excluding the log transformation. Seurat's authors recommend using the former method when working with integer counts and the latter when working with relative counts. 10e4 is the recommended and default scale factor option, but when using CPM values the scale factor should be set to 10e6.

Simultaneously with normalization, the highly variable features within the dataset are identified and these features are later used when clustering with Seurat.

![BingleSeq Bulk RNA-Seq sc normData](/figures/sc_normData.PNG)

Once normalization and feature selection methods are complete, a Variable Features plot is returned and displayed. Seurat’s ‘Feature Selection’ methods include “VST”, “Mean Variance Plot”, and “Dispersion”.

![BingleSeq Bulk RNA-Seq sc varPlot](/figures/sc_variancePlot.PNG)
*This plot was genered using the recommended/default settings and the "VST" variance estimation method.*
  
*Note that ‘Feature selection’ does not apply to monocle and SC3 clustering approaches and hence their inbuilt pre-clustering filter procedures were implemented. These procedures have a similar purpose to Seurat’s ‘Feature Selection’, as they can be used to filter out unwanted noise.*
  
  
#### 4.	Clustering
Following normalization, the ‘Clustering’ tab is generated which implements functionality for scaling of the data, dimensionality reduction with PCA, PC selection, and unsupervised clustering. The former three are done simultaneously and Seurat’s ‘PCElbowPlot’ is used to generate and return an elbow plot. The returned elbow plot serves as a heuristic method for determining the true dimensionality of the dataset (i.e. PC Selection). Selecting which PCs to include in Seurat and monocle clustering methods is an essential step as it enables a large portion of technical noise to be excluded.

![BingleSeq Bulk RNA-Seq sc clustEblow](/figures/sc_clustElbow.PNG)
  
  
In addition to the Elbow plot, BingleSeq implements Seurat's PC heatmaps option - to be used as a complementary tool to the elbow plot.
  
![BingleSeq Bulk RNA-Seq sc clustHeat](/figures/sc_clustHeat.PNG)

*A) represents the 1st PC Heatmap with the top 10 most variable Genes and it is highly likely to represent part of the true dimensionality of the dataset. In contrast, B) represents the 15th PC Heatmap which likely represent mainly noise and not true signal.*



Once the count data is scaled and linear dimensionality reduction performed, users can proceed to unsupervised clustering with Seurat, SC3, and monocle. 

When using Seurat for unsupervised clustering, users must specify the number of PCs to be included in the analysis as well as the value of its ‘Resolution’ parameter. The latter parameter is used to set the ‘granularity’ of the clustering and as such it controls the number of clusters. The authors suggest that the optimal Resolution for datasets with ~3000 cells is 0.6-1.2 and it is typically higher for larger datasets. Users can also choose from Seurat’s inbuilt algorithms including Louvain and SLM algorithms.

![BingleSeq Bulk RNA-Seq sc clustSeurat](/figures/sc_clustSeurat.PNG)

*tSNE plot produced using 0.5 as granularity parameter and the first 10 PCs.*
  
  
When clustering with monocle, users are requested to specify the number of PCs to be included in the analysis. Also, if required users can further minimize noise by filtering the gene counts according to the minimum expression level via the ‘Lower Detection Parameter’. Users can also pick from monocle’s inbuilt algorithms, which include Density Peak and Louvain algorithms. Furthermore, Monocle enables the number of clusters to be explicitly specified as well as to be estimated.
  
  
![BingleSeq Bulk RNA-Seq sc clustMono](/figures/sc_clustMonocle.PNG)

*tSNE plot produced by explicitly setting the number of clusters to 9 and using the first 10 PCs (without any additional filtering).*


Unsupervised clustering with SC3 in BingleSeq utilizes SC3's k-means-based clusering approach. Users must specify the number of random initial centroid selections (sets). A larger number of initial centroid configurations (nStart) is likely to produce a better clustering result, but has a high toll on computational time. By default, this parameter is set to 1000 when working with less than 2000 cells and to 50 when working with more than 2000 cells, in accordance to the authors recommendantions.
Users can also use SC3’s inbuilt filtering options to further reduce noise by filtering out genes below and above certain dropout (zero value) percentage thresholds. Similarly to monocle, the number of clusters can be supplied by user or estimated with SC3.
It is worth noting that the k-means approach of SC3 is likely too computationally demanding when working with large datasets (e.g. when N=2000, computational time is ~20 mins), hence future updates of BingleSeq are likely to also implement SC3's SVM-hybrid approach as an alternative solution. 

![BingleSeq Bulk RNA-Seq sc clustSC3](/figures/sc_clustSC3.PNG)

*tSNE plot produced by explicitly setting the number of clusters to 9 and 50 random initial centroid sets (without any additional filtering).*
  
  
*Each tSNE plot in BingleSeq is generated using the package with which clustering was performed.
Also, when performing clustering with SC3 or monocle, the data used to create the required objects to run these pipelines is the same data that was previously filtered, normalized, and scaled using Seurat’s pipeline.*


#### 5.	Differential Expression
Following clustering, DE analysis can be conducted using Seurat’s inbuilt functionality to identify marker genes. Users can perform marker gene identification using the following inbuilt DE testing methods: Student’s T test, Wilcoxon Rank Sum test, and Logistic regression. Additionally, DE analysis can also be performed with DESEq2 and MAST packages (Love, Huber, and Anders, 2014; Finak et al., 2015). Prior to running DE analysis, users are prompted to enter the following filtering parameters: genes expressed in a minimum fraction of cells, fold-change, and adjusted p-value.

![BingleSeq Bulk RNA-Seq sc deTab](/figures/sc_deTab.PNG)

Furthermore, by using Seurat’s inbuilt visualization options, BingleSeq provides tools for the exploration of DE results. These tools include cluster heatmap with user-specified gene number as well as exploration of specific genes via Violin, Feature, and Ridge plots.

![BingleSeq Bulk RNA-Seq sc deFigs](/figures/sc_deFigs.PNG)

*A) Heatmap showing the top 10 genes for each cluster in the 2700 PBMCs dataset, while Violin B), Feature C), and Ridge D) plots are shown for MS4A1 gene – a biomarker of B lymphocytes.*


#### 6.	Functional Annotation
The scRNA-Seq pipeline of BingleSeq incorporates functional annotation in an analogous manner to its Bulk RNA-Seq counterpart. The only difference is that the subsets of DEGs to be used in the GOseq pipeline can be filtered according to the cluster they belong to; thus, allowing users to assess each cluster independently. Accordingly, it also implements both PROGENy and Dorothea-Viper which were implemented to estimate Pathway and TF activity per cell cluster, respectively.
  
  
#### 7.	DE Method Comparison
The scRNA-Seq part also implements a ‘DE Method Comparison’ tab analogous to the ‘DE Package Comparison’ tab in Bulk RNA-Seq. The only difference is that scRNA-Seq Overlap functionality enables filtering according to the same parameters used in marker gene identification. Furthermore, rather than comparing the different packages, it compares the DE Methods implemented within Seurat. These include: DE testing with MAST, Wilcoxon Rank Sum Test, and Student’s T test.

*Also, note that Rank-based consensus is yet to be implemented for the scRNA-Seq pipeline.*

## Test Data
As of v0.3.2 BingleSeq features test data for both Bulk- and scRNA-Seq.
Bulk data - contrast between HSV-1 infected control and interferon B treatment (taken from McFarlane et al., 2019) 
Single cell data - Cell Ranger 10x Genomics public dataset looking at filtered data of 2700 PBMCs
[10x Genomics link](https://support.10xgenomics.com/single-cell-multiome-atac-gex/datasets/1.0.0/pbmc_unsorted_3k)



## Built With

* [shiny](https://shiny.rstudio.com/)
* [RStudio](https://www.rstudio.com/)


## References
Alvarez M.J., Shen Y., Giorgi F.M., Lachmann A., Ding B.B., Ye B.H., Califano A. (2016). “Functional characterization of somatic mutations in cancer using network-based inference of protein activity.” Nature genetics, 48(8), 838–47.

Alvarez MJ, Shen Y, Giorgi FM, Lachmann A, Ding BB, Ye BH, Califano A (2016). “Functional characterization of somatic mutations in cancer using network-based inference of protein activity.” Nature genetics, 48(8), 838–47.

Bowden J, Ross J, Oytam Y (2019). HarmanData: Data for the Harman package. R package version 1.12.0, http://www.bioinformatics.csiro.au/harman/.

Carlson, M. Falcon, S., Pages, H., Li, N., 2019. GO.db: A set of annotation maps describing the entire Gene Ontology. R package version 3.8.2.

Finak, G., McDavid, A., Yajima, M., Deng, J., Gersuk, V., Shalek, A.K., Slichter, C.K., Miller, H.W., McElrath, M.J., Prlic, M. and Linsley, P.S., 2015. MAST: a flexible statistical framework for assessing transcriptional changes and characterizing heterogeneity in single-cell RNA sequencing data. Genome biology, 16(278) doi: 10.1186/s13059-015-0844-5.

Garcia-Alonso L, Holland CH, Ibrahim MM, Turei D, Saez-Rodriguez J. "Benchmark and integration of resources for the estimation of human transcription factor activities." Genome Research. 2019. DOI: 

Holland CH, Szalai B, Saez-Rodriguez J. "Transfer of regulatory knowledge from human to mouse for functional genomics analysis." Biochimica et Biophysica Acta (BBA) - Gene Regulatory Mechanisms. 2019. DOI: 10.1016/j.bbagrm.2019.194431.

Holland CH, Tanevski J, Perales-Patón J, Gleixner J, Kumar MP, Mereu E, Joughin BA, Stegle O, Lauffenburger DA, Heyn H, Szalai B, Saez-Rodriguez, J. "Robustness and applicability of transcription factor and pathway analysis tools on single-cell RNA-seq data." Genome Biology. 2020. DOI: 10.1186/s13059-020-1949-z.

Kiselev, V.Y., Kirschner, K., Schaub, M.T., Andrews, T., Yiu, A., Chandra, T., Natarajan, K.N., Reik, W., Barahona, M., Green, A.R. and Hemberg, M., 2017. SC3: consensus clustering of single-cell RNA-seq data. Nature methods, 14(5), pp. 483–486.

Kucukural, A., Yukselen, O., Ozata, D.M., Moore, M.J. and Garber, M., 2019. DEBrowser: interactive differential expression analysis and visualization tool for count data. BMC genomics, 20(6). DOI: https://doi.org/10.1186/s12864-018-5362-x

Leek JT, Johnson WE, Parker HS, Fertig EJ, Jaffe AE, Storey JD, Zhang Y, Torres LC (2019). sva: Surrogate Variable Analysis. R package version 3.32.1.

Li, Y. and Andrade, J., 2017. DEApp: an interactive web interface for differential expression analysis of next generation sequence data. Source code for biology and medicine, 12(2), doi: 10.1186/s13029-017-0063-4

Love, M.I., Huber, W. and Anders, S., 2014. Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome biology, 15(12). doi:10.1186/s13059-014-0550-8

McFarlane, S., Orr, A., Roberts, A.P., Conn, K.L., Iliev, V., Loney, C., da Silva Filipe, A., Smollett, K., Gu, Q., Robertson, N. and Adams, P.D., 2019. The histone chaperone HIRA promotes the induction of host innate immune defences in response to HSV-1 infection. PLoS pathogens, 15(3). doi:10.1371/journal.ppat.1007667

Oytam Y, Sobhanmanesh F, Duesing K, Bowden JC, Osmond-McLeod M, Ross J (2016). “Risk-conscious correction of batch effects: maximising information extraction from high-throughput genomic datasets.” BMC Bioinformatics, 17(1), 1–17. doi: 10.1186/s12859-016-1212-5, http://dx.doi.org/10.1186/s12859-016-1212-5.

Ritchie, M.E., Phipson, B., Wu, D., Hu, Y., Law, C.W., Shi, W. and Smyth, G.K., 2015. limma powers differential expression analyses for RNA-sequencing and microarray studies. Nucleic acids research, 43(7), pp.e47-e47.

Robinson, M.D., McCarthy, D.J. and Smyth, G.K., 2010. edgeR: a Bioconductor package for differential expression analysis of digital gene expression data. Bioinformatics, 26(1), pp.139-140.

Satija, R., Farrell, J.A., Gennert, D., Schier, A.F. and Regev, A., 2015. Spatial reconstruction of single-cell gene expression data. Nature biotechnology, 33(5), pp.495-502.

Schubert M, Klinger B, Klünemann M, Sieber A, Uhlitz F, Sauer S, Garnett MJ, Blüthgen N, Saez-Rodriguez J (2018). “Perturbation-response genes reveal signaling footprints in cancer gene expression.” Nature communications, 9(20).

Soneson, C., 2014. compcodeR—an R package for benchmarking differential expression methods for RNA-seq data, Bioinformatics, 30(17), pp.2517–2518.

Trapnell, C., Cacchiarelli, D., Grimsby, J., Pokharel, P., Li, S., Morse, M., Lennon, N.J., Livak, K.J., Mikkelsen, T.S. and Rinn, J.L., 2014. The dynamics and regulators of cell fate decisions are revealed by pseudotemporal ordering of single cells. Nature biotechnology, 32(4), pp. 381–386.

Young, M.D., Wakefield, M.J., Smyth, G.K. and Oshlack, A., 2010. Gene ontology analysis for RNA-seq: accounting for selection bias. Genome biology, 11(R14). doi: https://doi.org/10.1186/gb-2010-11-2-r14.



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details



## R Session Info:
R version 4.0.3 (2020-10-10)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 20.04.1 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

locale:
 [1] LC_CTYPE=en_US.UTF-8      
 [2] LC_NUMERIC=C              
 [3] LC_TIME=de_DE.UTF-8       
 [4] LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=de_DE.UTF-8   
 [6] LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=de_DE.UTF-8      
 [8] LC_NAME=C                 
 [9] LC_ADDRESS=C              
[10] LC_TELEPHONE=C            
[11] LC_MEASUREMENT=de_DE.UTF-8
[12] LC_IDENTIFICATION=C       

attached base packages:
 [1] splines parallel stats4   
 [4] grid stats  graphics 
 [7] grDevices utils  datasets 
[10] methods base     

other attached packages:
 [1] BingleSeq_0.3.6            
 [2] org.Hs.eg.db_3.11.4        
 [3] viper_1.24.0               
 [4] plotly_4.9.3               
 [5] dorothea_1.0.1             
 [6] progeny_1.10.0             
 [7] forcats_0.5.0              
 [8] stringr_1.4.0              
 [9] purrr_0.3.4                
[10] readr_1.4.0                
[11] tidyr_1.1.2                
[12] tibble_3.0.5               
[13] tidyverse_1.3.0            
[14] pheatmap_1.0.12            
[15] GO.db_3.11.4               
[16] AnnotationDbi_1.52.0       
[17] goseq_1.40.0               
[18] geneLenDataBase_1.24.0     
[19] BiasedUrn_1.07             
[20] SC3_1.16.0                 
[21] scran_1.16.0               
[22] Seurat_3.2.3               
[23] monocle_2.16.0             
[24] DDRTree_0.1.5              
[25] irlba_2.3.3                
[26] VGAM_1.1-4                 
[27] Matrix_1.2-18              
[28] MAST_1.14.0                
[29] SingleCellExperiment_1.10.1
[30] edgeR_3.30.3               
[31] limma_3.44.3               
[32] DESeq2_1.28.1              
[33] SummarizedExperiment_1.20.0
[34] Biobase_2.50.0             
[35] MatrixGenerics_1.2.0       
[36] matrixStats_0.57.0         
[37] GenomicRanges_1.42.0       
[38] GenomeInfoDb_1.26.2        
[39] IRanges_2.24.1             
[40] S4Vectors_0.28.1           
[41] BiocGenerics_0.36.0        
[42] sva_3.36.0                 
[43] BiocParallel_1.24.1        
[44] genefilter_1.70.0          
[45] mgcv_1.8-33                
[46] nlme_3.1-149               
[47] Harman_1.16.0              
[48] ggrepel_0.8.2              
[49] gridExtra_2.3              
[50] reshape2_1.4.4             
[51] fastcluster_1.1.25         
[52] factoextra_1.0.7           
[53] VennDiagram_1.6.20         
[54] futile.logger_1.4.3        
[55] ggplot2_3.3.2              
[56] DT_0.17                    
[57] dplyr_1.0.2                
[58] waiter_0.2.0               
[59] shinyWidgets_0.5.4         
[60] shinyFiles_0.9.0           
[61] shinyjs_2.0.0              
[62] shiny_1.5.0                

loaded via a namespace (and not attached):
  [1] rsvd_1.0.3               
  [2] ica_1.0-2                
  [3] class_7.3-17             
  [4] ps_1.5.0                 
  [5] Rsamtools_2.4.0          
  [6] foreach_1.5.1            
  [7] lmtest_0.9-38            
  [8] rprojroot_2.0.2          
  [9] crayon_1.3.4             
 [10] MASS_7.3-53              
 [11] WriteXLS_6.1.0           
 [12] backports_1.2.1          
 [13] qlcMatrix_0.9.7          
 [14] reprex_0.3.0             
 [15] rlang_0.4.10             
 [16] XVector_0.30.0           
 [17] ROCR_1.0-11              
 [18] readxl_1.3.1             
 [19] callr_3.5.1              
 [20] scater_1.16.2            
 [21] bcellViper_1.24.0        
 [22] bit64_4.0.5              
 [23] glue_1.4.2               
 [24] rngtools_1.5             
 [25] sctransform_0.3.1        
 [26] processx_3.4.5           
 [27] vipor_0.4.5              
 [28] haven_2.3.1              
 [29] tidyselect_1.1.0         
 [30] usethis_2.0.0            
 [31] fitdistrplus_1.1-3       
 [32] XML_3.99-0.5             
 [33] zoo_1.8-8                
 [34] GenomicAlignments_1.24.0 
 [35] xtable_1.8-4             
 [36] magrittr_2.0.1           
 [37] cli_2.2.0                
 [38] zlibbioc_1.36.0          
 [39] rstudioapi_0.13          
 [40] doRNG_1.8.2              
 [41] miniUI_0.1.1.1           
 [42] rpart_4.1-15             
 [43] lambda.r_1.2.4           
 [44] BiocSingular_1.4.0       
 [45] askpass_1.1              
 [46] pkgbuild_1.2.0           
 [47] cluster_2.1.0            
 [48] listenv_0.8.0            
 [49] Biostrings_2.56.0        
 [50] png_0.1-7                
 [51] future_1.21.0            
 [52] withr_2.4.1              
 [53] bitops_1.0-6             
 [54] slam_0.1-48              
 [55] plyr_1.8.6               
 [56] cellranger_1.1.0         
 [57] pcaPP_1.9-73             
 [58] sparsesvd_0.2            
 [59] e1071_1.7-4              
 [60] dqrng_0.2.1              
 [61] pillar_1.4.7             
 [62] cachem_1.0.1             
 [63] GenomicFeatures_1.40.1   
 [64] fs_1.5.0                 
 [65] kernlab_0.9-29           
 [66] DelayedMatrixStats_1.10.1
 [67] vctrs_0.3.6              
 [68] ellipsis_0.3.1           
 [69] generics_0.1.0           
 [70] devtools_2.3.2           
 [71] tools_4.0.3              
 [72] beeswarm_0.2.3           
 [73] munsell_0.5.0            
 [74] DelayedArray_0.16.0      
 [75] fastmap_1.1.0            
 [76] HSMMSingleCell_1.8.0     
 [77] compiler_4.0.3           
 [78] pkgload_1.1.0            
 [79] abind_1.4-5              
 [80] httpuv_1.5.4             
 [81] rtracklayer_1.48.0       
 [82] segmented_1.3-1          
 [83] sessioninfo_1.1.1        
 [84] clipr_0.7.1              
 [85] GenomeInfoDbData_1.2.4   
 [86] lattice_0.20-41          
 [87] deldir_0.2-3             
 [88] later_1.1.0.1            
 [89] BiocFileCache_1.12.1     
 [90] jsonlite_1.7.2           
 [91] scales_1.1.1             
 [92] docopt_0.7.1             
 [93] pbapply_1.4-3            
 [94] lazyeval_0.2.2           
 [95] promises_1.1.1           
 [96] spatstat_1.64-1          
 [97] doParallel_1.0.16        
 [98] goftest_1.2-2            
 [99] spatstat.utils_1.17-0    
[100] reticulate_1.18          
[101] cowplot_1.1.0            
[102] statmod_1.4.35           
[103] Rtsne_0.15               
[104] uwot_0.1.9               
[105] igraph_1.2.6             
[106] survival_3.2-7           
[107] yaml_2.2.1               
[108] htmltools_0.5.1.1        
[109] memoise_2.0.0            
[110] locfit_1.5-9.4           
[111] viridisLite_0.3.0        
[112] digest_0.6.27            
[113] rrcov_1.5-5              
[114] assertthat_0.2.1         
[115] mime_0.9                 
[116] rappdirs_0.3.2           
[117] densityClust_0.3         
[118] futile.options_1.0.1     
[119] RSQLite_2.2.1            
[120] future.apply_1.6.0       
[121] remotes_2.2.0            
[122] data.table_1.13.4        
[123] blob_1.2.1               
[124] fastICA_1.2-2            
[125] labeling_0.4.2           
[126] mixtools_1.2.0           
[127] RCurl_1.98-1.2           
[128] broom_0.7.2              
[129] hms_0.5.3                
[130] modelr_0.1.8             
[131] colorspace_2.0-0         
[132] ggbeeswarm_0.6.0         
[133] Rcpp_1.0.6               
[134] RANN_2.6.1               
[135] mvtnorm_1.1-1            
[136] fansi_0.4.2              
[137] parallelly_1.22.0        
[138] R6_2.5.0                 
[139] ggridges_0.5.2           
[140] lifecycle_0.2.0          
[141] formatR_1.7              
[142] curl_4.3                 
[143] leiden_0.3.6             
[144] testthat_3.0.1           
[145] robustbase_0.93-6        
[146] desc_1.2.0               
[147] RcppAnnoy_0.0.17         
[148] RColorBrewer_1.1-2       
[149] iterators_1.0.13         
[150] htmlwidgets_1.5.3        
[151] polyclip_1.10-0          
[152] biomaRt_2.44.4           
[153] crosstalk_1.1.1          
[154] rvest_0.3.6              
[155] globals_0.14.0           
[156] openssl_1.4.3            
[157] patchwork_1.1.0          
[158] codetools_0.2-16         
[159] lubridate_1.7.9.2        
[160] FNN_1.1.3                
[161] prettyunits_1.1.1        
[162] dbplyr_2.0.0             
[163] gtable_0.3.0             
[164] DBI_1.1.0                
[165] tensor_1.5               
[166] httr_1.4.2               
[167] KernSmooth_2.23-17       
[168] stringi_1.5.3            
[169] progress_1.2.2           
[170] farver_2.0.3             
[171] annotate_1.68.0          
[172] viridis_0.5.1            
[173] xml2_1.3.2               
[174] combinat_0.0-8           
[175] BiocNeighbors_1.6.0      
[176] geneplotter_1.66.0       
[177] scattermore_0.7          
[178] DEoptimR_1.0-8           
[179] bit_4.0.4                
[180] spatstat.data_1.5-2      
[181] pkgconfig_2.0.3