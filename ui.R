library(shiny)

shinyUI(fluidPage(
	
	titlePanel("Neural Network Image Classification"),
	sidebarLayout(
		sidebarPanel(
			fileInput(inputId = 'files', 
				label = 'Select an image from a file',
				multiple = FALSE,
				accept=c('image/png', 'image/jpeg')),
			textInput(inputId = 'wwwAdress',
				label = "Enter a www adress of an image",
				value = "", width = NULL, placeholder = "Web adress of picture"),
			actionButton("submit", "Start"),
			br(),
			br(),
			br(paste0("Choose an image from a local file or from a webpage to run the",
				" image classification. The classification uses 'mxnet' with two",
				" pretrained models from neural networks to predict the contents",
				" and the location where the picture was taken. Obviously the",
				" location is better (if not only) estimated for scenic images."))
		),
		mainPanel(
			imageOutput('normed_image'),
			tableOutput('prob_table'),
			imageOutput('map_image')
		)
	)
))