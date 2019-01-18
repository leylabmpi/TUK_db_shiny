# Shiny UI
library(shiny)
library(plotly)


#-- shiny --#
shinyUI(fluidPage(
  fluidRow(
    column(4,
           fileInput('query_file', 
                     label = "File listing queries, 1 per line"),
           textInput('query_column', 
                     label = 'Which column to query? ("all" = all columns)',
                     value = 'all') 
    ),
    column(4,
           checkboxGroupInput('tables',
                              label = 'Data to show',
                              choices = c('Show collection metadata?' = 'show_collection',
                                          'Show additional metadata?' = 'show_additional',
                                          'Show E662 anxiety scores?' = 'show_E662_AS',
                                          'Show E662 raw data?' = 'show_E662_raw',
                                          'Show E788 raw data?' = 'show_E788_raw',
                                          'Show E788 data key?' = 'show_E788_key',
                                          'Show 16S qiime2 data?' = 'show_16S_qiime2',
                                          'Show metagenome data?' = 'show_metagenome',
                                          'Show twubif genome capture data?' = 'show_twubif_capture')
           )
    ),
    column(2, 
           br(),
           br(),
           downloadButton("downloadData", "Download selected data")
    )
  ),
  tags$hr(),
  DT::dataTableOutput('table')
))
