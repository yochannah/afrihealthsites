#' compare healthsite points from different sources for a country
#'
#' main aim to plot map comparing different sources
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasources vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param plotshow whether to show the plot, otherwiser just return plot object
#' @param plotcex sizes of symbols for each source default=c(6,3), helps view symbol overlap
#' @param col.regions list of two colour palettes to pass to mapview
#' @param plotlegend whether to add legend to mapview plot
#' @param hs_amenity filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#' @param canvas mapview plotting option, TRUE by default for better performance with larger data
#' @param plotstaticlabels whether to add mapview static labels
#'
#' @examples
#'
#' #compare_hs_sources("nigeria", datasources=c('who', 'healthsites'), plot='mapview')
#' #compare_hs_sources(c('malawi','zambia'))
#'
#' @return \code{sf}
#' @export
#'
compare_hs_sources <- function(country,
                            datasources = c('healthsites','who'), #'hdx',
                            plot = 'mapview',
                            plotshow = TRUE,
                            plotcex = c(6,3),
                            col.regions = list(RColorBrewer::brewer.pal(5, "YlGn"), RColorBrewer::brewer.pal(5, "BuPu")),
                            plotlegend = TRUE,
                            hs_amenity = 'all',
                            canvas = TRUE,
                            plotstaticlabels=FALSE) {

  sf1 <- afrihealthsites(country, datasource = datasources[1], plot=FALSE, hs_amenity=hs_amenity)
  sf2 <- afrihealthsites(country, datasource = datasources[2], plot=FALSE, hs_amenity=hs_amenity)


  #TODO add a plot='sf' option


  if (plot == 'mapview')
  {
    set_zcol <- function(datasource) {
      zcol <- switch(datasource,
                      'healthsites' = 'amenity',
                      'healthsites_live' = 'amenity',
                      'hdx' = 'amenity',
                      'who'= "Facility type",
                      NULL)
      zcol
    }

    set_labcol <- function(datasource) {
      labcol <- switch(datasource,
                     'healthsites' = 'name',
                     'healthsites_live' = 'name',
                     'hdx' = 'name',
                     'who'= "Facility name",
                     NULL)
      labcol
    }

    zcol1 <- set_zcol(datasources[1])
    zcol2 <- set_zcol(datasources[2])

    labcol1 <- set_labcol(datasources[1])
    labcol2 <- set_labcol(datasources[2])


    #add datasources separately to cope when one is missing or empty
    if (!is.null(sf1) & isTRUE(nrow(sf1) > 0))
    {
      mapplot <- mapview::mapview(sf1,
                                  zcol=zcol1,
                                  label=paste(sf1[[zcol1]],sf1[[labcol1]]),
                                  cex=plotcex[1],
                                  col.regions=col.regions[[1]],
                                  layer.name=datasources[1],
                                  legend=plotlegend,
                                  canvas=canvas)

      #option to add static labels
      #still trialling, not quite working
      #TODO try to fix this
      if (plotstaticlabels)
      {
        lopt = labelOptions(noHide = TRUE,
                            direction = 'bottom',
                            textOnly = FALSE, offset=c(10,10))
        #this causes an error later, non numeric arg to binary operator
        mapplot <- mapview::addStaticLabels(mapplot, label=paste(sf1[[zcol1]],sf1[[labcol1]]), labelOptions = lopt)
      }

    }


    if (!is.null(sf2)  & isTRUE(nrow(sf2) > 0))
    {
      if (!is.null(sf1) & isTRUE(nrow(sf1) > 0))
      {
        mapplot <- mapplot + mapview::mapview(sf2,
                                          zcol=zcol2,
                                          label=paste(sf2[[zcol2]],sf2[[labcol2]]),
                                          cex=plotcex[2],
                                          col.regions=col.regions[[2]],
                                          layer.name=datasources[2],
                                          legend=plotlegend,
                                          canvas=canvas )
      } else {
        #if there's no sf1 then start the plot with sf2
        mapplot <- mapview::mapview(sf2,
                                     zcol=zcol2,
                                     label=paste(sf2[[zcol2]],sf2[[labcol2]]),
                                     cex=plotcex[2],
                                     col.regions=col.regions[[2]],
                                     layer.name=datasources[2],
                                     legend=plotlegend,
                                     canvas=canvas )

      }
    }
  }


  if (plotshow) print(mapplot)

  invisible(mapplot)

  # of course can't do the below because they have different numbers columns
  # TODO I could subset just the geometry and zcol columns (and maybe name) and then rbind to return
  #add source column, rbind and return in case it is useful
  # sf1$datasource <- datasources[1]
  # sf2$datasource <- datasources[2]
  #
  # sfboth <- rbind(sf1,sf2)
  # invisible(sfboth)
}
