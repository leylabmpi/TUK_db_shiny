# Shiny server
library(shiny)
library(plotly)
library(dplyr)
source("../utils/io.R")


#db_dir = '/Volumes/abt3_projects/TwinsUK/Dataset_summary/metadata_db/'
db_dir = '/ebio/abt3_projects/TwinsUK/Dataset_summary/metadata_db/'
# basic metadata
metadata_basic = file.path(db_dir, 'metadata_basic.tsv')
metadata_collection = file.path(db_dir, 'metadata__collection.tsv')
metadata_additional = file.path(db_dir, 'metadata_additional.tsv')
# E539
E539_immune = file.path(db_dir, 'E539_immune.tsv')
E539_medication = file.path(db_dir, 'E539_medication.tsv')
# E662
E662_AS = file.path(db_dir, 'E662_AS.tsv')
E662_raw = file.path(db_dir, 'E662_raw.tsv')
E788_raw = file.path(db_dir, 'E788.tsv')
# E788
E788_key = file.path(db_dir, 'E788_key.tsv')
# sequence data
rRNA16S_qiime2 = file.path(db_dir, '16S_qiime2.tsv')
metagenome = file.path(db_dir, 'metagenomes.tsv')
twubif_bifido_capture = file.path(db_dir, 'twubif_bifido_capture.tsv')

#-- server --#
shinyServer(function(input, output, session) {
  # querying database & making data table
  data = reactive({
    x = read.delim(metadata_basic, sep='\t')
    # filtering table
    ## by query file
    q = query()
    if(!is.null(q)){
      if(tolower(input$query_column) == 'all'){
        x = x[apply(x, 1, function(y) any(y %in% q[,1])),]
      } else {
        x = x[x[,input$query_column] %in% q[,1],]  
      }
    }
    if(input$inner_join){
      # table joins 
      ## extended basic metadata
      if('show_collection' %in% input$tables_misc){
        x = x %>%
          inner_join(read.delim(metadata_collection, sep='\t'),
                     c('s.FPBarcode'))
      } 
      if('show_additional' %in% input$tables_misc){
        x = x %>%
          inner_join(read.delim(metadata_additional, sep='\t'),
                     c('s.FPBarcode'))
      } 
      ## E539
      if('show_E539_immune' %in% input$tables_E539){
        x = x %>%
          inner_join(read.delim(E539_immune, sep='\t'),
                     c('i.IndividualID'))
      } 
      if('show_E539_medication' %in% input$tables_E539){
        x = x %>%
          inner_join(read.delim(E539_medication, sep='\t'),
                     c('s.NameOnSampleWithOutAnon' = 'Microbiome_ID'))
      } 
      ## E662 
      if('show_E662_AS' %in% input$tables_E662){
        x = x %>%
          inner_join(read.delim(E662_AS, sep='\t'),
                     c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      if('show_E662_raw' %in% input$tables_E662){
        x = x %>%
          inner_join(read.delim(E662_raw, sep='\t'),
                     c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      ## E788
      if('show_E788_raw' %in% input$tables_E788){
        x = x %>%
          inner_join(read.delim(E788_raw, sep='\t'),
                     c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      if('show_E788_raw' %in% input$tables_E788 & 'show_E788_key' %in% input$tables_E788){
        x = x %>%
          inner_join(read.delim(E788_key, sep='\t'),
                     c('E788_phenID' = 'PhenID',
                       'E788_phen_value' = 'Phen_value'))
      } 
      ## 16S
      if('show_16S_qiime2' %in% input$tables_seq){
        x = x %>%
          inner_join(read.delim(rRNA16S_qiime2, sep='\t'),
                     c('s.FPBarcode' = 'FPBarcode'))
      } 
      if('show_metagenome' %in% input$tables_seq){
        x = x %>%
          inner_join(read.delim(metagenome, sep='\t'),
                     c('s.FPBarcode' = 'Sample'))
      } 
      ## twubif
      if('show_twubif_capture' %in% input$tables_seq){
        x = x %>%
          inner_join(read.delim(twubif_bifido_capture, sep='\t'),
                     c('s.FPBarcode' = 'Sample'))
      } 
    } else {
      # table joins 
      ## extended basic metadata
      if('show_collection' %in% input$tables_misc){
        x = x %>%
          left_join(read.delim(metadata_collection, sep='\t'),
                    c('s.FPBarcode'))
      } 
      if('show_additional' %in% input$tables_misc){
        x = x %>%
          left_join(read.delim(metadata_additional, sep='\t'),
                    c('s.FPBarcode'))
      } 
      ## E539
      if('show_E539_immune' %in% input$tables_E539){
        x = x %>%
          left_join(read.delim(E539_immune, sep='\t'),
                    c('i.IndividualID'))
      } 
      if('show_E539_medication' %in% input$tables_E539){
        x = x %>%
          left_join(read.delim(E539_medication, sep='\t'),
                    c('s.NameOnSampleWithOutAnon' = 'Microbiome_ID'))
      } 
      ## E662 
      if('show_E662_AS' %in% input$tables_E662){
        x = x %>%
          left_join(read.delim(E662_AS, sep='\t'),
                    c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      if('show_E662_raw' %in% input$tables_E662){
        x = x %>%
          left_join(read.delim(E662_raw, sep='\t'),
                    c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      ## E788
      if('show_E788_raw' %in% input$tables_E788){
        x = x %>%
          left_join(read.delim(E788_raw, sep='\t'),
                    c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
      } 
      if('show_E788_raw' %in% input$tables_E788 & 'show_E788_key' %in% input$tables_E788){
        x = x %>%
          left_join(read.delim(E788_key, sep='\t'),
                    c('E788_phenID' = 'PhenID',
                      'E788_phen_value' = 'Phen_value'))
      } 
      ## 16S
      if('show_16S_qiime2' %in% input$tables_seq){
        x = x %>%
          left_join(read.delim(rRNA16S_qiime2, sep='\t'),
                    c('s.FPBarcode' = 'FPBarcode'))
      } 
      if('show_metagenome' %in% input$tables_seq){
        x = x %>%
          left_join(read.delim(metagenome, sep='\t'),
                    c('s.FPBarcode' = 'Sample'))
      } 
      ## twubif
      if('show_twubif_capture' %in% input$tables_seq){
        x = x %>%
          left_join(read.delim(twubif_bifido_capture, sep='\t'),
                    c('s.FPBarcode' = 'Sample'))
      } 
    }
    
    # filter by query again
    if(!is.null(q)){
      if(tolower(input$query_column) == 'all'){
        x = x[apply(x, 1, function(y) any(y %in% q[,1])),]
      } else {
        x = x[x[,input$query_column] %in% q[,1],]  
      }
    } 
    # ret
    return(x)
  })
  
  # reading in query list
  query = reactive({
    if(is.null(input$query_file)){
      return(NULL)
    } 
    infile = rename_tmp_file(input$query_file)
    read.delim(infile, sep='\t', header=FALSE)
  })

  # rendering data table
  output$table = DT::renderDataTable(
    data(),
    filter = 'top',
    rownames = FALSE,
    extensions = c('Buttons', 'ColReorder', 'FixedColumns'),
    options = list(pageLength = 10,
		   lengthMenu = list(c(10, 50, 100, 500, -1), c('10', '50', '100', '500', 'All')),
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

