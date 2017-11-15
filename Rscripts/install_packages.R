####################################################################################
####### Object:  Analyse BFAST      
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/10/22                                    
####################################################################################

####################################################################################
####### INSTALLATION DES PAQUETS
####################################################################################

packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

packages(devtools)
install_github('loicdtx/bfastSpatial')

packages(raster)
packages(rgdal)
packages(bfastSpatial)
packages(stringr)
packages(parallel)
packages(devtools)
packages(ggplot2)