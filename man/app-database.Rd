% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app-database.R
\name{app-database}
\alias{app-database}
\alias{db_app_index_anon}
\alias{db_load_params}
\alias{db_save_params}
\title{Interface with Database}
\usage{
db_app_index_anon()

db_load_params(oid, sid)

db_save_params(oid, sid, args)
}
\arguments{
\item{oid}{org id}

\item{sid}{store id}

\item{args}{args to send to the db}
}
\description{
Interface with Database
}
\section{Functions}{
\itemize{
\item \code{db_app_index_anon()}: get index of locations with anonomized names

\item \code{db_load_params()}: get default model params by location from the db

\item \code{db_save_params()}: save custom model params by location to the db

}}
