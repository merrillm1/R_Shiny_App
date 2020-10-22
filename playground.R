model_data <- read.csv('/Users/mattmerrill/Springboard/Capstone/HotelExplorer_2/data/feature_data.csv', skip=1)
hotels <- read.csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-11/hotels.csv')

saveRDS(hotels, 'data/hotels.Rds')


library(shiny)
ui <- navbarPage(
  "Navbar!",
  tabPanel("Normal tabs"),
  tags$script(
    HTML(paste0(
      "var header = $('.navbar > .container-fluid');
     header.append('<div style=\"float:right; padding-top: 8px\">",
      selectInput(
        'test', 'Select Input', choices = c('Y', 'N')
        ),
      "</div>')"))
  )
)
server <- function(input, output, session) {
}
shinyApp(ui, server)
