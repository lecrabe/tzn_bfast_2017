####################################################################################
####### Object:  DEZIP les archives WSH       
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/10/27                                    
####################################################################################

####################################################################################
####### PAQUETS
####################################################################################
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

options(stringsAsFactors = FALSE)
packages(raster)
packages(rgdal)
packages(bfastSpatial)
packages(stringr)
packages(parallel)
packages(devtools)
packages(ggplot2)
packages(foreign)

####################################################################################
####### REPERTOIRE
####################################################################################
osfaco  <- "/home/dannunzio/rci_ws_20171022/OSFACO/"
destdir <- "/home/dannunzio/rci_ws_20171022/SPOT_annuel/"
tmpdir  <- "/home/dannunzio/rci_ws_20171022/tmp_SPOT/"

dir.create(destdir)
dir.create(tmpdir)
setwd(destdir)

####################################################################################
####### LISTING
####################################################################################
#annee <- 1986
for(annee in 1986:2012){
  
  annee_dir <- paste0(destdir,"SPOT_",annee,"/")
  dir.create(annee_dir)
  
  liste_dossier <- list.files(osfaco,pattern=paste0("XS_",annee))
  #liste_zip     <- list.files(paste0(osfaco,liste_dossier),pattern=".zip")
  # if(length(liste_dossier) != length(liste_zip)){
  #   print(annee)
  # }
  #archive <- liste_dossier[1]
  for(archive in liste_dossier){
    system(sprintf("unzip %s -d %s",
                   paste0(osfaco,archive,"/",archive,".zip"),
                   tmpdir
                   )
           )
    
    system(sprintf("gdal_merge.py -o %s -co COMPRESS=LZW %s",
                   paste0(annee_dir,archive,"_MS.tif"),
                   paste0(tmpdir,archive,"/*.tif")
                   ))
    
    system(sprintf("rm -r %s",
                   paste0(tmpdir,"*")))
  }
}

