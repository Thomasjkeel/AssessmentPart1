# Load in libraries
library(tidyverse)
library(maptools)
library(RColorBrewer)
library(classInt)
library(OpenStreetMap)
library(rJava)
library(tmap)
library(mallet)
library(rgdal)
library(rgeos)
library(sp)
library(sf)
library(raster)
library(tmaptools)
library(methods)
library(rprojroot)
library(magrittr)
library(leaflet)
library(classInt)
library(modEvA) 
library(shinyjs)

setwd('..')
getwd()
# read in data (data from http://www.nomisweb.co.uk/census/2011/dc5102ew)
df <- read_csv("no_qual_over16.csv")
# make new column of percentage of total
df$perc_no_qual <- (df$no_qual / df$total)*100

# SEshp <- read_shape("southeastmsoa.shp", as.sf = TRUE)
SEshp <- read_shape("SEcty.shp", as.sf = TRUE)
# SEshp <- set_projection(SEMap, projection = 27700)

# merge shapefile to data (from https://borders.ukdataservice.ac.uk//easy_download_data.html?data=England_msoa_2011 and http://geoportal.statistics.gov.uk/datasets/8d3a9e6e7bd445e2bdcc26cdf007eac7_4?geometry=-44.385%2C49.997%2C39.243%2C58.896)
SEMap <- merge(SEshp, df, by.x='msoa11cd', by.y='code')
class(SEMap)
projection(SEMap)

# map percnoqual
SEMap4326 <- SEMap %>% st_transform(crs = 4326) %>% as("Spatial")
projection(SEMap4326)

# error in the data remove values (a few msoa included in these (LIMITATION))
toremove <- c("Dorset", "Hertfordshire",
              "Northamptonshire", "Gloucestershire",
              "Outer London", "Warwickshire")
# remove values in shapefile
SEMap4326 <- SEMap4326[!(SEMap4326$CTY17NM %in% toremove),]

# No compass in view mode
tmap_mode("view")
tmap_options(limits = c(facets.view = 13))
tm_shape(SEMap4326) +
  tm_polygons("perc_no_qual",
              style="pretty",
              n=5,
              palette="Blues",
              midpoint=NA,
              title="Population (%)",
              popup.vars = c("msoa11nm","perc_no_qual"),
              id='msoa11cd') +
  tm_scale_bar() + 
  tm_layout(panel.show = TRUE,
            legend.outside = T) + 
  tm_facets(by = "CTY17NM", nrow = 2)

