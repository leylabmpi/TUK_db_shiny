# Shiny UI
library(shiny)
library(plotly)


#-- shiny --#
shinyUI(fluidPage(
  fluidRow(
    column(4,
           downloadButton("downloadData", "Download selected data"),
           hr(),
           fileInput('query_file',
                     label = "File listing queries, 1 per line"),
           textInput('query_column',
                     label = 'Which column to query? ("all" = all columns)',
                     value = 'all'),
           h5(textOutput('n_records')),
           h5(textOutput('n_individuals'))
    ),
    column(3,
           checkboxGroupInput('tables',
                              label = 'Data to show',
                              choices = c('Show misc metadata?' = 'show_misc',
                                          'Show E538 metadata?' = 'show_E538',
                                          'Show E539 metadata?' = 'show_E539',
                                          'Show E662 metadata?' = 'show_E662',
                                          'Show E788 metadata?' = 'show_E788',
                                          'Show E808 metadata?' = 'show_E808',
                                          'Show sequence data?' = 'show_seq')
           ),
           h5('WARNING: table joins on tables with many values will be slow'),
           checkboxInput('inner_join',
                         'Just overlapping values?',
                         value = TRUE)
    ),
    column(4,
           conditionalPanel(
             'input.tables.includes("show_misc")',
             checkboxGroupInput('tables_misc',
                                label = 'Misc metadata',
                                choices = c('Show collection metadata?' = 'show_collection',
                                            'Show additional metadata?' = 'show_additional'))

           ),
           conditionalPanel(
             'input.tables.includes("show_E538")',
             checkboxGroupInput('tables_E538',
                                label = 'E538 metadata (cancer)',
                                choices = c('Show E538 raw data?' = 'show_E538_raw',
                                            'Show E538 value key?' = 'show_E538_key'))
           ),
           conditionalPanel(
             'input.tables.includes("show_E539")',
             checkboxGroupInput('tables_E539',
                                label = 'E539 metadata (immune/meds)',
                                choices = c('Show E539 immune data?' = 'show_E539_immune',
                                            'Show E539 medication data?' = 'show_E539_medication',
                                            'Show E539 value key?' = 'show_E539_key'))
           ),
           conditionalPanel(
             'input.tables.includes("show_E662")',
             checkboxGroupInput('tables_E662',
                                label = 'E662 metadata (anxiety)',
                                choices = c('Show E662 anxiety scores?' = 'show_E662_AS',
                                            'Show E662 raw data?' = 'show_E662_raw',
                                            'Show E662 data key?' = 'show_E662_key'))
           ),
           conditionalPanel(
             'input.tables.includes("show_E788")',
             checkboxGroupInput('tables_E788',
                                label = 'E788 metadata (cardiac)',
                                choices = c('Show E788 raw data?' = 'show_E788_raw',
                                            'Show E788 data key?' = 'show_E788_key'))
           ),
           conditionalPanel(
             'input.tables.includes("show_E808")',
             checkboxGroupInput('tables_E808',
                                label = 'E808 metadata (immune)',
                                choices = c('Show E808 raw data?' = 'show_E808_raw',
                                            'Show E808 value key?' = 'show_E808_key'))
           ),
           conditionalPanel(
             'input.tables.includes("show_seq")',
             checkboxGroupInput('tables_seq',
                                label = 'Sequence data',
                                choices = c('Show 16S qiime2 data?' = 'show_16S_qiime2',
                                            'Show metagenome data?' = 'show_metagenome',
                                            'Show TuKBif Bifidobacterium capture reactions?' = 'show_twubif_capture',
                                            'Check that files exist?' = 'check_exists'))
           )
    )
  ),
  tags$hr(),
  DT::dataTableOutput('table')
))
