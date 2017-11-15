####################################################################################
####### Object:  Analyse BFAST      
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org                               
####### Update:  2017/10/22                                    
###################################################################################

###################################################################################
#### Parametres pour ce processus
###################################################################################

example_title <- 1
example_directory <- file.path(results_directory,paste0("example_",example_title))
dir.create(example_directory)

log_filename <- file.path(results_directory, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_example_", example_title, ".log"))
start_time   <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")
result       <- file.path(example_directory, paste0("example_", example_title, ".tif"))

###################################################################################
#### Execution de BFAST spatial
###################################################################################
time <- system.time(bfmSpatial(ndmiStack, 
                               start = c(monitoring_year_beg, 1),
                               formula = response ~ harmon,
                               order = 1, 
                               history = "all",
                               filename = result,
                               mc.cores = detectCores()))

###################################################################################
#### Enregistrement des temps de calculs
###################################################################################
write(paste0("Process demarre @ ", start_time,
             " et finalise @ ",format(Sys.time(),"%Y/%m/%d %H:%M:%S"),
             ". Temps de calcul: ", time[[3]]/60," minutes"), log_filename, append=TRUE)

###################################################################################
#### Post-processing
###################################################################################

#### Lire le raster de sortie de BFAST 
bfm_ndmi <- brick(result)

#### Detection de changement dans la premiere bande
change <- raster(bfm_ndmi,1)
plot(change, col=rainbow(8),breaks=c(monitoring_year_beg:monitoring_year_end))

#### Magnitude de changement dans la deuxieme bande
magnitude <- raster(bfm_ndmi,2)
magn_bkp  <- magnitude
magn_bkp[is.na(change)] <- NA
plot(magn_bkp,breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))
plot(magnitude, breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))

#### Erreurs dans la troisieme bande
error <- raster(bfm_ndmi,3)
plot(error)

#### Detection de la deforestation
def_ndmi <- magn_bkp
def_ndmi[def_ndmi>0] <- NA
plot(def_ndmi)
plot(def_ndmi,col="black",main="NDMI_deforestation")

#### Export des resultats des pertes detectees
writeRaster(def_ndmi,
            filename = file.path(example_directory,paste0("example_",example_title,"_deforestation_magnitude.tif")),
            overwrite=TRUE)

#### Detection des annees de changement
def_years <- change
def_years[is.na(def_ndmi)] <- NA

#### Affichage graphique
years <- c(monitoring_year_beg:monitoring_year_end)
plot(def_years, 
     col=rainbow(length(years)),
     breaks=years, 
     main=paste0("Detection de deforestation apres ",monitoring_year_beg)
)

#### Export des resultats des annees de pertes
writeRaster(def_years,
            filename = file.path(example_directory,paste0("example_",example_title,"_deforestation_dates.tif")),
            overwrite=TRUE)

