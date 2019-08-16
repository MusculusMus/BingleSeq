#' Single Cell Load Data UI
#'
#' @export
#' @return None
sc_loadDataUI <- function(id) {
  ns <- NS(id)

  tagList(
    # Sidebar layout with input and output definitions ----
    sidebarPanel(

      h4("Upload Data"),

      radioButtons(
        ns("loadData"),
        label = "Data Type",
        c("Count Data Table" = 1, "10x Genomics Data" = 2)
      ),

      conditionalPanel(
        condition = "input.loadData == 1",
        ns = ns,



        radioButtons(
          ns("sep"),
          "Separator",
          choices = c(
            Comma = ",",
            Space = " ",
            Tab = "\t",
            Semicolumn = ";"
          )
        ),


        fileInput(
          ns("file1"),
          "Choose Counts File",
          multiple = FALSE,
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        )

      ),

      conditionalPanel(
        condition = "input.loadData == 2",
        ns = ns,
        shinyDirButton(
          ns('directoryButton'),
          'Select Directory',
          'Please select a folder'
        )

      )
    ),

    # Main panel for displaying outputs ----
    mainPanel(
      htmlOutput(ns("helpLoadInfo")),
      verbatimTextOutput(ns("loadDataText"), placeholder = F)
      )
  )
}


#' Single Cell Load Data Server
#'
#' Enables the upload of two types of data: 10x Genomics and Count data
#'
#' @export
#' @return counts - The count table to be used in the sc analysis
sc_loadData <- function(input, output, session) {
  counts <- reactiveValues()



  output$helpLoadInfo <- renderUI({
    if(as.numeric(input$loadData)==1 && is.null(counts$countTable)){
      HTML("<div style='border:2px solid blue; font-size: 14px; border-radius: 10px;text-align: center'>
      <p style='padding-top: 8px'> Select a count table that contains the read counts in .csv/.txt file format. </p>
      <p style ='font-style: italic; padding-bottom: 8px;'> Note: The first row(header)
           and first column should contain cell names and gene names/IDs, respsectively </p> </div>")
    }else if(as.numeric(input$loadData)==2 && is.null(counts$countTable)){
      HTML("<div style='border:2px solid blue; font-size: 14px; border-radius: 10px;text-align: center'>
           <p style='padding-top: 8px'; padding-bottom: 8px;>
           Select a 10x Genomics output directory containing matrix.mtx, barcodes.tsv, and genes.tsv files </p> </div>")
    } else{
      HTML("")
    }
  })


  # Load 10x -----
  observeEvent(input$directoryButton, {
    volumes <- getVolumes()

    shinyDirChoose(input,
                   'directoryButton',
                   roots = volumes,
                   session = session)


    path1 <- reactive({
      return(print(parseDirPath(volumes, input$directoryButton)))
    })


    # show meta data table
    if (!is.null(path1)) {

      req(nchar(path1()) > 0)

      show_waiter(tagList(spin_folding_cube(), h2("Loading ...")))
      counts$countTable <- load10xData(path1(), session)
      hide_waiter()

    }
  })

  # Load CountTable -----
  observeEvent(input$file1, {
    show_waiter(tagList(spin_folding_cube(), h2("Loading ...")))
    counts$countTable <- read.csv(input$file1$datapath,
                                  sep = input$sep,
                                  row.names = 1)

    hide_waiter()

  })


  observe({
    output$loadDataText <- renderText({
      sprintf(
        " Number of cells is %s;\n Number of genes is %s;",
        ncol(counts$countTable),
        nrow(counts$countTable)
      )
    })
  })



  return(counts)
}


#' Load 10x Data with TryCatch
#'
#' Simply adds TryCatch statement to the function supplied by Seurat
#'
#'
#' @param path The directory containing the 10X genomics data
#'
#' @export
#' @return
load10xData <- function(path, session) {
  counts <- tryCatch(
    {
      counts <- Read10X(data.dir = path)
    },
    error=function(cond) {
      sendSweetAlert(
        session = session,
        title = "Data format error",
        text = "Ensure that a folder containing 10X Genomics data was appropriately chosen",
        type = "error"
      )
      return()
    }
  )
  return(counts)
}