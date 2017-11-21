library(gfcanalysis)
download_gfc_2016 <- function (tiles, output_folder, images = c("treecover2000", "loss", 
                                           "gain", "lossyear", "datamask")) 
{ 
  base <- "https://storage.googleapis.com/earthenginepartners-hansen/GFC-2016-v1.4/"
  
  stopifnot(all(images %in% c("treecover2000", "loss", "gain", 
                              "lossyear", "datamask", "first", "last")))
  if (!file_test("-d", output_folder)) {
    stop("output_folder does not exist")
  }
  message(paste(length(tiles), "tiles to download/check."))
  successes <- 0
  failures <- 0
  skips <- 0
  for (n in 1:length(tiles)) {
    gfc_tile <- tiles[n, ]
    min_x <- bbox(gfc_tile)[1, 1]
    max_y <- bbox(gfc_tile)[2, 2]
    if (min_x < 0) {
      min_x <- paste0(sprintf("%03i", abs(min_x)), "W")
    }
    else {
      min_x <- paste0(sprintf("%03i", min_x), "E")
    }
    if (max_y < 0) {
      max_y <- paste0(sprintf("%02i", abs(max_y)), "S")
    }
    else {
      max_y <- paste0(sprintf("%02i", max_y), "N")
    }
    file_root   <- "Hansen_GFC-2016-v1.4_"
    file_suffix <- paste0("_", max_y, "_", min_x, ".tif")
    filenames   <- paste0(file_root, images, file_suffix)
    tile_urls   <- paste0(paste0(base, filenames))
    local_paths <- file.path(output_folder, filenames)
    for (i in 1:length(filenames)) {
      tile_url <- tile_urls[i]
      local_path <- local_paths[i]
      if (file.exists(local_path)) {
        print(paste0("skipping ",local_path))
        skips <- skips + 1
        next
      }
      # system(sprintf("wget %s -O %s",
      #                tile_url,
      #                local_path))
      download.file(tile_url,local_path,method="auto")
      if (file.exists(local_path)) {
        successes <- successes + 1
      }
      else {
        failures <- failures + 1
      }
    }
  }
  message(paste(successes, "file(s) succeeded,", skips, "file(s) skipped,", 
                failures, "file(s) failed."))
}
