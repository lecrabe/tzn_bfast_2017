####################################################################################
####### Object:  Run the MAD algorithm on two timescans              
####### Author:  remi.dannunzio@fao.org                         
####### Update:  2017/10/06                                  
####################################################################################

####################################################################################
#### SETUP PARAMETERS
rootdir <- "/media/dannunzio/hdd_remi/cote_ivoire/CIV/"
setwd(rootdir)

####################################################################################
#### LOAD PACKAGES
library(raster)
library(rgeos)
library(rgdal)

library(foreign)
library(plyr)
library(ggplot2)

options(stringsAsFactors = F)

####################################################################################
#### ALIGN TWO PRODUCTS TO THE SAME EXTENT
r1_name <- "2015/016A/Timescan/Timescan.VVVH.vrt"
r2_name <- "2017/016A/Timescan/Timescan.VVVH.vrt"

r1 <- brick(r1_name)
r2 <- brick(r2_name)

ext <- extent(r1)
ext@xmin <- max(extent(r1)@xmin,extent(r2)@xmin)
ext@xmax <- min(extent(r1)@xmax,extent(r2)@xmax)
ext@ymin <- max(extent(r1)@ymin,extent(r2)@ymin)
ext@ymax <- min(extent(r1)@ymax,extent(r2)@ymax)

res(r1)
res(r2)

res <- min(res(r1),res(r2))

system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -co COMPRESS=LZW %s %s",
               ext@xmin,
               ext@ymin,
               ext@xmax,
               ext@ymax,
               res,
               res,
               r1_name,
               paste0(rootdir,"tmp_r1.tif")))

system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -co COMPRESS=LZW %s %s",
               ext@xmin,
               ext@ymin,
               ext@xmax,
               ext@ymax,
               res,
               res,
               r2_name,
               paste0(rootdir,"tmp_r2.tif")))

####################################################################################
#### FORCE ORIGIN TO BE THE SAME
r1 <- brick(paste0(rootdir,"tmp_r1.tif"))
r2 <- brick(paste0(rootdir,"tmp_r2.tif"))

origin(r2) <- origin(r1)

writeRaster(r2,paste0(rootdir,"tmp_r2_origined.tif"),overwrite=T)

####################################################################################
#### RUN THE MAD ALGORITHM
system(sprintf("otbcli_MultivariateAlterationDetector -in1 %s -in2 %s -out %s",
               paste0(rootdir,"tmp_r1.tif"),
               paste0(rootdir,"tmp_r2_origined.tif"),
               paste0(rootdir,"tmp_imad.tif")))

####################################################################################
#### COMPRESS
system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
               paste0(rootdir,"tmp_imad.tif"),
               paste0(rootdir,"imad_timescan.tif")
               ))
