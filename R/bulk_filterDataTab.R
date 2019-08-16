#' Bulk Filter Tab UI
#'
#' @export
#' @return None
bulk_filterDataUI <- function(id) {
  ns <- NS(id)

  tagList(
    sidebarPanel(
      h4("Filter Counts Table"),

      # Select Filter Method
      selectInput(
        ns("selectFilter"),
        label = "Select Filter Method",
        choices = list(
          "CPM" = 1,
          "Median" = 2,
          "Max" = 3
        ),
        selected = 1
      ),

      # Horizontal line
      tags$hr(),


      # Input: Select threshold number ----
      numericInput(ns("filterValue"), label = "Value to filter", value = 2),

      hr(),
      fluidRow(column(3, verbatimTextOutput(
        ns("filterValue")
      ))),



      # Input: Button that calls the filter function ----
      actionButton(ns("filterButton"), label = "Filter Data")

    ),

    # Main panel for displaying outputs ----
    mainPanel(fluidRow(
      column(
        width = 4,
        offset = 0,
        tags$h4("Raw Data Summary"),
        DT::dataTableOutput(ns("prefilterTable"))
      ),

      column(
        width = 4,
        offset = 0,
        tags$h4("Filtered Data Summary"),
        DT::dataTableOutput(ns("postfilterTable"))
      )
    ))
  )
}


#' Bulk Filter Tab Server
#'
#' @param counts The loaded Count Table
#'
#' @export
#' @return filt A reactive value with the filtered Count Table
bulk_filterData <- function(input, output, session, counts) {
  filt <- reactiveValues()

  observeEvent(input$filterButton, {
    filt$filteredCounts <-
      filterFunction(
        counts$countTable,
        as.numeric(input$selectFilter),
        as.numeric(input$filterValue)
      )

    output$postfilterTable <- DT::renderDataTable(DT::datatable(
      generateSummary(filt$filteredCounts, session),
      options = list(paging = FALSE, searching = FALSE),
      rownames = FALSE
    ))

    # Used to generate DE Tab only when generateSummary is OK
    filt$correctFormat <- TRUE
  })

  return(filt)
}


#' Filter Function
#'
#' @param countTable The loaded Count Table
#' @param method Filter Option (CPM, MAX, Median)
#' @param value Keep only genes with counts > than this value
#'
#' @export
#' @return countTable The filtered Count Table
filterFunction <- function(data, method, value) {
  countTable  <- data[, -1]
  rownames(countTable) <- data[, 1]


  #filter by CPM
  if (method == 1) {
    keep <- rowSums(edgeR::cpm.default(countTable) > 1) >= value
    countTable <- countTable[keep, ]

    #filter by Median
  } else if (method == 2) {
    countTable <-
      subset(countTable, apply(countTable, 1, median) >= value)

    #filter by Max
  } else if (method == 3) {
    countTable <- subset(countTable, apply(countTable, 1, max) >= value)

  }

  # add gene IDs as first column


  IDs <- rownames(countTable)

  rownames(countTable) <- NULL

  countTable <- cbind(IDs, countTable)

  head(countTable)
  # write.csv(countTable, file="output/filtered_Data.csv", row.names = FALSE)

  return(countTable)
}