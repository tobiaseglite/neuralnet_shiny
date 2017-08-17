library(shiny)

source('classify_image_mxnet.R')

shinyServer(function(input, output, session) {
	
	values <- reactiveValues(classification_res = NULL,
		input_use = NULL)
	
	observeEvent(input$submit,{
			values$input_use <- input$wwwAdress
	})
	
	observeEvent(input$files,{
			values$input_use <- input$files$datapath[1]
	})
		
	output$normed_image <- renderUI({
		if(is.null(input$files)){
			return(NULL)
		}

		tagList(imageOutput("normed_image"))
	})
	
	output$prob_table <- renderUI({
		if(is.null(input$files)){
			return(NULL)
		}

		tagList(tableOutput("normed_image"))
	})
	
	observeEvent(values$input_use,{
		local({

			width  <- session$clientData$output_myImage_width
			height <- session$clientData$output_myImage_height
			pixelratio <- session$clientData$pixelratio
			
			outfile <- paste0("tmp/",paste(sample(c(letters,1:9), 10, TRUE),collapse = ""))
			dir.create(outfile, recursive = T)	
			
			values$classification_res <- run_classification(values$input_use,
				tmp_path = outfile,
				224,
				117,
				"data_model_image_FullImageNet",
				"Inception",
				9)		
			
			# values$classification_res <- run_classification(values$input_use,
				# tmp_path = outfile,
				# 299,
				# 128,
				# "data_model_image_InceptionV3",
				# "Inception-7",
				# 1)
			
			output$normed_image <- renderImage({
				
				list(src = values$classification_res$normed_image,
					contentType = 'image/png',
					width = width*pixelratio,
					height = height*pixelratio,
					alt = "Image failed to render")
				
			}, deleteFile = FALSE)
			
			output$map_image <- renderImage({
			
				list(src = values$classification_res$map_image,
					contentType = 'image/png',
					width = width*pixelratio,
					height = height*pixelratio,
					alt = "Image failed to render")
				
			}, deleteFile = FALSE)

			output$prob_table <- renderTable({
				values$classification_res$image_probabilities
			},include.rownames=FALSE)
			
		})
	})
})