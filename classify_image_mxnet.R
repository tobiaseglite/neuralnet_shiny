# http://dmlc.ml/rstats/2015/11/03/training-deep-net-with-R.html
# https://github.com/apache/incubator-mxnet/blob/master/R-package/vignettes/classifyRealImageWithPretrainedModel.Rmd
# https://www.students.ncl.ac.uk/keith.newman/r/maps-in-r

run_classification <- function(image_read,
	tmp_path,
	pixel_size,
	mean_img_value,
	path_name,
	model_name,
	model_iteration){

	require(mxnet)
	require(imager)
	require(grid)
	require(httr)
	require(maps)       # Provides functions that let us plot the maps
	require(mapdata)    # Contains the hi-resolution points that mark out the countries.
	require(viridis)
	require(gridExtra)
	require(gridBase)
	
	preproc.image <- function(im, mean.image) {
		# crop the image
		shape <- dim(im)
		short.edge <- min(shape[1:2])
		long.edge <- max(shape[1:2])
		which.short <- which.min(shape[1:2])
		
		im_tmp <- array(rep(1, (long.edge^2)*3), dim = c(long.edge, long.edge, 1, 3))
	  
	  	if(short.edge != long.edge){
		  
			edge_diff <- (long.edge - short.edge)/2
			
			if(dim(im)[4] == 3){
				if(which.short == 1){
					for(i in 1:3){
						im_tmp[edge_diff:(long.edge-edge_diff-1),,1,i] <- im[,,1,i]
					}
				}else{
					for(i in 1:3){
						im_tmp[,edge_diff:(long.edge-edge_diff-1),1,i] <- im[,,1,i]
					}
				}
			}else{
				if(which.short == 1){
					for(i in 1:3){
						im_tmp[edge_diff:(long.edge-edge_diff-1),,1,i] <- im[,,1,1]
					}
				}else{
					for(i in 1:3){
						im_tmp[,edge_diff:(long.edge-edge_diff-1),1,i] <- im[,,1,1]
					}
				}		  	
			}
		}else{
			im_tmp <- im
		}
		
		# resize to pixel_size x pixel_size, needed by input of the model.
		resized <- resize(im_tmp, pixel_size, pixel_size)
		# convert to array (x, y, channel)
		arr <- as.array(resized) * 255
		arr <- arr[,,,1:3, drop = F]
		dim(arr) <- c(pixel_size, pixel_size, 3)
		# subtract the mean
		normed <- arr - mean.img[,,1:3, drop = F]
		# Reshape to format needed by mxnet (width, height, channel, num)
		dim(normed) <- c(pixel_size, pixel_size, 3, 1)
		return(normed)
	}
	
	classify_image <- function(normed){
		
		#----------------------------------	Plot normalized image
		normed_plot <- normed[,,,1]
		normed_plot <- normed_plot + abs(min(normed_plot))
		normed_plot <- normed_plot/max(normed_plot)
		
		png(paste0(tmp_path,"/normed_image.png"))
		grid.raster(t(as.raster(normed_plot)))
		dev.off()
		
		#----------------------------------	Get probabilities
		prob <- predict(model_img, X = normed)
		
		dim(prob)
		prob_df <- data.frame(prob = round(prob,2), row = 1:nrow(prob))
		prob_df <- prob_df[prob_df$prob > 0.05,]
		prob_df <- prob_df[order(prob_df$prob,decreasing = T),]
		
		synsets <- readLines(paste0(path_name,"/synset.txt"))
		synsets <- sapply(synsets,function(x){
			tmp <- strsplit(x," ")[[1]][-1]
			return(paste(tmp,collapse = " "))
		}, USE.NAMES = F)
		prob_df$label <- synsets[prob_df$row]
		prob_df <- prob_df[,-2]
		return(prob_df)
	}
	
	classify_location <- function(normed){
		
		#----------------------------------	Get location probabilities
		normed_plot <- normed[,,,1]
		normed_plot <- normed_plot + abs(min(normed_plot))
		normed_plot <- normed_plot/max(normed_plot)
			
		prob <- predict(model_loc, X = normed)
		
		dim(prob)
		prob_df <- data.frame(prob = round(prob,2), row = 1:nrow(prob))
		prob_df <- prob_df[prob_df$prob > 0.01,]
		prob_df <- prob_df[order(prob_df$prob,decreasing = T),]
		
		synsets <- read.table("data_model_location/grids.txt",
			sep = "\t")
		
		synsets_use <- synsets[prob_df$row,]
		
		names(synsets_use) <- c("id","lat","lon")
		
		synsets_use$prob <- prob_df$prob
		
		
		#----------------------------------	Get location map
		png(paste0(tmp_path,"/map_image.png"))
		maps::map('worldHires', col = "lightgrey")
		
		ii <- cut(synsets_use$prob, breaks = seq(0, 1, len = 100), 
			include.lowest = TRUE)
		colors_use <- viridis(99)[ii]
	
		synsets_use$col <- colors_use
		
		if(nrow(synsets_use) > 0){
			points(rev(synsets_use$lon),
				rev(synsets_use$lat),
				col=rev(synsets_use$col),
				pch=18,
				cex = 2)
			
			points(synsets_use$lon[1],
				synsets_use$lat[1],
				col="red",
				pch=5,
				cex = 1.5)
			
			top_location <- maps::map.where(database = "world", synsets_use$lon[1], synsets_use$lat[1])	
		
		legend("bottom",
			legend = paste0(top_location," (",synsets_use$prob[1]*100,"% Prob.)"),
			pch = 5,
			col = "red",
			pt.cex = 1.5,
			bty = "n")
		}
		
		ii <- cut(seq(0,1,0.01), breaks = seq(0, 1, len = 100), 
			include.lowest = TRUE)
		colors_legend <- viridis(99)[ii]
			
		points(x = seq(-150,150,length.out = 101),
			y = rep(100,101),
			pch = 15,
			col = colors_legend,
			xpd = T)
		text(x = seq(-150,150,length.out = 5),
			y = 110,
			labels = paste0(seq(0,100,25),"%"),
			xpd = T)
		dev.off()
	}
	
	model_img <- mx.model.load(paste0(path_name,"/",model_name),
		iteration = model_iteration)
	mean.img <- array(c(rep(mean_img_value, pixel_size* pixel_size*3)),
		dim = c(pixel_size, pixel_size,3))
	
	model_loc <- mx.model.load("data_model_location/RN101-5k500", iteration = 12)
	
	im <- load.image(image_read)
	normed <- preproc.image(im, mean.img)
		
	prob_df <- classify_image(normed)
	prob_df[,"prob"] <- paste0(prob_df[,"prob"]*100,"%")
	
	classify_location(normed)
	
	# normed_image: paste0(tmp_path,"/normed_image.png")
	# Image probabilities: prob_df
	# Map image: map_image.png
	
	return(list(normed_image = paste0(tmp_path,"/normed_image.png"),
		image_probabilities = prob_df[,c("prob","label")],
		map_image = paste0(tmp_path,"/map_image.png")))
	
}
