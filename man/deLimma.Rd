% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bulk_deDataTab.R
\name{deLimma}
\alias{deLimma}
\title{Limma Differential Expression Pipeline}
\usage{
deLimma(readCounts, meta, normMethod, useBatch)
}
\arguments{
\item{readCounts}{The filtered CountTable}

\item{meta}{Metadata table}

\item{useBatch}{If FALSE reasigns IDs to row.names}

\item{fitType}{The test method to be used}
}
\value{
Returns limma DE pipeline results
}
\description{
Limma Differential Expression Pipeline
}
