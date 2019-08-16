#' Differential Expression Tab UI
#'
#' @export
#' @return None
bulk_deDataUI <- function(id) {
  ns <- NS(id)

  tagList(
    # Sidebar panel for inputs ----

    sidebarPanel(

      h4("Run DE Pipeline"),

      # Input: Select a package ----
      # Select DE package
      selectInput(
        ns("selectPackage"),
        label = "Select DE package",
        choices = list(
          "DESeq2" = 1,
          "EdgeR" = 2,
          "ALDEx2" = 3,
          "Limma" = 4
        ),
        selected = 1
      ),

      # Horizontal line
      tags$hr(),

      # Input: Select condition number ----
      numericInput(
        ns("conditionNo"),
        label = "Number of Conditions",
        value = 3,
        min = 2,
        max = 3
      ),

      hr(),
      fluidRow(column(3, verbatimTextOutput(
        ns("conditionNo")
      ))),

      # Input: Select replicate number ----
      numericInput(
        ns("replicateNo"),
        label = "Number of Replicates",
        value = 4,
        min = 1
      ),

      hr(),
      fluidRow(column(3, verbatimTextOutput(
        ns("replicateNo")
      ))),


      # Input: Button that runs the analysis ----
      actionButton(ns("dePackageButton"), label = "Run DE Analysis")

    ),

    # Main panel for displaying outputs ----
    mainPanel(# Output: DE Table ----
              htmlOutput(ns("helpDEInfo")),
              DT::dataTableOutput(ns("deTable")))


  )
}


