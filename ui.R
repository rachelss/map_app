library(shiny)
library(leaflet)
library(shinyapps)

ui <- fluidPage(
  titlePanel("Marmots found in the Great Basin"),
  sidebarLayout(
    sidebarPanel(
      selectInput("Overlay", 
                  label = "Overlay",
                  choices = c("Terrain","Topo","EsriTopo","Current Temperature","Basic"))
      ),
    mainPanel(
      leafletOutput("marmots")
    )
  )
)

