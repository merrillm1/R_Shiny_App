
shinyServer(function(input, output) {

   #Leaflet Map
  output$main_map <- renderLeaflet({
    req(input$min_bookings)
    
    x <- country_count %>% filter(Count >= input$min_bookings)
    
    leaflet() %>% addProviderTiles(providers$Esri.WorldStreetMap) %>% 
      addPolygons(data = st_as_sf(x), 
                  fillOpacity = 0.6, stroke = FALSE,
                  layerId = x$country,
                  color = x$Color, popup  = x$map_label)
    
  })
  
  #Plot matrix
  observeEvent(input$main_map_shape_click, {
    
    output$plot_matrix <- renderPlot({
      clicked_country <- input$main_map_shape_click
      x <- hotels %>% filter(country == clicked_country)
      x %>% select(children, adr, required_car_parking_spaces,
                             total_of_special_requests) %>% 
        ggpairs(aes(color = children))
    })
  })
  
  output$month_plot <- renderPlotly({
    req(input$main_map_shape_click)
    clicked_country <- input$main_map_shape_click
    x <- hotels %>% filter(country == clicked_country)
    x <- x %>% mutate(
      arrival_date_month = factor(arrival_date_month, levels = month.name)
      ) %>% count(hotel, arrival_date_month, children) %>% 
      group_by(hotel,children) %>% mutate(proportion = n/sum(n)) 
      
      ggplotly(
        ggplot(x, aes(x = arrival_date_month, y = proportion, fill = children)) +
          geom_col(position = 'dodge') +
          scale_y_continuous(labels = scales::percent_format()) +
          facet_wrap(~ hotel, nrow = 2)
      )
  })
  

# Save data for the model to predict on -----------------------------------

observeEvent(input$save_data, {
  new_df <- data.frame(
    previous_cancellations = input$previous_cancellations,
    lead_time = input$lead_time,
    customer_type_Transient = input$customer_type_Transient,
    market_segment_Groups = input$market_segment_Groups,
    adr = input$adr,
    customer_type_Transient_Party = input$customer_type_Transient_Party,
    arrival_date_week_number = input$arrival_date_week_number,
    previous_bookings_not_canceled = input$previous_bookings_not_canceled,
    arrival_date_year = input$arrival_date_year,
    market_segment_Online_TA = input$market_segment_Online_TA,
    market_segment_Direct = input$market_segment_Direct,
    agent_9.0 = input$agent_9.0
  )
  
  print(new_df)
  print(cat_model$predict(new_df))
  
  output$predicted_value <- renderText({
    paste('The predicted value for for this booking:', cat_model$predict(new_df))
  })
})  

})
