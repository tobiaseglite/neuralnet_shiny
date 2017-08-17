library(shiny)
#https://stackoverflow.com/questions/36108705/drag-and-drop-data-into-shiny-app

library(shiny)

ui <- shinyUI(
  fluidPage(
    tags$head(tags$link(rel="stylesheet", href="css/styles.css", type="text/css"),
      tags$script(src="getdata.js")),
    h3(id="data-title", "Drop Datasets"),
    div(class="col-xs-12", id="drop-area", ondragover="dragOver(event)", 
      ondrop="dropData(event)"),
    imageOutput('images'),  # doesn't do anything now

    ## debug
    div(class="col-xs-12",
      tags$hr(style="border:1px solid grey;width:150%"),
      tags$button(id="showData", "Show", class="btn btn-info", 
        onclick="printData('dat.csv')")),
    div(id="data-output")  # print the data
  )
)