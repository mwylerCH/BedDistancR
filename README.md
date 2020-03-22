# BedDistancR

Users of [Bedtools](https://bedtools.readthedocs.io/en/latest/index.html) and genome annotations in [Bed format](https://www.ensembl.org/info/website/upload/bed.html) maybe noticed that missing task: calculating the physical distance between genomic features. In fact [bedtool closest](https://bedtools.readthedocs.io/en/latest/content/tools/closest.html) allows only to calculate the distance between to proximal features. Following the UNIX phylosophy to create one software for one task, BedDistancR is the attempt to fill this gap. Don’t hesitate to communicate any issues.

Download and Usage
----------------------

The only dependency is the R package [data.table](https://cran.r-project.org/web/packages/data.table/). This should be automatically downloaded in case it’s missing. Clone the repository and use BedDistancR as follow:
```
$ Rscript /path/to/BedDistancR/BedDistanc.R <FILE1.bed> [FILE2.bed] 
```
By default the results appear as **STDOUT**, but they can be redirected with *"> results.txt"*

If only **FILE1.bed** is supplied, then the reciprocal distance is calculated. All input files need to follow the BED standards with at least  chromosomal column, start coordinates and end coordinates separated by tab. Supplementary columns are possible and will be also outputted. Sorting or ordering are not needed.
```
Chr1	2	24	GeneA
Chr1	562	272	GeneB
Chr3	37	500	GeneC
Chr1    185     203     GeneD

```
BedDistancR is optimized for large files. If many features are annotated on the same chromosome, the STDOUT can appear only with a short delay.
The output contains all possible pairings with the features contained in FILE1.bed. The last column (*‘distance’*) indicates the bp distance to other features  (defined with *‘chrom.y’*, *‘Start.y’* and *‘End.y’*).

```
chrom.x	Start.x	End.x	V4	chrom.y	Start.y	End.y	V4	distance
Chr1	2	24	GeneA	Chr1	562	272	GeneB	248
Chr1	2	24	GeneA	Chr1	185	203	GeneD	161
Chr1	185	203	GeneD	Chr1	562	272	GeneB	69
```


Technical
---------------
Developed with R version 3.5.1 and [data.table](https://cran.r-project.org/web/packages/data.table/) version 1.11.8 on a Ubuntu 16.06 LTS machine.      
21th March 2020, a Covid-19 day, Zurigo, Switzerland.
