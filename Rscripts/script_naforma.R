####################################################################################################
####################################################################################################
## Extract Tanzania NAFORMA points
## Contact remi.dannunzio@fao.org 
## 2017/11/15
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
workdir  <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/tanzania/"
setwd(workdir)

## READ NAFORMA RESULTS
df  <- read.csv("naforma/collect_csv_data_naforma1_2016-07-13T15-38-50/plot.csv")
aoi <- readOGR("gis_data/camps/camps_25k_buffer.shp")
lu  <- read.csv("naforma/land_use.csv")
vg  <- read.csv("naforma/vegetation_type.csv")
tree<- read.csv("naforma/collect_csv_data_naforma1_2016-07-13T15-38-50/tree.csv")
wd  <- read.table("naforma/wood_densities.txt",sep="\t",fileEncoding = "UTF-16LE",header = T)

names(lu) <- c("lu_code","lu_label")
names(vg) <- c("vg_code","vg_label")
names(df)
table(df$location_srs)

## SPATIALIZE POINTS
df <- df[df$location_srs == "EPSG:21036",]
spdf <- SpatialPointsDataFrame(
  coords = df[,c("location_x","location_y")],
  data = df,
  proj4string = CRS("+init=epsg:21036")
)

sp <- spTransform(spdf,CRS("+init=epsg:4326"))
proj4string(sp) <- proj4string(aoi) 

## INTERSECT WITH AOI
plot(aoi)
plot(sp,add=T)
pts <- sp[aoi,]

dbf <- pts@data
table(dbf$land_use)
names(dbf)

## MERGE ALL NAFORMA VEGETATION CODES
dbf <- merge(dbf,lu,by.x="land_use",by.y="lu_code")
dbf <- merge(dbf,vg,by.x="vegetation_type",by.y="vg_code")
head(dbf)

pts@data <- dbf
writeOGR(pts,"gis_data/naforma.kml","naforma","KML")

## COMPUTE AVERAGE BIOMASS FOR THE CLUSTERS
summary(dbf)
plot(aoi)
plot(pts,add=T)
head(pts)
unique(pts@data$cluster_id)
nrow(pts)
table(pts$vg_label)
table(pts$no)
names(tree)

pts$unique_plot <- paste0(pts$cluster_id,"_",pts$no)
pts1 <- pts[grep("Woodland",pts$vg_label),]

table(pts1$vg_label)

## SELECT ONLY TREES FROM THE CLUSTER ID
tree$unique_plot <- paste0(tree$cluster_id,"_",tree$plot_no)
trees            <- tree[tree$unique_plot %in% unique(pts1@data$unique_plot),]
list_species     <- levels(as.factor(trees$species_scientific_name))

## MAKE LIST OF OCCURING GENUS
names(wd)
list <- list()

for(x in levels(as.factor(wd$Genus))){
  if(length(list_species[grep(x,list_species,ignore.case = T)])>0){
    list <- append(list,x)
  }
}

## CHECK DISTRIBUTION AND COMPUTE MEDIAN VALUE
hist(wd[wd$Genus %in% list,]$Density_g_cm3,
     xlab="Tree density in g/cm3",
     main="Density distribution for Genus occuring in the AOI")

med_wd <- median(wd[wd$Genus %in% list,]$Density_g_cm3)

####################################################################################
### Apply the CHAVE equation for the trees "AGB = 0.0673*(dbh^2*h*wd)^0.976"
names(trees)
trees <- trees[!is.na(trees$total_height) & trees$total_height_unit_name == "m",]
head(trees)


trees$agb <- 0.0673*(trees$dbh*trees$dbh*trees$total_height*med_wd)^0.976

plot(trees$dbh,trees$total_height,xlab="DBH in cm",ylab="Height in m")

trees$radius <- 15
trees[trees$dbh < 20, ]$radius <- 10
trees[trees$dbh < 10, ]$radius <- 5
trees[trees$dbh < 5, ]$radius  <- 2

trees$agb_ha <- trees$agb * 10000 / (trees$radius*trees$radius*pi)
table(trees$radius)
summary(trees[trees$radius == 15,]$dbh)
####################################################################################
### Compute sum of biomass per cluster
df_agb    <- tapply(trees$agb_ha,  trees[,c("cluster_id","plot_no")],FUN = sum)
df_agb_sd <- tapply(trees$agb_ha,  trees[,c("cluster_id")],FUN = sd)
df_nb_obs <- tapply(trees$species_code,  trees[,c("cluster_id")],FUN = length)

trees[trees$dbh > 40,]

mean(df_agb,na.rm=T)
min(df_agb,na.rm=T)
trees[trees$cluster_id == "39_54" & trees$plot_no == 9 ,]
