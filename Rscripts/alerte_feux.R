####################################################################################
####### Object:  Gestion des alertes feux provenant de Global Forest Watch      
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/10/23                                    
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
packages(ggplot2)
packages(foreign)

setwd("/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/cote_ivoire/trainings_cote_ivoire/training_alertes_oct2017/data/")

################# Limites administratives
rci <- readOGR("coteivoire_gaul_adm1_geo.shp","coteivoire_gaul_adm1_geo")

################# Masque foret-non foret
fnf <- raster("bnetd_2015.tif")
proj_utm <- proj4string(fnf)

################# Lire alertes GFW
df <- read.csv("alerte_fire_20171023.csv")

################# Transformer en fichier vecteur
pt_df_geo <- SpatialPointsDataFrame(
  coords = df[,c("longitude","latitude")],
  data   = df,
  proj4string=CRS("+init=epsg:4326")
)

################# Reprojeter les points en UTM
pts <- spTransform(pt_df_geo,proj_utm)

################# Intersecter avec le masque FNF
pts$FNF <- extract(fnf,pts@coords)

################# Intersecter avec les regions de la Cote d'Ivoire
rci <- spTransform(rci,proj_utm) 
pts$region <- over(pts,rci)$ADM1_NAME

################# Afficher les alertes en fonction du masque et de la region
table(pts$region,pts$FNF)

################# Afficher le graphe des points alerte
plot(rci)
plot(pts[pts$FNF ==1,],add=T)
