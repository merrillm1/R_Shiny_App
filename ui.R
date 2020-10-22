navbarPage(
  theme = shinytheme('united'),
  title = div(img(src = 'img/compass.png', 
                  height = 30, 
                  width = 30), 'Hotel Explorer'),
  windowTitle = 'HotelExplorer',
  fluid = TRUE,
  
  tabPanel(
    title = 'Explore',
    fluidRow(
      column(
        12,
        h4('This is where you can write a little introduction')
      )
    ),
    sidebarLayout(
      sidebarPanel(
        width = 3,
        p('The map on the right allows you to explore bookings made from different countries
          for the two hotels in Portugal. Use the slider input below to select the minimum number of 
          bookings made from each country'),
        sliderInput('min_bookings', 'Select minimum number of bookings',
                    min = 500, max = 30000, value = 500),
        hr(),
        p('You can get further insights on the bookings made from each country by clicking 
          on the country of interest'),
        p('The plot matrix you get below the map on clicking a country, is colour coded according to the booking
          request made if children were also included in the guests. The other variables considered are
          ADR, whetehr car parking has been requested and total number of special requests.')
      ),
      mainPanel(
        leafletOutput('main_map', height = '600px'),
        hr(), br(),
        plotOutput('plot_matrix',height = '600px'),
        hr(), br(),
        plotlyOutput('month_plot')
      )
    )
  ),

# Predictive Model --------------------------------------------------------

  tabPanel(
    title = 'Predict Cancellations',
    fluidRow(
      h4('Use the inputs below to enter details of the booking')
    ),
    hr(),
    fluidRow(
      column(3, numericInput('arrival_date_year', 'Year of arrival:', value=2015, min=2015, max=2020, step=1)),
      column(3, numericInput('arrival_date_week_number', 'Week of the year:', value=26, min=1, max=52, step=1)),
      column(3, numericInput('lead_time', 'How many days until the stay?',value = 10)),
      column(3, numericInput('adr', 'What is the average daily rate?', value = 0))
    ),
    
    fluidRow(
      column(3, checkboxInput('market_segment_Online_TA', 'Was this booking made through an online travel agency?', value=TRUE)),
      column(3, conditionalPanel(
        condition = "'input.market_segment_Online_TA' == FALSE",
        checkboxInput('market_segment_Direct', 'Was this booking direct through the Hotel?', value = TRUE))),
      column(3, conditionalPanel(
        condition = "'input.market_segment_Direct' == FALSE",
        checkboxInput('market_segment_Groups', 'Was this booking made with a Group?', value = FALSE))),
      column(3, checkboxInput('agent_9.0', 'Was this booking made with agent 9?', value=FALSE))
      
    ),
    fluidRow(
      column(3, checkboxInput('customer_type_Transient_Party', 'Was this a transient booking connected with a party?',
                              value = TRUE)),
      column(3, conditionalPanel(
        condition = "input.customer_type_Transient == FALSE",
        checkboxInput('customer_type_Transient', 'Was this a transient booking not connected with a party?', value = FALSE))),
      column(3, checkboxInput('previous_cancellations', 'Has this guest canceled before?', value = FALSE)),
      column(3, checkboxInput('previous_bookings_not_canceled', 'Has this guest stayed at this hotel before?', value = FALSE)) 
    ),
    
    fluidRow(

    ),
    hr(),
    actionButton('save_data', 'Save Data', icon = icon('floppy-o')),
    hr(),
    textOutput('predicted_value')
  ),

  tabPanel(
    title = 'About'
  )
)