# Shiny UI
library(shiny)
library(plotly)


#-- shiny --#
shinyUI(fluidPage(
  fluidRow(
    column(4,
           br(),
          downloadButton("downloadData", "Download selected data")
    ),
    column(4,
           fileInput('query_file', 
                     label = "Query file listing queries, 1 per line")
    ),
    column(4,
           textInput('query_column', 
                     label = 'Which column to query? ("all" = all columns)',
                     value = 'all'),   
           checkboxGroupInput('filters',
                         label = 'Filters',
                         choices = c('Just show unused samples?' = 'show_unused',
                                     'Just show used samples?' = 'show_used')
                         )
    )
  ),
  tags$hr(),
  DT::dataTableOutput('table')
))
