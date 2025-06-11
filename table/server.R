# Shiny server
library(shiny)
library(plotly)
library(dplyr)
library(data.table)
library(tidytable)
source("../utils/io.R")
setDTthreads(4)


#db_dir = '/Volumes/abt3_projects/TwinsUK/Dataset_summary/metadata_db/'
db_dir = '/ebio/abt3_projects2/TwinsUK/Dataset_summary/metadata_db/'
# basic metadata
metadata_basic = file.path(db_dir, 'metadata_basic.tsv')
metadata_collection = file.path(db_dir, 'metadata__collection.tsv')
metadata_additional = file.path(db_dir, 'metadata_additional.tsv')
# E538
E538_key = file.path(db_dir, 'E538_key.tsv')
E538_raw = file.path(db_dir, 'E538_raw.tsv')
# E539
E539_key = file.path(db_dir, 'E539_key.tsv')
E539_immune = file.path(db_dir, 'E539_immune.tsv')
E539_medication = file.path(db_dir, 'E539_medication.tsv')
# E662
E662_AS = file.path(db_dir, 'E662_AS.tsv')
E662_raw = file.path(db_dir, 'E662_raw.tsv')
E662_key = file.path(db_dir, 'E662_key.tsv')
# E788
E788_raw = file.path(db_dir, 'E788.tsv')
E788_key = file.path(db_dir, 'E788_key.tsv')
# E808
E808_key = file.path(db_dir, 'E808_key.tsv')
E808_raw = file.path(db_dir, 'E808_raw.tsv')
# sequence data
rRNA16S_qiime2 = file.path(db_dir, '16S_qiime2.tsv')
metagenome = file.path(db_dir, 'metagenomes.tsv')
twubif_bifido_capture = file.path(db_dir, 'twubif_bifido_capture.tsv')

