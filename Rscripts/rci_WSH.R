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
packages(foreign)


setwd("/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/cote_ivoire/trainings_cote_ivoire/training_alertes_oct2017/data/")

df <- read.dbf("bckUP_SWH_RCI.dbf")
df$Image <- as.character(df$Image)
table(df$Image)
df$date <- data.frame(t(data.frame(strsplit(df$Image,"-"))))[,3]

df$annee <- substr(df$date,4,7)
head(df)
write.dbf(df,"SWH_RCI.dbf")
table(df$ResSpatial,df$annee)
shp <- readOGR("SWH_RCI.shp","SWH_RCI")
rci <- readOGR("coteivoire_gaul_adm1_geo.shp","coteivoire_gaul_adm1_geo")

dev.off()
par(mfrow = c(7,4))
par(mar=c(0,0,0,0))

for(annee in 1986:2012){
  couverture <- shp[shp@data$annee == annee,]
  plot(rci)
  plot(couverture,add=T)
}

df <- read.dbf("bckUP_P2015_RCI_F.dbf")
df$Image <- as.character(df$Image)
table(df$Image)
df$date <- data.frame(t(data.frame(strsplit(df$Image,"_"))))[,4]

df$annee <- substr(df$date,1,4)
head(df)
write.dbf(df,"P2015_RCI_F.dbf")
table(df$ResSpatial,df$annee)
shp <- readOGR("P2015_RCI_F.shp","P2015_RCI_F")
rci <- readOGR("coteivoire_gaul_adm1_geo.shp","coteivoire_gaul_adm1_geo")

dev.off()
par(mfrow = c(1,4))
par(mar=c(0,0,0,0))

for(annee in 2013:2016){
  couverture <- shp[shp@data$annee == annee,]
  plot(rci)
  plot(couverture,add=T)
}
