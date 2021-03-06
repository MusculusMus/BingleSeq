% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sc_footprintTab.R
\name{sc_dorothea_viper}
\alias{sc_dorothea_viper}
\title{Dorothea-Viper TF Activity estimation}
\usage{
sc_dorothea_viper(s_object, tf_num, regulon)
}
\arguments{
\item{s_object}{Seurat object with clustering results}

\item{tf_num}{Minimum Regulon size}

\item{regulon}{dorothea regulon (human or mouse)}
}
\value{
Returns a table with TF activity scores ready for display
}
\description{
Dorothea-Viper TF Activity estimation
}
\keyword{internal}
