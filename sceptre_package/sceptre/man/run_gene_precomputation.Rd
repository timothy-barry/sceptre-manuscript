% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/resampling_method_functions.R
\name{run_gene_precomputation}
\alias{run_gene_precomputation}
\title{Run gene precomputation}
\usage{
run_gene_precomputation(expressions, covariate_matrix, gene_precomp_size)
}
\arguments{
\item{expressions}{the vector of gene expressions}

\item{covariate_matrix}{the cell-specific covariate matrix}

\item{gene_precomp_size}{the pre-computed size parameter (NULL if none)}
}
\value{
a named list containing two items: offsets and size.
}
\description{
This function runs the precomputation for a given gene. In particlar, it fits an NB regression of expression against covariates. The estimate of theta (i.e., the NB size parameter) is obtained from glm.nb function. This is sensible as, under the null hypothesis, the NB model without the gRNA indicator is true. Offsets are obtained by log-transforming the fitted values.
}
