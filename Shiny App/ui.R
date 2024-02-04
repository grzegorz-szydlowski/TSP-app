#ui.R
library(shiny)
library(shinyWidgets)
library(DT)
library(leaflet)
library(TSP)
citiesData <- read.csv("cityCoordinatesV2.csv")

shinyUI
(
  fluidPage
  (
    setBackgroundColor("lightblue"),
    div(style = "text-align: center;",
        titlePanel("Interactive TSP visualisation")),
    sidebarPanel
    (
      sliderInput("numOfCities", "Choose the number of cities", min = 5, max = 25, value = 5),
      selectizeInput("selectedCities", "Select cities", choice = citiesData$city, multiple = TRUE),
      selectizeInput("selectedStart", "Select the starting point", choice = citiesData$city, multiple = FALSE),
      selectizeInput("selectedAlgorithm", "Select the algorithm", choice = c("Nearest insertion", "Farthest insertion"), multiple = FALSE),
      h3("Run the simulation"),
      div(style = "text-align: center;",
          actionButton("runUnoptimised", "Unoptimised route", style = "width: 150px; text-align: center;")),
      div(style = "text-align: center;",
          actionButton("runOptimised", "Optimised route", style = "width: 150px; text-align: center;"))

    ),
    mainPanel
    (
      tabsetPanel
      (
        tabPanel("About", h2("TSP - the Travelling Salesman Problem"),
                 helpText("This application visualises the TSP in a real world scenario. You can choose how many and which cities the Salesman has to visit. There are a total of 26 cities all over Europe for you to choose from. The unoptimised route is based on the alphabetical order of the cities. The optimised route is calculated using a proper algorithm."),
                 h4("Map of the available cities"),
                 leafletOutput("mapPlotFrontPage")),
        tabPanel("Salesman's route", conditionalPanel(
          condition = "input.runUnoptimised > 0 || input.runOptimised > 0",
          leafletOutput("mapPlot")
        )),
        tabPanel("Dataset", DTOutput("citiesDataTable")),
      )
    ),
      
      
  )
)

