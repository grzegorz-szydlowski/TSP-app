
library(shiny)
library(DT)
library(leaflet)
library(TSP)

citiesData2 <- read.csv("cityCoordinatesV2.csv")
colnames(citiesData2) <- c("City", "Latitude", "Longitude")
distanceMatrix <- read.csv("distanceMatrix.csv", row.names = 1)

shinyServer(function(input, output, session) {
  output$mapPlotFrontPage <- renderLeaflet({
    leaflet(data = citiesData2) %>%
      addTiles() %>%
      addMarkers(lng = ~Longitude, lat = ~Latitude, label = ~City)
  })
  
  
  observe({
    updateSelectizeInput(session, "selectedCities", options = list(maxItems = input$numOfCities))
  })
  
  observe({
    updateSelectizeInput(session, "selectedStart", choices = setNames(setdiff(citiesData2$City, input$selectedCities), setdiff(citiesData2$City, input$selectedCities)))
  })
  
  unoptimisedRouteData <- reactive({
    selectedCities <- input$selectedCities
    selectedStart <- input$selectedStart
    filteredCities <- citiesData2[citiesData2$City %in% selectedCities, ]
    sortedCities <- filteredCities[order(filteredCities$City), ]
    startingPoint <- citiesData2[citiesData2$City %in% selectedStart, ]
    result <- rbind(startingPoint, sortedCities)
    return(result)
  })
 
  
  observeEvent(input$runUnoptimised, {
    unoptimisedRouteDataValue <- unoptimisedRouteData()
    print(unoptimisedRouteDataValue)
    output$mapPlot <- renderLeaflet({
      leaflet(data = unoptimisedRouteDataValue) %>%
        addTiles() %>%
        addMarkers(lng = ~Longitude, lat = ~Latitude, label = ~City) %>%
        addPolylines(data = unoptimisedRouteDataValue, lng = ~Longitude, lat = ~Latitude)
    })
  })
 
  
  optimisedRouteData <- reactive({
    selectedCities <- input$selectedCities
    selectedStart <- input$selectedStart
    selectedAlgorithm <- "default"
    if (input$selectedAlgorithm == "Nearest insertion") {
      selectedAlgorithm = "nearest_insertion"
    } else {
      selectedAlgorithm = "farthest_insertion"
    }
    filteredDistanceMatrix <- distanceMatrix[(rownames(distanceMatrix) %in% c(selectedCities, selectedStart)), 
                                             (colnames(distanceMatrix) %in% c(selectedCities, selectedStart))]
    startIndex <- which(rownames(filteredDistanceMatrix) == selectedStart)
    tsp <- TSP(as.dist(filteredDistanceMatrix))
    tspRoute <- solve_TSP(tsp, method = selectedAlgorithm, start = startIndex)
    routeCityNames <- names(tspRoute)
    matchingRows <- match(routeCityNames, citiesData2$City)
    routeCities <- citiesData2[matchingRows, ]
    return(routeCities)
    
  })
  
  observeEvent(input$runOptimised, {
    optimisedRouteDataValue <- optimisedRouteData()
    print(optimisedRouteDataValue)
    
    output$mapPlot <- renderLeaflet({
      leaflet(data = optimisedRouteDataValue) %>%
        addTiles() %>%
        addMarkers(lng = ~Longitude, lat = ~Latitude, label = ~City) %>%
        addPolylines(data = optimisedRouteDataValue, lng = ~Longitude, lat = ~Latitude)
    })
  })
  
  output$citiesDataTable <- renderDT({
    datatable(citiesData2, options = list(pageLength = 10))
  })
  
})