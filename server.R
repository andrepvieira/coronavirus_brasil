# remotes::install_github("liibre/coronabr")
# library(coronabr)
library(tidyverse)
library(zoo)
library(janitor)
library(DT)
library(leaflet)
library(rgdal)
library(highcharter)
library(sf)
library(rgeos)

# 1.0 Carrega dados ----

load("mapa_uf.rda")
load("mapa_mun.rda")
load("total_br_dia.rda")
load("acum_br_dia.rda")
load("total_uf_mortes.rda")
load("total_mun.rda")

# 2.0 Servidor da aplicacao ----

server <- function(input, output, session) {
  
  Sys.setenv(TZ = "America/Sao_Paulo")
  
  output$time_update <- renderText({return(format(Sys.time(), "%d/%m/%Y %H:%M", tz = ""))})
  
  output$total_casos <- renderText({
    
    return(
    
    total_br_dia %>% 
      dplyr::filter(row_number() == n()) %>% 
      dplyr::pull(totalCases)
    
    )
    
    })
  
  output$total_mortes <- renderText({
    
    return(
    total_uf_mortes %>% 
      dplyr::filter(state == "TOTAL") %>% 
      dplyr::pull(deaths)
    )
    
    })
  
  output$chart_diario <- highcharter::renderHighchart({
    
    hchart(acum_br_dia,
           type = "line", 
           hcaes(date, newCases),
           color = "rgb(230, 0, 0)") %>% 
      hc_xAxis(type = "datetime", dateTimeLabelFormats = list(day = '%Y-%m-%d')) %>% 
      hc_yAxis(title = list(text = "")) %>%
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Casos confirmados por dia no Brasil",
               style = list(color = "#bdbdbd", useHTML = TRUE, fontSize = 14)) %>% 
              hc_credits(enabled = TRUE, 
                         text = paste0(HTML("Fonte: Secretarias Estaduais de Saúde, Ministério da Saúde.")),
                         href = "https://www.saude.gov.br/coronavirus",
                         margin = 20,
                         style = list(fontSize = "10px", color = "#bdbdbd")) %>% 
              hc_responsive() %>% 
              hc_plotOptions(
                    series = list(
                          marker = list(enabled = TRUE),
                          name = "Casos confirmados"))
    
  })
  
  output$chart_acumulado <- highcharter::renderHighchart({
        
        hchart(total_br_dia,
               type = "line", 
               hcaes(date, totalCases),
               color = "rgb(230, 0, 0)") %>% 
              hc_xAxis(type = "datetime", dateTimeLabelFormats = list(day = '%Y-%m-%d')) %>% 
              hc_yAxis(title = list(text = "")) %>%
              hc_xAxis(title = list(text = "")) %>% 
              hc_title(text = "Casos acumulados no Brasil",
                       style = list(color = "#bdbdbd", useHTML = TRUE, fontSize = 14)) %>% 
              hc_credits(enabled = TRUE, 
                         text = paste0(HTML("Fonte: Secretarias Estaduais de Saúde, Ministério da Saúde.")),
                         href = "https://www.saude.gov.br/coronavirus",
                         margin = 20,
                         style = list(fontSize = "10px", color = "#bdbdbd")) %>% 
              hc_responsive() %>% 
              hc_plotOptions(
                    series = list(
                          marker = list(enabled = TRUE),
                          name = "Casos confirmados"))
        
  })
  
  output$chart_acumulado_log <- highcharter::renderHighchart({
        
        hchart(total_br_dia,
               type = "line", 
               hcaes(date, log(totalCases)),
               color = "rgb(230, 0, 0)") %>%
              hc_xAxis(type = "datetime", dateTimeLabelFormats = list(day = '%Y-%m-%d')) %>% 
              hc_yAxis(title = list(text = "")) %>%
              hc_xAxis(title = list(text = "")) %>% 
              hc_title(text = "Logaritmo dos casos acumulados no Brasil",
                       style = list(color = "#bdbdbd", useHTML = TRUE, fontSize = 14)) %>% 
              hc_credits(enabled = TRUE, 
                         text = paste0(HTML("Fonte: Secretarias Estaduais de Saúde, Ministério da Saúde.")),
                         href = "https://www.saude.gov.br/coronavirus",
                         margin = 20,
                         style = list(fontSize = "10px", color = "#bdbdbd")) %>% 
              hc_responsive() %>% 
              hc_plotOptions(
                    series = list(
                          marker = list(enabled = TRUE),
                          name = "Casos confirmados"))
        
  })
  
  output$table_confirmado <- DT::renderDataTable({
        datatable(total_mun %>% rename(c = totalCases) %>% select(2, 1), 
                  rownames = F,  extensions = 'Scroller', 
                  colnames = c("", ""),
                  width = "100%",
                  height = "340px",
                  options = list(pageLength = 10, dom = 't', 
                                 scrollY = 340,
                                 scroller = TRUE,
                                 scrollX = T,
                                 deferRender = F,
                                 autoWidth = F,
                                 ordering=F,
                                 columnDefs = list(list(width = '5px', targets = "_all",
                                                        className = 'dt-left')))
        ) %>% 
              DT::formatStyle(columns = c(2), fontSize = '90%') %>% 
              DT::formatStyle(columns = c(1), fontSize = '110%') %>% 
              DT::formatStyle(columns = c(1), Color = 'red', fontWeight = "bold")
        
  })
  
  output$table_mortes <- DT::renderDataTable({
        datatable(total_uf_mortes %>% 
                    arrange(desc(deaths)) %>% 
                    select(2, 1) %>% 
                    filter(!state == "TOTAL"), 
                  rownames = F,  
                  extensions = 'Scroller', 
                  colnames = c("", ""),
                  width = "100%",
                  options = list(pageLength = 5, 
                                 dom = 't', 
                                 scrollY = 180,
                                 scroller = TRUE,
                                 scrollX = T,
                                 deferRender = F,
                                 autoWidth = F,
                                 ordering = F,
                                 columnDefs = list(list(width = '5px', targets = "_all",
                                                        className = 'dt-left')))
        ) %>% 
              DT::formatStyle(columns = c(1, 2), fontSize = '90%') %>% 
              DT::formatStyle(columns = c(1), Color = 'white', fontWeight = "bold")
        
  })
  
  output$table_recuperado <- DT::renderDataTable({
        datatable(data_recuperados, 
                  rownames = F,  extensions = 'Scroller', 
                  colnames = c("", ""),
                  width = "100%",
                  options = list(pageLength = 10, dom = 't', 
                                 scrollY = 300,
                                 scroller = TRUE,
                                 scrollX = T,
                                 deferRender = F,
                                 autoWidth = F,
                                 ordering=F,
                                 columnDefs = list(list(width = '5px', targets = "_all",
                                                        className = 'dt-left')))
        ) %>% 
              DT::formatStyle(columns = c(1, 2), fontSize = '90%') %>% 
              DT::formatStyle(columns = c(1), Color = 'white', fontWeight = "bold")
        
  })
  
  output$mapa_brasil <- renderLeaflet({ 
        
        pall <- colorBin("YlOrRd", 
                         domain = mapa_mun_simplified@data$totalCases,
                         bins = c(0, 11, 25, 50, 500))
        
        labels <- sprintf(
              "<b>Cidade:</b> %s <br>
                        <b>Casos:</b> %g",
              pull(distinct(select(mapa_mun_simplified@data, city))),
              mapa_mun_simplified@data$totalCases
              ) %>% 
              lapply(htmltools::HTML)
        
        leaflet() %>% 
              setView(lng = -55.1734835, lat = -14.0470971, zoom = 4) %>% 
              addTiles(layerId = "darkmatter",
                       options = providerTileOptions(minZoom = 4, maxZoom = 15)) %>% 
              addProviderTiles(provider = "CartoDB.DarkMatter", 
                               group = "Dark",
                               options = providerTileOptions(minZoom = 4, 
                                                             maxZoom = 15)) %>% 
              addPolygons(data = mapa_uf_simplified, 
                          color = "white", 
                          weight = 1, 
                          smoothFactor = 0.5,
                          opacity = 1.5, 
                          fillOpacity = 0.2, 
                          dashArray = "3", 
                          label = ~NM_ESTADO,
                          highlightOptions = highlightOptions(
                                color = "white",
                                weight = 1,
                                dashArray = "",
                                fillOpacity = 0.6
                                ),
                          popup = ~NM_ESTADO,
                          ) %>% 
              addCircleMarkers(
                    data = mapa_mun_simplified,
                    lng = ~lng, 
                    lat = ~lat,
                    radius = ~sqrt(totalCases)/2,
                    color = ~pall(totalCases),
                    label = labels,
                    stroke = FALSE, 
                    fillOpacity = 0.5
              )
         })
  }