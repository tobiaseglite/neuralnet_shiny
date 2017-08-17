library(shiny)

source('classify_image_mxnet.R')

shinyServer(function(input, output) {
	
	values <- reactiveValues(classification_res = NULL,
		normed_image = NULL,
		google_image1 = NULL,
		google_image2 = NULL,
		google_image3 = NULL,
		google_image4 = NULL,
		google_image5 = NULL,
		map_image = NULL)
	
	output$normed_image <- renderUI({
		if(is.null(input$files)){
			return(NULL)
		}

		tagList(imageOutput("normed_image"))
	})
	
	
	observeEvent(input$files, {
		local({
		
			if(is.null(input$files)){
				return(NULL)
			}
	
			outfile <- paste0("tmp/",paste(sample(c(letters,1:9), 10, TRUE),collapse = ""))
			dir.create(outfile, recursive = T)
			
			values$classification_res <- run_classification(input$files$datapath[1], tmp_path = outfile)	
			
			#values$normed_image <- values$classification_res$normed_image
			values$google_image1 <- values$classification_res$google_image1
			values$google_image2 <- values$classification_res$google_image2
			values$google_image3 <- values$classification_res$google_image3
			values$google_image4 <- values$classification_res$google_image4
			values$google_image5 <- values$classification_res$google_image5
			values$map_image <- values$classification_res$map_image
	
			output$normed_image <- renderImage({
			
				list(src = "normed_image.png",
					contentType = 'image/png',
					width = 640,
					alt = "Image failed to render")
				
			}, deleteFile = FALSE)
		})
	})
		
	

	
	# files <- reactive({
		# files <- input$files
		# files$datapath <- gsub("\\\\", "/", files$datapath)
	# })
	
	# observe({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# outfile <- paste0("tmp/",paste(sample(c(letters,1:9), 10, TRUE),collapse = ""))
		# dir.create(outfile, recursive = T)
		
		# run_classification(files()$datapath[1], tmp_path = outfile)	
	# })
	
	# output$normed_image <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("normed_image"))
	# })
	
	# output$google_image1 <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("google_image1"))
	# })
	
	# output$google_image2 <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("google_image2"))
	# })
	
	# output$google_image3 <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("google_image3"))
	# })
	
	# output$google_image4 <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("google_image4"))
	# })
	
	# output$google_image5 <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("google_image5"))
	# })
	
	# output$map_image <- renderUI({
		# if(is.null(input$files)){
			# return(NULL)
		# }

		# tagList(imageOutput("map_image"))
	# })
		
		
	# # # # observe({
		# # # # if(is.null(input$files)){
			# # # # return(NULL)
		# # # # }
		# # # # # for (i in 1:nrow(files())){
			# # # # local({
				# # # # # my_i <- i

				# # # # outfile <- paste(sample(c(letters,1:9), 10, TRUE),collapse = "")
				# # # # dir.create(outfile)
				# # # # classification_res <- run_classification(files()$datapath[1], tmp_path = outfile)
				
				# # # # output$normed_image <- renderImage({
					
					# # # # list(src = classification_res$normed_image,
						# # # # contentType = 'image/png',
						# # # # width = 640,
						# # # # alt = "Image failed to render")
					
				# # # # }, deleteFile = FALSE)
			# # # # })
			
			# # # # # local({
				# # # # # output$google_image1 <- renderImage({
					
					# # # # # list(src = classification_res$google_images[1],
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
			
			# # # # # local({
				# # # # # output$google_image2 <- renderImage({
					
					# # # # # list(src = classification_res$google_images[2],
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
			
			# # # # # local({
				# # # # # output$google_image3 <- renderImage({
					
					# # # # # list(src = classification_res$google_images[3],
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
				
			# # # # # local({
				# # # # # output$google_image4 <- renderImage({
					
					# # # # # list(src = classification_res$google_images[4],
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
			
			# # # # # local({
				# # # # # output$google_image5 <- renderImage({
					
					# # # # # list(src = classification_res$google_images[5],
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
			
			# # # # # local({
				# # # # # output$map_image <- renderImage({
					
					# # # # # list(src = classification_res$map_image,
					# # # # # contentType = 'image/png',
					# # # # # width = 640,
					# # # # # alt = "Image failed to render")
					
				# # # # # }, deleteFile = FALSE)
			# # # # # })
		# # # # #}
	# # # # })
})