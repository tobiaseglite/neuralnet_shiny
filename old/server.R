server <- function(input, output, session) {
	observeEvent(input$mydata, {
		len = length(input$mydata)
		output$images <- renderPlot({
			sapply(1:len, function(i) {
				input$mydata[[i]]
			})
		})
	})
}