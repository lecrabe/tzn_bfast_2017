####################################################################################
####### Object:  Analyse BFAST      
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org                               
####### Update:  2017/10/22                                    
####################################################################################

####################################################################################
####### DONNEES D'ENTREE
####################################################################################


## load libraries
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

## name of raster stack with 0 as no data
NDMIstack_outputfile <- paste0(strsplit(NDMIstack,'.tif'),'0NA.tif')
NDVIstack_outputfile <- paste0(strsplit(NDVIstack,'.tif'),'0NA.tif')

system(sprintf("gdal_translate -co COMPRESS=LZW -a_nodata 0  %s %s",
               NDMIstack,
               NDMIstack_outputfile
))
system(sprintf("gdal_translate -co COMPRESS=LZW -a_nodata 0 %s %s",
               NDVIstack,
               NDVIstack_outputfile
))


## read images as raster stack
NDMIstack <- stack(NDMIstack) 
NDVIstack <- stack(NDVIstack)

## read scene IDs
NDMIsceneID <- read.csv(NDMIsceneID)
NDVIsceneID <- read.csv(NDVIsceneID)

## assign the scene id as the name for each band in the stack
names(NDMIstack) <- NDMIsceneID$scene_id

## head(NDMIsceneID$scene_id)
## remove duplicates
scenes <- NDMIsceneID$scene_id
s <- as.data.frame(scenes)
s$scenes2 <- substr(scenes, 10, 16)
nodup <- s[!duplicated(s$scenes2),]
ndmiStack<-subset(NDMIstack,nodup$scenes)

## extract date of images
year <- substr(nodup$scenes2, 1,4)
julianday <- substr(nodup$scenes2, 5,8)
nodup$date <- as.Date(as.numeric(julianday),  origin = paste0(year,"-01-01"))

## set date as Z in the raster stack
ndmiStack <- setZ(ndmiStack,nodup$date)

## remove duplicates
names(NDVIstack) <- NDVIsceneID$scene_id
scenes <- NDVIsceneID$scene_id
s <- as.data.frame(scenes)
s$scenes2 <- substr(scenes, 10, 16)
nodup <- s[!duplicated(s$scenes2),]
ndviStack<-subset(NDVIstack,nodup$scenes)

## extract date of images
year <- substr(s$scenes2, 1,4)
julianday <- substr(s$scenes2, 5,8)
s$date <- as.Date(as.numeric(julianday),  origin = paste0(year,"-01-01"))

## set date as Z in the raster stack
ndviStack <- setZ(ndviStack,s$date)

