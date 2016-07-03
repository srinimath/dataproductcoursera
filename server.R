library(UsingR)
library(quantmod)
library(ggplot2)
library(plyr)
library(dplyr)
library(forecast)
library(plotly)
shinyServer(
  function(input, output){
    dataInput <- reactive({
      getSymbols(input$symb, src = "yahoo",
                 from = input$dates[1],
                 to = input$dates[2],
                 auto.assign = FALSE)
      })
    finaldata <- reactive({
      validate(
        need(is.numeric(as.numeric(input$prednum)) == TRUE & as.numeric(input$prednum)%%1==0 , "Enter an integer value...")
        )
      dataInput1 <- as.data.frame(dataInput())
      dataInput1 <- transmute(dataInput1,Dates=as.Date(rownames(dataInput1)),AdjStockPrice=dataInput1[,6])
      if(input$model=="Arima"){fit <- auto.arima(dataInput1$AdjStockPrice)}
      if(input$model=="Exponential"){fit <- ets(dataInput1$AdjStockPrice)}
      forecasteddata <- forecast(fit,as.numeric(input$prednum))
      forecasteddata <- as.data.frame(forecasteddata)
      maxdate <- max(dataInput1$Dates)
      for (i in 1:nrow(forecasteddata)){
        maxdate=maxdate+1
        if(weekdays(maxdate)=="Saturday"){
          maxdate=maxdate+2
          }
        if(weekdays(maxdate)=="Sunday"){
          maxdate=maxdate+1
          }
        forecasteddata$Dates[i]= format(maxdate)
        }
      dataInput1 <- transmute(dataInput1,Dates,AdjStockPrice,Low80="",High80="",Low95="", High95="" ,Data="Actual")
      forecasteddata <- transmute(forecasteddata,Dates,AdjStockPrice = `Point Forecast`,Low80=`Lo 80`,
                                  High80=`Hi 80`,Low95=`Lo 95`, High95=`Hi 95` ,Data="Projected")
      rbind(dataInput1,forecasteddata)
      })
    output$plot <- renderPlot({
      chartSeries(dataInput(),theme = chartTheme("white"))
      })
    output$plot2 <- renderPlotly({
      finaldata <- as.data.frame(finaldata())
      if(input$ci=="95ci"){
        gg<- ggplot(finaldata)+geom_line(aes(x=Dates,y=AdjStockPrice,group=1,col=Data))+
          geom_ribbon(aes(x=Dates,y=AdjStockPrice,ymax=as.numeric(High95),ymin=as.numeric(Low95),group=1,col="95% CI"),
                      data=finaldata[finaldata$Data=="Projected",],alpha=0.3)
        }
      else if(input$ci=="80ci"){
        finaldata <- as.data.frame(finaldata())
        gg <- ggplot(finaldata)+geom_line(aes(x=Dates,y=AdjStockPrice,group=1,col=Data))+
          geom_ribbon(aes(x=Dates,y=AdjStockPrice,ymax=as.numeric(High80),ymin=as.numeric(Low80),group=1,col="80% CI"),
                      data=finaldata[finaldata$Data=="Projected",],alpha=0.3)
        }
      ggplotly(gg, displayModeBar = FALSE)
      })
    output$table <- renderDataTable({
      if(input$ci=="95ci"){
        forecasteddata <- as.data.frame(finaldata())
        forecasteddata <- forecasteddata[forecasteddata$Data=="Projected",]
        forecasteddata <- transmute(forecasteddata, Model = input$model, ProjectedDates = format(Dates), 
                                    ProjectedStockPrice=AdjStockPrice, LOw95CI=Low95, High95CI = High95 )
        forecasteddata
        }
      else if(input$ci=="80ci"){
        forecasteddata <- as.data.frame(finaldata())
        forecasteddata <- forecasteddata[forecasteddata$Data=="Projected",]
        forecasteddata <- transmute(forecasteddata, Model = input$model, ProjectedDates = format(Dates), 
                                    ProjectedStockPrice=AdjStockPrice, LOw80CI=Low80, High80CI = High80 )
        forecasteddata
        }
      })
    })