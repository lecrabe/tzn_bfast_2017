####################################################################################
####### Object:  Analyse BFAST      
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org                               
####### Update:  2017/10/22                                    
###################################################################################

####### Materiel adapte de https://github.com/rosca002/FAO_Bfast_workshop/tree/master/tutorial

###################################################################################
#### Parametres d'environnement
###################################################################################

#### Repertoire racine
rootdir <- "~/tzn_bfast_2017/"

dir.create(rootdir)

#### Repertoire des scripts
scriptdir <- paste0(rootdir,"Rscripts/")

#### Repertoire des donnees d'entree
data_dir <- paste0(rootdir,"data/")
dir.create(data_dir)

###################################################################################
####### GEE SCRIPT FROM 2017-11-20 TO OBTAIN TIME SERIES :   
####### https://code.earthengine.google.com/9f896ff6b3cbb2ff20862f0b96125d64

###################################################################################
####### VISIT HERE TO GET AUTHORIZATION KEY
####### https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=354790962074-7rrlnuanmamgg1i4feed12dpuq871bvd.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=2017-11-16+19%3A18%3A23.215943903+%2B0000+UTC2596996162

###################################################################################
####### LOAD AUTHORIZATION KEY FOR "DRIVE" AND DOWNLOAD RESULTS
setwd(data_dir)
base <- '_tzn_20171119'

system(sprintf("echo %s | drive init",
               "4/ArVSuBIEOH79H8rPsJDggWAOd3Qd4JbgJb2tLDnsD5w"))


system(sprintf("drive list -matches %s > %s",
               paste0('All_NDMI',base),
               "list_ndmi_tif.txt"))

system(sprintf("drive list -matches %s > %s",
               paste0('All_NDVI',base),
               "list_ndvi_tif.txt"))


data_input <- c(basename(unlist(read.table("list_ndmi_tif.txt"))),
                basename(unlist(read.table("list_ndvi_tif.txt"))),
                paste0(c('tableID_NDMI','tableID_NDVI'),base,'.csv')
)

data_input

for(data in data_input){
  system(sprintf("drive pull %s",
                 data))
}

###################################################################################
#### Results directory
results_directory <- paste0(rootdir,"results/")
dir.create(results_directory)

###################################################################################
#### NDMI stack
NDMIstack <- paste0(data_dir,'All_NDMI',base,'.tif') 
NDMIsceneID <- paste0(data_dir,'tableID_NDMI',base,'.csv')

###################################################################################
#### NDVI stack
NDVIstack <- paste0(data_dir,'All_NDVI',base,'.tif')
NDVIsceneID <- paste0(data_dir,'tableID_NDVI',base,'.csv')

###################################################################################
#### Start date historical
historical_year_beg <- 2010

###################################################################################
#### Start date monitoring
monitoring_year_beg <- 2015

###################################################################################
#### End date monitoring
monitoring_year_end <- 2017

###################################################################################
#### Process
###################################################################################

#### Standardize ENTRY DATA
source(paste0(scriptdir,"input_data.R"),echo = T)

#### RUN
source(paste0(scriptdir,"runBfast.R"),echo = T)


