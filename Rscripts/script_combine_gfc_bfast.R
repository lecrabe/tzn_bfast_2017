####################################################################################################
####################################################################################################
## Combine GFC data with BFAST loss
## Contact remi.dannunzio@fao.org 
## 2017/11/20
####################################################################################################
####################################################################################################
options(stringsAsFactors = FALSE)

### Load necessary packages
library(gfcanalysis)
library(rgeos)
library(ggplot2)
library(rgdal)
library(maptools)
library(dplyr)

## Set the working directory
rootdir  <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/tanzania/"
workdir  <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/tanzania/gis_data/"
setwd(workdir)

## Select the folder where GFC data archives are stored
gfc_folder <- paste0(workdir,"gfc_2016_tanzania/")
bfast_dir  <- paste0(rootdir,"bfast/")
aoi        <- readOGR("camps/camps_25k_buffer.shp","camps_25k_buffer")

list_camps <- aoi$Refugee_ca
list_gfc   <- list.files("gfc_2016_tanzania/full_aoi/",pattern=glob2rx("aoi*.tif"))

####################################################################################################
##### camp <- list_camps[1]

results <- data.frame(matrix(ncol=0,nrow=3))

for(camp in list_camps){
  
  ##### FOLDER FOR THE CAMP
  cmp_folder <- paste0(gfc_folder,camp,"/")
  
  ##### BFAST LOSS AND TC2015 FROM GFC
  bfast  <- paste0(bfast_dir,"bfast_",tolower(camp),"/example_2.tif")
  tc2015 <- paste0(cmp_folder,"treecover2015.tif")
  
  ##### ALIGN BFAST RESULTS TO GFC EXTENT
  mask   <- tc2015
  input  <- bfast
  ouput  <- paste0(cmp_folder,"bfast_",tolower(camp),".tif")
  
  proj   <- proj4string(raster(mask))
  extent <- extent(raster(mask))
  res    <- res(raster(mask))[1]
  
  # system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
  #                proj4string(raster(mask)),
  #                extent(raster(mask))@xmin,
  #                extent(raster(mask))@ymin,
  #                extent(raster(mask))@xmax,
  #                extent(raster(mask))@ymax,
  #                res(raster(mask))[1],
  #                res(raster(mask))[2],
  #                input,
  #                ouput
  # ))
  # 
  # ##### MAKE A BFAST LOSS MASK AND COMBINE WITH GFC > 30%
  # system(sprintf("gdal_calc.py -A %s --A_band=1 -B %s --B_band=2 -C %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
  #                paste0(cmp_folder,"bfast_",tolower(camp),".tif"),
  #                paste0(cmp_folder,"bfast_",tolower(camp),".tif"),
  #                tc2015,
  #                paste0(cmp_folder,"bfast_loss_mask",tolower(camp),".tif"),
  #                "(A>2015)*(A<2018)*(B<0)*(C>30)"
  # ))
  # 
  # #################### SIEVE RESULTS x6
  # system(sprintf("gdal_sieve.py -st %s -8 %s %s",
  #                6,
  #                paste0(cmp_folder,"bfast_loss_mask",tolower(camp),".tif"),
  #                paste0(cmp_folder,"tc_loss_2015_2017_",tolower(camp),".tif")
  # ))

  #################### Compute stats loss
  system(sprintf("oft-stat -i %s -o %s -um %s",
                 paste0(cmp_folder,"tc_loss_2015_2017_",tolower(camp),".tif"),
                 paste0(cmp_folder,"stats_tc_loss_2015_2017_",tolower(camp),".txt"),
                 paste0(cmp_folder,"tc_loss_2015_2017_",tolower(camp),".tif")
  ))
  loss <- read.table(paste0(cmp_folder,"stats_tc_loss_2015_2017_",tolower(camp),".txt"))[1,2]*30*30/10000

  #################### Compute stats tc 2015
  system(sprintf("oft-stat -i %s -o %s -um %s",
                 tc2015,
                 paste0(cmp_folder,"stats_tc2015_",tolower(camp),".txt"),
                 tc2015
  ))
  
  df <- read.table(paste0(cmp_folder,"stats_tc2015_",tolower(camp),".txt"))[,1:2]
  names(df) <- c("tc","count")
  tc_area <- sum(df[df$tc>30,"count"])*30*30/10000
  results <- cbind(results,c(camp,tc_area,loss))

}
out <- data.frame(t(results))
names(out) <- c("camp","area_tc_2015","area_loss_2015_2017")
write.csv(out,"loss_bfast.csv",row.names = F)
