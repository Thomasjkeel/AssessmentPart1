## CASA GIS Assignment 1
---
title: "assignment1_GIS"
author: "Thomas Keel"
date: "07/11/2018"
output:
  html_document: default
  pdf_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

### GIS Assignment 1

## 1. Introduction:



## Load required Libraries
```{r, warning=FALSE, message=FALSE}
library(tidyverse)
library(maptools)
library(RColorBrewer)
library(classInt)
library(tmap)
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
```

## Data Preparation:
# Read in data and shapefile (see Appendix A)
```{r, , warning=FALSE, message=FALSE}
# data downloaded at:  http://www.nomisweb.co.uk/census/2011/dc5102ew [accessed 6th Novemeber 2018]
df <- read_csv("data/no_qual_over16.csv")

#read shape for south East containing only msoa within counties 
SEshp <- read_shape("shapes/SouthEast.shp", as.sf = TRUE)
# change projection to WGS84 so that tmap "view" mode works
SEshp <- set_projection(SEshp, projection = 4326)

```

# check projection which should be WGS84
```{r}
print(projection(SEshp))
```

# make new column for percentage
```{r}
# make new column of percentage of total
df$perc_no_qual <- (df$no_qual / df$total)*100

```

# merge shapefile to data 
```{r}
SEmap <- merge(SEshp, df, by.x='msoa11cd', by.y='code')
```

# remove counties which cross over into the 
```{r}
toremove <- c("Dorset", "Hertfordshire",
              "Northamptonshire", "Gloucestershire",
              "Outer London", "Warwickshire")

# removes values which are not (!) in toremove list
SEmap <- SEmap[!(SEmap$CTY17NM %in% toremove),]
```

## 3. Mapping
# Map prerequisits
```{r}
tmap_mode("view")
tmap_options(limits = c(facets.view = 13))
```

# Map output
```{r}
tm_shape(SEmap) +
  tm_polygons("perc_no_qual",
              style="pretty",
              n=5,
              palette="Blues",
              midpoint=NA,
              title="Population (%)",
              popup.vars = c("msoa11nm","perc_no_qual"),
              id='msoa11cd') +
  tm_scale_bar() + 
  tm_layout(panel.show = TRUE) + 
  tm_facets(by = "CTY17NM", nrow = 2) +
  tm_view(set.view = 8)

```
```{r}

print("next")
```



## Appendix A: Code used to merge shapefile together based on Middle Super Output Areas (MSOA)

```{Python}
import geopandas as gpd
import pandas as pd
import numpy as np

gdf = gpd.read_file('southeastmsoa.shp')
