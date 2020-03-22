# Like bedtools closest but calculate distance for all elements
# Wyler Michele
# March 21th 2020, Zurigo, Switzerland

args <- commandArgs(TRUE)
FILE1 <- args[1]
FILE2 <- args[2]
# suppress warnings
options(warn=-1)

# check if file is present
if(length(args) == 0){
  stop(print('Usage: BEDdistance.R file.bed file.bed'), call. = F)
} else if(length(args) == 1){
  FILE2 <- FILE1
  #print(paste0("Single File input: ", FILE1))
} 


# load libraries ----------------------------------------------------
suppressMessages(suppressWarnings(require(data.table)))

### define functions ------------------------------------------------
# subfunction used with aplly inside f.Merger
f.tableMaker <- function(TAB) {
  soggetto <- as.character(as.vector(TAB))

  # remove same entry from File2
  remaining <- BEDfile2[!(BEDfile2$chrom.y == soggetto[1] &
                            BEDfile2$Start.y == soggetto[2]&
                            BEDfile2$End.y == soggetto[3]),]
  # and remove entries on a different chromosome
  remaining <- remaining[remaining$chrom.y == soggetto[1],]
  
  # test that at least one pair is available
  if (nrow(remaining) > 0){
    # merge all possible combination
    QUERY <- as.data.table(t(soggetto))
    colnames(QUERY)[1:3] <- c('chrom.x', 'Start.x', 'End.x')                       
    coppie <- cbind(QUERY, remaining)
    # populate list
    name <- paste(soggetto[1], as.numeric(soggetto[2]), as.numeric(soggetto[3]), sep = '_')
    ListPairs[[name]] <- coppie
    }
  
}


# take one element from file 1 and merge with possible candidates from file 2
# each element is an element of a list
f.Merger <- function(X,Y) {
  # make sure both are data.table format
  BEDfile1 <- as.data.table(X)
  BEDfile2 <- as.data.table(Y)
  
  ### create list
  ListPairs <- apply(BEDfile1, 1 , f.tableMaker)
  
  return(ListPairs)
}


# distance calculator
f.dist <- function(X){
  # make data table
  coppie <- as.data.table(X)
  # make numeric
  coppie$Start.y <- as.numeric(coppie$Start.y)
  coppie$Start.x <- as.numeric(coppie$Start.x)
  coppie$End.y <- as.numeric(coppie$End.y)
  coppie$End.x <- as.numeric(coppie$End.x)
  
  # calcola distance
  coppie$d1 <- coppie$Start.y - coppie$Start.x
  coppie$d2 <- coppie$End.y - coppie$Start.x
  coppie$d3 <- coppie$Start.y - coppie$End.x
  coppie$d4 <- coppie$End.y - coppie$End.x
  
  # calculate min distance 
  minore <- apply(coppie[, c('d1','d2','d3','d4')], 1, min)
  risultato <- ifelse(minore <= 0, 0, minore)
  
  # prepare output 
  finale <- coppie
  # finale <- as.data.table(coppie)
  finale$distance <- risultato
  finale <- finale[finale$distance > 0,]
  finale$d1 <- NULL
  finale$d2 <- NULL
  finale$d3 <- NULL
  finale$d4 <- NULL
  return(finale)
  # if(nrow(finale) ==0){
  #   rm(finale)} else { print(finale)}
}

## RUN ------------------------------------------------


# create empty list for output
ListPairs <- list()

# read in arguments from command line
BEDfile1 <- fread(FILE1)
BEDfile2 <- fread(FILE2)


# add colnames
colnames(BEDfile1)[1:3] <- c('chrom.x', 'Start.x', 'End.x')
colnames(BEDfile2)[1:3] <- c('chrom.y', 'Start.y', 'End.y')

# merge input BED files to list with possible combinations
BEDlist <- f.Merger(BEDfile1, BEDfile2)


# calculate basepair distance over the chromosome
l <- parallel::mclapply(BEDlist, f.dist, mc.cores = 1)


# merge list to dataframe
STDOUT <- do.call(rbind.data.frame, l)
# write out to stdout
fwrite(STDOUT, '', sep = '\t')