#-- server --#
shinyServer(function(input, output, session) {
  # querying database & making data table
  data = reactive({
    x = fread(metadata_basic, sep='\t') %>%
        mutate(s.FPBarcode = s.FPBarcode %>% as.character)
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
    # which join to use?
    if(input$inner_join){
      JOIN = function(...){
        inner_join.(...)
      }
    } else {
      JOIN = function(...){
        left_join.(...)
      }
    }
    # table joins
    ## extended basic metadata
    if('show_collection' %in% input$tables_misc){
      x = x %>%
        JOIN(fread(metadata_collection, sep='\t') %>%
               mutate.(s.FPBarcode = s.FPBarcode %>% as.character),
             c('s.FPBarcode'))
    }
    if('show_additional' %in% input$tables_misc){
      x = x %>%
        JOIN(fread(metadata_additional, sep='\t') %>%
               mutate.(s.FPBarcode = s.FPBarcode %>% as.character),
             c('s.FPBarcode'))
    }
    ## E538
    if('show_E538_raw' %in% input$tables_E538){
      x = x %>%
        JOIN(fread(E538_raw, sep='\t'),
             c('s.NameOnSampleWithOutAnon' = 'Microbiome_ID'))
    }
    if('show_E538_key' %in% input$tables_E538){
      x = x %>%
        JOIN(fread(E538_key, sep='\t'),
             c('E538_phenID'='PhenID'))
    }
    ## E539
    if('show_E539_immune' %in% input$tables_E539){
      x = x %>%
        JOIN(fread(E539_immune, sep='\t'),
             c('i.IndividualID'))
    }
    if('show_E539_medication' %in% input$tables_E539){
      x = x %>%
        JOIN(fread(E539_medication, sep='\t'),
             c('s.NameOnSampleWithOutAnon' = 'Microbiome_ID'))
    }
    if('show_E539_key' %in% input$tables_E539 &
       'show_E539_immune' %in% input$tables_E539){
      x = x %>%
        JOIN(fread(E539_key, sep='\t'),
             c('E539_immune_phenID' = 'E539_phenID',
               'E539_immune_phen_value' = 'E539_phen_value_code'))
    }
    if('show_E539_key' %in% input$tables_E539 &
       'show_E539_medication' %in% input$tables_E539){
      x = x %>%
        JOIN(fread(E539_key, sep='\t'),
             c('E539_medication_phenID' = 'E539_phenID',
               'E539_medication_phen_value' = 'E539_phen_value_code'))
    }
    ## E662
    if('show_E662_AS' %in% input$tables_E662){
      x = x %>%
        JOIN(fread(E662_AS, sep='\t'),
             c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
    }
    if('show_E662_raw' %in% input$tables_E662){
      x = x %>%
        JOIN(fread(E662_raw, sep='\t'),
             c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
    }
    if('show_E662_key' %in% input$tables_E662 &
       'show_E662_raw' %in% input$tables_E662){
      x = x %>%
        JOIN(fread(E662_key, sep='\t'),
             c('E662_phenID', 'E662_phen_value'))
    }
    ## E788
    if('show_E788_raw' %in% input$tables_E788){
      x = x %>%
        JOIN(fread(E788_raw, sep='\t'),
             c('s.NameOnSampleWithAnon' = 'Microbiome_ID'))
    }
    if('show_E788_raw' %in% input$tables_E788 &
       'show_E788_key' %in% input$tables_E788){
      x = x %>%
        JOIN(fread(E788_key, sep='\t'),
             c('E788_phenID' = 'PhenID',
               'E788_phen_value' = 'Phen_value'))
    }
    ## E808
    if('show_E808_raw' %in% input$tables_E808){
      x = x %>%
        JOIN(fread(E808_raw, sep='\t'),
             c('s.NameOnSampleWithOutAnon' = 'Microbiome_ID'))
    }
    if('show_E808_key' %in% input$tables_E808){
      x = x %>%
        JOIN(fread(E808_key, sep='\t'),
             c('E808_phenID'='PhenID'))
    }
    ## 16S
    if('check_exists' %in% input$tables_seq){
      check_file = function(x) file.exists(x)
    } else {
      check_file = function(x) NULL
    }
    if('show_16S_qiime2' %in% input$tables_seq){
      x = x %>%
        JOIN(fread(rRNA16S_qiime2, sep='\t') %>%
               mutate.(r16S_read1_exists = sapply(r16S_read1, function(x) check_file(x)),
                       r16S_read2_exists = sapply(r16S_read2, function(x) check_file(x)),
                       FPBarcode = FPBarcode %>% as.character),
             c('s.FPBarcode' = 'FPBarcode'))
    }
    if('show_metagenome' %in% input$tables_seq){
      x = x %>%
        JOIN(fread(metagenome, sep='\t') %>%
               mutate.(MG_read1_exists = sapply(MG_read1, function(x) check_file(x)),
                       MG_read2_exists = sapply(MG_read2, function(x) check_file(x)),
                       MG_read12_exists = sapply(MG_read12, function(x) check_file(x)),
                       Sample = Sample %>% as.character),
             c('s.FPBarcode' = 'Sample'))
    }
    ## twubif
    if('show_twubif_capture' %in% input$tables_seq){
      x = x %>%
        JOIN(fread(twubif_bifido_capture, sep='\t') %>%
               mutate.(Sample = Sample %>% as.character),
             c('s.FPBarcode' = 'Sample'))
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
    fread(infile, sep='\t', header=FALSE)
  })
  # selected records table
  dt_table = reactive({
    data()
  })
  # stats
  output$n_records = reactive({
    x = dt_table() %>% nrow
    return(paste('No. of records selected:', x, sep=' '))
  })
  output$n_individuals = reactive({
    x = dt_table() %>% distinct(i.IndividualID) %>% nrow
    return(paste('No. of individuals selected:', x, sep=' '))
  })
  # rendering data table
  output$table = DT::renderDataTable(
    dt_table(),
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
      write.csv(data()[input$table_rows_all, , drop=FALSE], file, row.names=FALSE, quote=FALSE)
    }
  )

})

