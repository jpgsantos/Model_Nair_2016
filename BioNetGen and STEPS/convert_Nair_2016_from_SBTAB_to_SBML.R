#system("R CMD INSTALL libSBML_5.18.0.tar.gz") # install libSBML from http://sbml.org/Software/libSBML
#install.packages("pracma")
#install.packages("hdf5r")

PATH_LIB = "/Applications/anaconda2/lib/R/library" ### PATH TO libSBML and other packages
library("libSBML", lib.loc=PATH_LIB) 
library("pracma", lib.loc=PATH_LIB)  
library("hdf5r", lib.loc=PATH_LIB)   

d0 = getwd()
PATH_SBtabVFGEN = "/SBtabVFGEN-master" ### SET PATH TO SBTAB->SBML CONVERSION TOOL HERE (the folder should contain sbtab_to_vfgen.R and sbtab_from_tsv.R , See https://github.com/a-kramer/SBtabVFGEN ) 
d1 = paste(d0,PATH_SBtabVFGEN,sep = '')  ### 
setwd(d1)
source("sbtab_to_vfgen.R")

d2 = paste(d0,"/SBTAB_Nair_2016",sep = '')
setwd(d2)
tsv.files <- dir(pattern=".*[.]tsv");
SBtabDoc <- sbtab_from_tsv(tsv.files)
setwd(d0)
Model <- sbtab_to_vfgen(SBtabDoc)

