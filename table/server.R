# Shiny server
library(shiny)
library(plotly)
source("../utils/io.R")


db_dir = '/Volumes/abt3_projects/TwinsUK/Dataset_summary/metadata_db/'
main_tble = 'main_metadata.tsv'
# 16S_qiime2.tsv
# E662_AS.tsv
# E662_raw.tsv
# E788_key.tsv
# E788.tsv
# main_metadata.tsv
# metagenomes.tsv

#-- server --#
shinyServer(function(input, output, session) {
  # querying database & making data table
  data = reactive({
    
  })
  

  # rendering data table
  output$table = DT::renderDataTable(
    data(),
    filter = 'top',
    rownames = FALSE,
    extensions = c('Buttons', 'ColReorder', 'FixedColumns'),
    options = list(pageLength = 10,
		   lengthMenu = list(c(10, 20, 40, 100, -1), c('10', '20', '40', '100', 'All')),
                   colReorder = TRUE,
                   dom = 'Blfrtip',
                   scrollX = TRUE,
                   buttons = c('colvis', 'copy', 'csv', 'excel', 'pdf', 'print'),
                   fixedColumns = list(leftColumns = 2)
                   )
  )

  # download all data
  output$downloadData <- downloadHandler(
    filename = function() {
      'TUK_metadata.csv'
    },
    content = function(file) {
      write.csv(data()[input$table_rows_all, , drop=FALSE], file, row.names = FALSE)
    }
  )

})

