library(UsingR)
library(quantmod)
library(ggplot2)
library(plyr)
library(dplyr)
library(forecast)
library(plotly)
shinyUI(
  tabsetPanel(
    tabPanel("Stock Analysis",
             fluidPage(
               headerPanel("Stock Analysis"),
               sidebarPanel(
                 h2("Stock Trends"),
                 textInput("symb","Enter Stock Symbol here","AAPL"),
                 a( "Click Here!", href="http://finance.yahoo.com/lookup"),
                 p("to search for stock symbols"),
                 dateRangeInput("dates","Date range",
                                start = as.character(Sys.Date()-180), 
                                end = as.character(Sys.Date())),
                 br(),
                 br(),
                 radioButtons("chooseForecast", label = "Would you like to forecast?",
                              choices = list("No" = 0, "Yes" = 1),
                              selected = 0),
                 conditionalPanel(
                   condition = "input.chooseForecast == 1",
                   h2("Stock Forecasting"),
                   selectInput(
                     "model", "Select forecasting model from below",
                     c("Exponential"="Exponential","Arima"="Arima")),
                   textInput("prednum","Choose total periods to be predicted",10),
                   selectInput(
                     "ci", "Choose confidence Interval",
                     c("95% CI"="95ci","80% CI"="80ci")),
                   radioButtons("forecasttableradio", label = "Would you like see forecasted data",
                                choices = list("No" = 0, "Yes" = 1),
                                selected = 0),
                   br(),
                   br()
                   )
                 ),
               mainPanel(
                 h4("Stock Trend Chart",align ="center"),
                 plotOutput('plot'),
                 conditionalPanel(
                   condition = "input.chooseForecast == 1",h4("Stock Forecast Chart",align ="center")
                   ),
                 conditionalPanel(
                   condition = "input.chooseForecast == 1",plotlyOutput('plot2')),
                 conditionalPanel(
                   condition = "input.forecasttableradio == 1 & input.chooseForecast == 1",h4("Stock Forecasted Data",align ="center")
                   ),
                 conditionalPanel(
                   condition = "input.forecasttableradio == 1 & input.chooseForecast == 1",dataTableOutput('table'))
                 )
               )
             ),
    tabPanel("Documentation",
      h2("Introduction",align="left"),
      p("Check the trends of your favorite stock for any period using this application. You can just look at the trends or even use your
        trend data to forecast upto any period. Remember not to have a high number here as the farther the models have to predict less
        accurate it becomes"),
      p("The Stock Forecast Chart is also interactive if you choose to hover over it to see data for that period. You can also see the 
        forecasted data in tabular form by choosing Yes on the last radio button"),
      p("On opening the application the first time, if you dont see any charts, please wait for a few seconds for it to load."),
      h2("References",align="left"),
      a("1. Confidence Interval (CI)", href = "https://en.wikipedia.org/wiki/Confidence_interval"),
      br(),
      a("2. Exponential Time Smoothing", href = "https://en.wikipedia.org/wiki/Exponential_smoothing"),
      br(),
      a("3. Arima", href = "https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average")
      )
    )
  )
  