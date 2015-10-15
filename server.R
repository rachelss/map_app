library(shiny)
library(leaflet)
library(shinyapps)
library(magrittr)
library(rgdal)

#run: shinyapps::deployApp('marmot_map_app')
marmotdata <- read.csv("Location data for marmots observed in Great Basin 1999-2013 UPDATED.csv",header=TRUE)

pal <- colorFactor(palette = rainbow(length(unique(marmotdata$Obs.))), domain = marmotdata$Obs.)

# prepare UTM coordinates matrix
utmcoor<-SpatialPoints(cbind(marmotdata$Easting,marmotdata$Northing), proj4string=CRS("+proj=utm +zone=11"))
#zone= UTM zone
# converting
longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat"))
marmotdata<-cbind(marmotdata,longlatcoor)
center_long<-max(marmotdata$coords.x1)+((min(marmotdata$coords.x1)-max(marmotdata$coords.x1))/2)
center_lat<-max(marmotdata$coords.x2)+((min(marmotdata$coords.x2)-max(marmotdata$coords.x2))/2)

#   lng = c(-114,-115,-116) 
#   lat = c(39, 40, 41) 
#   nm<-c("happy","sad","notail")
#   pretendmarmotlocs<- data.frame(lng,lat,nm)       # df is a data frame

shinyServer <- function(input, output, session) {
  output$marmots <- renderLeaflet({
    
    maptype<-switch(input$Overlay,
                    "Topo" = "OpenTopoMap",
                    "EsriTopo" = "Esri.WorldTopoMap",
                    "Terrain" = "Acetate.terrain",
                    "Temperature" = "OpenWeatherMap.Temperature",
                    "Basic" = "OpenStreetMap")
    
    leaflet(data = marmotdata) %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      setView(lng = center_long, lat = center_lat, zoom =7) %>% 
      addProviderTiles(maptype)  %>% #Acetate.terrain or OpenTopoMap
      addCircleMarkers(~coords.x1, ~coords.x2,color = ~pal(Obs.),radius = 5,stroke = FALSE, fillOpacity = 1, popup = ~as.character(Range))  %>% 
      addLegend("bottomleft", pal = pal, values = ~Obs.,opacity = 1,title = "Who Found") %>%
      fitBounds(~min(coords.x1), ~min(coords.x2), ~max(coords.x1), ~max(coords.x2)) 
  })
}

    