#' Differential Expression Tab Server
#'
#' @param fCounts The reactive value containing the filtered counts
#'
#' @export
#' @return A reactive value with differential expression results
bulk_deData <- function(input, output, session, fCounts) {
  de <- reactiveValues()

  output$helpDEInfo <- renderUI({
    if(is.null(de$deTable)){
      HTML("<div style='border:2px solid blue; font-size: 14px; border-radius: 10px;'>

      <p style ='font-size: 15px; text-align: center'><b>This tab enables DE analysis using <i>DESeq2,
      edgeR,</i> and <i>limma</i> pipelines. </b> </p> <br>

      Upon DE pipeline completion, a results table is displayed
      that contains the log2 expression fold-change (logFC), package specific test statistics, p-value,
      multiple-testing adjusted p-value (FDR). <br> <br>

      <i>Note: Diffrences among different samples are accounted for using the package-specific methods.
      Furthermore, only comparisons with up to 3 conditions with the same number of replicates across
      each condition are implemented and the  appropriate number of conditions and replicates must be provided. </i></div>")
    } else{
      HTML("")
    }
  })

  # Run DE ----
  observeEvent(input$dePackageButton, {
    # Save values to variables
    de$selectedPackage <- as.numeric(input$selectPackage)
    de$conditionNo <- as.numeric(input$conditionNo)
    de$replicateNo <- as.numeric(input$replicateNo)

    print(de$selectedPackage)
    print(de$conditionNo)
    print(as.numeric(de$replicateNo))

    if (de$conditionNo == 2) {
      de$offset <- 4
    } else if (de$conditionNo == 3) {
      de$offset <- 7
    } else if (de$conditionNo == 4) {
      de$offset <- 10
    }

    print("offset is:")
    print(de$offset)

    show_waiter(tagList(spin_folding_cube(), h2("Loading ...")))


    de$deTable <- dePipelineCaller(fCounts$filteredCounts,
                                   as.numeric(input$conditionNo),
                                   as.numeric(input$replicateNo),
                                   as.numeric(input$selectPackage),
                                   session
                                   )

    output$deTable <-
      DT::renderDataTable(
        de$deTable[, 1:(de$offset)] %>% datatable() %>%
          formatSignif(columns = c(1:de$offset), digits = 4),
        options = list(pageLength = 10)
      )

    hide_waiter()

  })

  return(de)

}


#' Differential Expression Pipeline Caller
#'
#' Function that calls the appropriate DGE pipeline
#' and provides exception handling
#'
#' @param readCounts The filtered CountTable
#' @param conditionNo The number of Conditions
#' @param replicateNo The number of Replicates
#' @param selectedPackage The package(pipeline) to be executed
#' @param session Current R session
#'
#'
#' @export
#' @return The results of the appropriate DE pipeline
dePipelineCaller <- function(filteredCounts, conditionNo, replicateNo, selectedPackage, session) {
  out <- tryCatch(
    {
      if (selectedPackage == 1) {
        out <-
          deSequence(
            filteredCounts,
            conditionNo,
            replicateNo
          )

      } else if (selectedPackage == 2) {
        out <-
          deEdgeR(
            filteredCounts,
            conditionNo,
            replicateNo
          )

      } else if (selectedPackage == 3) {
        out <-
          deALDE(
            filteredCounts,
            conditionNo,
            replicateNo
          )

      } else if (selectedPackage == 4) {
        out <-
          deLimma(
            filteredCounts,
            conditionNo,
            replicateNo
          )

      }
    },
    error=function(cond) {
      sendSweetAlert(
        session = session,
        title = "Data Format Error",
        text = "Please ensure that the data was formatted and loaded correctly",
        type = "error"
      )
      return()      # Choose a return value in case of error
    }
  )
  return(out)
}



#' DESeq2 Differential Expression Pipeline
#'
#' @param readCounts The filtered CountTable
#' @param conditionNo The number of Conditions
#' @param replicateNo The number of Replicates
#'
#' @export
#' @return DESeq2 DE pipeline results
deSequence <- function(readCounts, conditionNo, replicateNo) {
  ## 2. Format Count dataframe
  output2 <- readCounts[, -1]
  rownames(output2) <- readCounts[, 1]


  # Create Name vectors for conditions
  if (conditionNo == 2) {
    samplescondition <- c(rep("C1", replicateNo), rep("C2", replicateNo))

  } else if (conditionNo == 3) {
    samplescondition <-
      c(rep("C1", replicateNo),
        rep("C2", replicateNo),
        rep("C3", replicateNo))
  }


  # Create a coldata frame
  coldata <-
    data.frame(row.names = colnames(output2), samplescondition)


  # Initialize DESeqDataSet Object
  dds <-
    DESeqDataSetFromMatrix(
      countData = output2,
      colData = coldata,
      design =  ~ samplescondition
    )
  print(nrow(output2))



  ## 3. Run the DESeq pipeline on the DESeq object
  if (conditionNo == 2) {
    dds <- DESeq(dds)
    res <-
      results(dds, contrast = c("samplescondition", "C2", "C1"))   ## Extract A vs B contrast results

    # Convert to a data-frame and make sure it matches EdgeR output
    DEData <- data.frame(as.data.frame(res))
    print(nrow(DEData))


    DEData.matching <- DEData[, c(2, 4:6)]

    colnames(DEData.matching) <- c("logFC", "stat", "Pvalue", "FDR")

  } else{
    # ANOVA
    dds = DESeq(dds, test = "LRT", reduced =  ~ 1)

    res <- results(dds)

    AvB <-
      results(dds,
              contrast = c("samplescondition", "C2", "C1"),
              test = "Wald")


    BvC <-
      results(dds,
              contrast = c("samplescondition", "C3", "C2"),
              test = "Wald")

    head(res)
    nrow(res)


    res$log2FC_AvB <- AvB$log2FoldChange
    res$log2FC_BvC <- BvC$log2FoldChange


    DEData.matching <- res[, c(7, 8, 2:6)]
    colnames(DEData.matching) <-
      c("logFC_C2vC1",
        "logFC_C3vC2",
        "logFC_C3vC1",
        "lfcSE",
        "stat",
        "Pvalue",
        "FDR")

    DEData.matching <- data.frame(as.data.frame(DEData.matching))

  }


  ## 5. Write NormalizedCounts and MasterFile

  # Write normalised read counts
  resdata <- as.data.frame(counts(dds, normalized = TRUE))
  # write.csv(resdata, file="output/normalizedCounts.csv", quote = FALSE)

  masterFileDE <-
    merge(DEData.matching, resdata, by = "row.names", all.x = TRUE)

  # write.csv(masterFileDE, file="output/DESeq2_DE_output.csv", row.names = FALSE)

  format.data.frame(masterFileDE, digits = 4)

  countTable <- masterFileDE[, -1]
  rownames(countTable) <- masterFileDE[, 1]

  return(countTable)
}

#' EdgeR Differential Expression Pipeline
#'
#' @param readCounts The filtered CountTable
#' @param conditionNo The number of Conditions
#' @param replicateNo The number of Replicates
#'
#' @export
#' @return EdgeR DE pipeline results
deEdgeR <- function(readCounts, conditionNo, replicateNo) {
  ## 1. Load and Format Count dataframe
  countTable  <- readCounts[, -1]
  rownames(countTable) <- readCounts[, 1]


  # 2. Create condition groups
  if (conditionNo == 2) {
    samplescondition <- c(rep("C1", replicateNo), rep("C2", replicateNo))

  } else if (conditionNo == 3) {
    samplescondition = factor(c(
      rep("C1", replicateNo),
      rep("C2", replicateNo),
      rep("C3", replicateNo)
    ))
    my.contrasts <-
      makeContrasts(
        BvsA = C2 - C1,
        CvsB = C3 - C2,
        CvsA = C3 - C1,
        levels = samplescondition
      )
    design <- model.matrix( ~ 0 + samplescondition) # without intercept
    colnames(design) <- levels(samplescondition)
  }


  ## 3. Perform DE
  dge  <- DGEList(countTable, group = samplescondition)

  # Calculate normalization factors to scale the raw library sizes
  dge = calcNormFactors(dge)

  # Estimate Common and Tagwise Dispersion
  dge = estimateCommonDisp(dge)
  dge = estimateTagwiseDisp(dge)

  if (conditionNo == 2) {
    # Compute genewise exact tests for differences in the means between two groups
    de = exactTest(dge, pair = c("C1", "C2"))
    tt = topTags(de, n = nrow(dge))

  } else {
    # ANOVA
    fit <- glmFit(dge, design)
    lrt <- glmLRT(fit, contrast = my.contrasts)

    tt = topTags(lrt, n = nrow(dge))
    head(tt$table)
  }

  ## 4.Extract normalized  CPMs
  nc = cpm(dge, normalized.lib.sizes = TRUE)
  resdata <- as.data.frame(nc)


  ## 5. Write normalized counts and Master File

  # Save the normalised read counts matrix:
  # write.csv(resdata, file="output/normalizedCounts.csv", quote = FALSE)

  # Save the masterFile
  masterFileDE <- merge(tt$table, resdata, by = "row.names", all.x = TRUE)

  # write.csv(masterFileDE, file="output/EdgeR_DE_output.csv", row.names = FALSE)

  countTable <- masterFileDE[, -1]
  rownames(countTable) <- masterFileDE[, 1]

  return(countTable)
}


#' ALDEx2 Differential Expression Pipeline
#'
#' @param readCounts The filtered CountTable
#' @param conditionNo The number of Conditions
#' @param replicateNo The number of Replicates
#'
#' @export
#' @return ALDEx2 DE pipeline results (with normalized counts and logFC from Edge)
deALDE <- function(readCounts, conditionNo, replicateNo) {
  # Format Count dataframe
  countTable <- readCounts [, -1]
  rownames(countTable) <- readCounts[, 1]


  # Create Name vectors for conditions
  if (conditionNo == 2) {
    samplescondition <- c(rep("C1", replicateNo), rep("C2", replicateNo))

  } else if (conditionNo == 3) {
    samples = c(rep("C1", replicateNo),
                rep("C2", replicateNo),
                rep("C3", replicateNo))

    samplescondition = factor(c(
      rep("C1", replicateNo),
      rep("C2", replicateNo),
      rep("C3", replicateNo)
    ))
    my.contrasts <-
      makeContrasts(
        BvsA = C2 - C1,
        CvsB = C3 - C2,
        CvsA = C3 - C1,
        levels = samplescondition
      )
    design <- model.matrix( ~ 0 + samplescondition) # without intercept
    colnames(design) <- levels(samplescondition)

  }

  # Must filter to match because ALDEx2 removes all 0 rows by default
  countTable <- subset(countTable, apply(countTable, 1, mean) > 0)


  # EdgeR object, Normalization, and Dispersion
  dge  <- DGEList(countTable, group = samplescondition)
  dge = calcNormFactors(dge)
  dge = estimateCommonDisp(dge)
  dge = estimateTagwiseDisp(dge)


  ## Run the pipeline and create the object
  if (conditionNo == 2) {

    # Create object
    clr <-
      aldex.clr(
        countTable,
        samplescondition,
        mc.samples = 1,
        denom = "all",
        verbose = FALSE
      )

    # Calculate differences and Normalized counts
    resdata <-
      aldex.effect(clr,
                   verbose = TRUE,
                   include.sample.summary = TRUE)

    # perform DE with ALDEx2
    DEData <-
      aldex.ttest(clr, paired.test = FALSE, hist.plot = FALSE)

    # perform DE with EdgeR
    de = exactTest(dge, pair = c("C1", "C2"))
    tt = topTags(de, n = nrow(dge))


    ## Combine and Format MasterFileDE

    # reorder edgeR logFC to match ALDEx2
    fc <- tt$table[order(row.names(tt$table)), c(1:2)]

    # Convert to a data-frame and make sure it matches EdgeR output
    DEData.matching <- DEData[order(row.names(DEData)), c(1:2)]

    resdata <-
      resdata[order(row.names(resdata)), c(4:(3 + replicateNo * 2))]

    masterFileDE <- cbind(fc, DEData.matching, resdata)

    colnames(masterFileDE)[c(3, 4)] <- c("PValue", "FDR")


  } else if (conditionNo == 3) {
    # ALDEx2

    clr <- aldex.clr(countTable,
                     design,
                     mc.samples = 1,
                     denom = "all")

    kw.test <- aldex.glm(clr)

    # format and save KW pvalues (exclude glm/anova pvalues)
    ALDEData <- kw.test[order(row.names(kw.test)),]

    head(ALDEData)
    #access ALDEx2 Normalized Counts
    #head(cbind(clr@analysisData$s1,clr@analysisData$s2, clr@analysisData$s3))

    # EdgeR glm
    fit <- glmFit(dge, design)
    lrt <- glmLRT(fit, contrast = my.contrasts)

    tt = topTags(lrt, n = nrow(dge))
    edgeRData <- tt$table[order(row.names(tt$table)), ]

    edgeRData[, c(6:7)] <- c(ALDEData$`(Intercept) Pr(>|t|)` , ALDEData$`(Intercept) Pr(>|t|).BH`)



    ## 4.Extract normalized  CPMs
    nc = cpm(dge, normalized.lib.sizes = TRUE)
    resdata <- as.data.frame(nc)
    resdata <- resdata[order(row.names(resdata)), ]

    masterFileDE <- cbind(edgeRData, resdata)

    head(masterFileDE)
    colnames(masterFileDE)[c(6, 7)] <- c("PValue", "FDR")

  }


  ## 5. Format, Write, Return
  df <- masterFileDE
  rownames(df) <- NULL
  IDs <- rownames(masterFileDE)
  masterFileDE <- cbind(IDs, df)

  countTable <- masterFileDE[, -1]
  rownames(countTable) <- masterFileDE[, 1]

  # Write normalised read counts
  # write.csv(resdata, file="output/normalizedCounts.csv", quote = FALSE)

  # Write results table
  # write.csv(masterFileDE, file="output/ALDEx2_DE_output.csv", row.names = TRUE)

  return(countTable)
}


#' Limma Differential Expression Pipeline
#'
#' @param readCounts The filtered CountTable
#' @param conditionNo The number of Conditions
#' @param replicateNo The number of Replicates
#'
#' @export
#' @return Limma DE pipeline results (with normalized/logtransformed counts with EdgeR and voom)
deLimma <- function(readCounts, conditionNo, replicateNo) {
  ## 1. Load Data
  countTable  <- readCounts[, -1]
  rownames(countTable) <- readCounts[, 1]

  ## 2. Create condition groups
  # Create Name vectors for conditions and contrasts
  if (conditionNo == 2) {
    samplescondition <- c(rep("C1", replicateNo), rep("C2", replicateNo))
    design = model.matrix(object = ~ samplescondition)
    coef = 2

  } else if (conditionNo == 3) {
    samplescondition = factor(c(
      rep("C1", replicateNo),
      rep("C2", replicateNo),
      rep("C3", replicateNo)
    ))
    my.contrasts <-
      makeContrasts(
        BvsA = C2 - C1,
        CvsB = C3 - C2,
        CvsA = C3 - C1,
        levels = samplescondition
      )
    design <- model.matrix( ~ 0 + samplescondition) # without intercept
    colnames(design) <- levels(samplescondition)
    coef = c(1:3)
  }

  d  <- DGEList(countTable, group = samplescondition)

  # Normalize - method can be selected here
  d <- calcNormFactors(d)

  # Transform count data to log2-counts per million (logCPM)
  v <- voom(d, design = design, plot = FALSE)

  # DE
  fit <- lmFit(v, design)

  if (conditionNo > 2) {
    fit2 <- contrasts.fit(fit, my.contrasts)
    ebayes.fit <- eBayes(fit2)
  } else{
    ebayes.fit <- eBayes(fit)
  }



  #Extract a table of the top-ranked genes from a linear model fit
  tab <-
    topTable(
      ebayes.fit,
      coef = coef ,
      number = dim(ebayes.fit)[1],
      genelist = fit$genes$NAME,
      adjust = "fdr",
      sort.by = "none"
    )

  head(tab, n = 100)

  if (conditionNo == 2) {
    DEData <- tab[, c(1, 3:5)]

    colnames(DEData)[4] <- "FDR"
  } else if (conditionNo == 3) {
    DEData <- tab[, c(1:7)]
    colnames(DEData)[7] <- "FDR"

    # # extract FC between conditions (check later)
    # DEData[1] <- topTable(fit2, coef="C1", n=Inf, sort.by="none")[1]
    # DEData[2] <- topTable(fit2, coef="C2", n=Inf, sort.by="none")[1]
    # DEData[3] <- topTable(fit2, coef="C3", n=Inf, sort.by="none")[1]

  }

  IDs <- rownames(tab)
  masterFileDE <- cbind(IDs, DEData, v$E)
  rownames(masterFileDE) <- NULL

  # write.csv(masterFileDE, file="output/Limma_DE_output.csv", row.names = FALSE)

  countTable <- masterFileDE[, -1]
  rownames(countTable) <- readCounts[, 1]

  return(countTable)
}