% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app-run.R
\name{app-run}
\alias{app-run}
\alias{appRestockML}
\alias{app_ui}
\alias{app_server}
\alias{new_waiter}
\alias{waiter_html}
\alias{update_stat_cards}
\alias{update_model_params}
\alias{run_model}
\title{Run App}
\usage{
appRestockML(...)

app_ui()

app_server()

new_waiter(session = getDefaultReactiveDomain())

waiter_html(msg)

update_stat_cards(index, session = getDefaultReactiveDomain())

update_model_params(args, session = getDefaultReactiveDomain())

run_model(w, oid, sid, index, ml_args, session = getDefaultReactiveDomain())
}
\arguments{
\item{...}{additional args for runApp or options to pass to shinyApp}

\item{session}{shiny session object}

\item{msg}{message for waiter progress}

\item{index}{table of filtered rows from app}

\item{args}{Values to update model parameters on UI}

\item{w}{waiter object from app}

\item{oid}{org uuid from app}

\item{sid}{store uuid from app}

\item{ml_args}{list of ml args from app}
}
\description{
Functions to run the package shiny app
}
\section{Functions}{
\itemize{
\item \code{appRestockML()}: returns app object for subsequent execution

\item \code{app_ui()}: UI function for app

\item \code{app_server()}: server function for app

\item \code{new_waiter()}: create a new waiter object

\item \code{waiter_html()}: get html for waiter progress page

\item \code{update_stat_cards()}: update stats on filter

\item \code{update_model_params()}: update ui sliders containing model params

\item \code{run_model()}: function that's executed on user action to run model

}}
