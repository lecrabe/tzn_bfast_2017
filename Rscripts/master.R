####################################################################################
####### Object:  Analyse BFAST      
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org                               
####### Update:  2017/10/22                                    
###################################################################################

####### Materiel adapte de thttps://github.com/rosca002/FAO_Bfast_workshop/tree/master/tutorial

###################################################################################
#### Parametres d'environnement
###################################################################################

#### Repertoire racine
#rootdir <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/cote_ivoire/trainings_cote_ivoire/training_alertes_oct2017/"
rootdir <- "~/rci_ws_20171022/"
dir.create(rootdir)

#### Repertoire des scripts
scriptdir <- paste0(rootdir,"Rscripts/")

#### Repertoire des donnees d'entree
data_dir <- paste0(rootdir,"data/")
dir.create(data_dir)

####################################################################################################################
####### Les donnees d'entree proviennent de GEE et sont composees de tous les indices NDVI et NDMI sur la periode
####################################################################################################################

####### EXECUTER LE SCRIPT GEE -> EXERCICE 2017-10-26 : https://code.earthengine.google.com/049a1836ce7b4a7bc93aff7148aa2ead

####### TELECHARGER DEPUIS GoogleDRIVE vers SEPAL
####### Exemple de cle autorisation : 4/QHH2DucZ-MI-GY0HnG6JyEfjMpfVvJsu6_TmHqbxBgQ
setwd(data_dir)
system(sprintf("echo %s | drive init",
               "VOTRE_CLE_AUTORISATION"))


system(sprintf("drive list"))

base <- '_rci_20171025'
data_input <- c(paste0(c('All_NDMI','All_NDVI'),base,'.tif'),
                paste0(c('tableID_NDMI','tableID_NDVI'),base,'.csv')
                )

for(data in data_input){
  system(sprintf("drive pull %s",
                 data))
}

#### SOLUTION VIA DROPBOX
# system(sprintf("echo 4/SGn-wOSw1u0Pt2kW3Sctd_4nyrYX0ZMsn2YcJWvYejc | gdrive download 0B48Ol_Tb6ewSX1RVcEZCRm9lWGM --force"))
# system("wget https://www.dropbox.com/s/hj3i0bn644vi1hl/data_rci_test_bfast.zip?dl=0")
# system("unzip data_rci_test_bfast.zip?dl=0")

#### Repertoire des resultats
results_directory <- paste0(rootdir,"results/")
dir.create(results_directory)

#### Stack des donnees NDMI  
NDMIstack <- paste0(data_dir,'All_NDMI',base,'.tif') # tile3
#### Liste des identifiant correspondant 
NDMIsceneID <- paste0(data_dir,'tableID_NDMI',base,'.csv')

#### Stack des donnees NDVI 
NDVIstack <- paste0(data_dir,'All_NDVI',base,'.tif')
#### Liste des identifiant correspondant 
NDVIsceneID <- paste0(data_dir,'tableID_NDVI',base,'.csv')

#### Annee de demarrage de la periode historique
historical_year_beg <- 2007

#### Annee de demarrage de la periode de monitoring
monitoring_year_beg <- 2013

#### Annee de fin de la periode de monitoring
monitoring_year_end <- 2017

###################################################################################
#### Execution des scripts de process
###################################################################################

#### Standardisation des donnees d'entree
source(paste0(scriptdir,"input_data.R"),echo = T)

#### Execution BFAST avec les parametres "all"
source(paste0(scriptdir,"example_1.R"),echo = T)

#### Execution BFAST avec les parametres "ROC"
source(paste0(scriptdir,"example_2.R"),echo = T)

#### Execution BFAST avec les parametres "2007 --->"
source(paste0(scriptdir,"example_3.R"),echo = T)

#### Comparaison des donnees de reference
#### source("Rscripts/reference_data.R")

#### Classification des magnitudes de changement
source(paste0(scriptdir,"magnitude_threshold.R"),echo = T)
