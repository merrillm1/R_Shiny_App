library(tidyverse)
library(lubridate)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(leaflet)
library(GGally)
library(reticulate)

theme_set(theme_light())
#Get data on map of countries

world <- ne_countries(scale = "medium", returnclass = "sf")

hotels <- readRDS('data/hotels.Rds')

hotels <- hotels %>% mutate(
  arrival_date = ymd(paste(
    arrival_date_year, arrival_date_month, arrival_date_day_of_month,
    sep = ' '
  ))
) %>% filter(country != 'NULL') %>% 
  mutate(
    agent = fct_lump_min(agent, 1000),
    company = fct_lump_min(company, 100),
    market_segment = fct_lump_min(market_segment, 500)
  ) %>% 
  mutate(children = case_when(
    children + babies == 0 ~ 'children',
    TRUE ~ 'none'
  ),
  required_car_parking_spaces = case_when(
    required_car_parking_spaces > 0 ~ 'parking',
    TRUE ~ 'none'
  ))

hotels$country[hotels$country == 'CN'] <- 'CHN' #To match the country name in world dataset

df <- world %>% filter(adm0_a3 %in% unique(hotels$country)) %>% 
  select(adm0_a3, name, geometry)

# not_avl <- setdiff(unique(hotels$country), unique(df$adm0_a3))
# hotels %>% filter(country %in% not_avl) %>% count(country)

#Country counts with atleast 10 bookings
country_count <- hotels %>% group_by(country) %>% 
  summarise(Count = n()) %>% 
  left_join(df, by = c('country' = 'adm0_a3')) %>% ungroup() %>% 
  select(country, name, Count, geometry) %>% 
  filter(!is.na(name), Count >= 500) %>% 
  mutate(Color = case_when(
    Count < 1000 ~ "#EBAD81",
    Count >= 1000 & Count < 5000 ~ "#7BE0A5",
    Count >= 5000 & Count < 10000 ~ "#4E76C2",
    Count >= 10000 ~ "#E34D4B"
  ))


#Add a label
country_count$map_label <- paste0("<b>","Country: ","</b>", country_count$name, "<br>",
                          "<b>", "Count of Bookings: ", "</b>", country_count$Count, "<br>")

#Load the python model
p <- import("pandas")
cat_model <- p$read_pickle('finalized_model.pkl')

model_data <- p$read_csv('data/feature_data.csv')

#cat_model$predict_proba(model_data[10, 1:20])
