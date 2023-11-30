FROM rocker/r-ubuntu:20.04

EXPOSE 3939

## Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    libssh2-1-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

## Install cran dependencies for app specified in DESC file
RUN install.r remotes
COPY DESCRIPTION .
RUN Rscript -e "remotes::install_deps()"
RUN rm -f DESCRIPTION

## Specify shiny runtime options in Rprofile
RUN echo "local(options(shiny.port = 3939, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

## Set GH Personal Access Token and Install private depends
ENV GITHUB_PAT="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"

RUN Rscript -e 'remotes::install_github("r-data-science/rpgconn")'
RUN Rscript -e 'remotes::install_github("r-data-science/rdstools")'
RUN Rscript -e 'remotes::install_github("r-data-science/rdscore")'
RUN Rscript -e 'remotes::install_github("r-data-science/rdsapps")'

## Set envvar used by package:rpgconn to connect to the appdata database
ENV RPG_CONN_STRING="user=cabbage;password=cabbage;host=host.docker.internal;port=5432;dbname=integrated"

## Add non-root system user that runs the app
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
#RUN echo "shiny::shinyApp(rdsapps:::ui_prm(), rdsapps:::server_prm())" > app.R

## Set permissions, switch user, and run the app
RUN chown app:app -R /home/app
USER app
CMD ["R", "-e", "rdsapps::runExplorePRM()"]
#CMD ["R", "-e", "shiny::runApp('/home/app')"]

