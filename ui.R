library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(plotly)
library(tidyverse)
library(leaflet) 
library(highcharter)

fluidPage(title = "",
          
          theme = shinytheme("slate"),
          tags$style(HTML('table.dataTable tr:nth-child(n) {background-color: #2e3338 !important;}')),
           
          
          
          # CSS ----
          includeCSS("www/styles.css"),
          
          # JS ----
          shinyjs::useShinyjs(),
          
          # 1.0 HEADER ----
          div(
                class = "container-fluid",
                
                shinydashboard::box(
                      solidHeader = TRUE,
                      width = 12,
                      title = h3(
                            class = "page-header",
                            "Coronavírus COVID-19 – Casos no Brasil segundo dados oficiais das secretarias estaduais de saúde")
                )
                ),
          
          div(
                # class = "container hidden-sm hidden-xs",
                id = "favorite_container",
                
                div(
                      class = "container-fluid",
                      column(
                            width = 2,
                            style = 'padding:4px;',
                            div(
                                  class = "panel panel-default",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        style = "height: 85px;",
                                        h5(style = 'margin: -5px; color: rgb(255, 255, 255); text-align: center;', 
                                           "Total confirmado"),
                                        h1(style = "margin: 10px; font-size: 44px; font-weight: bold; color: rgb(230, 0, 0); text-align: center;", 
                                           textOutput("total_casos"))
                                        )
                            ),
                            div(
                                  class = "panel panel-default",
                                  style = "margin-top: -12px;",
                                  
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        style = "height: 423px;",
                                        h5(style = 'margin: 2px; color: #bdbdbd; text-align: center;font-weight: bold;', 
                                           "Casos confirmados por Cidade"),
                                        DT::dataTableOutput('table_confirmado', height = "340px")  
                                        
                                  )
                            ),
                            div(
                                  class = "panel panel-default",
                                  style = "margin-top: -12px;",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        style = "height: 55px;",
                                        h6(style = 'margin: -5px; color: rgb(255, 255, 255); text-align: center;', 
                                           "Última atualização em:"),
                                        h5(style = "font-weight: bold; text-align: center;", 
                                           textOutput("time_update"))
                                  )
                            )
                            
                      ),
                      column(
                            width = 6,
                            style = 'padding:4px;',
                            div(
                                  class = "panel panel-default",
                                  style = "height: 520px;",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        leafletOutput("mapa_brasil", height = 490, width = "100%")
                                  )
                            ),
                            div(
                                  class = "panel panel-default",
                                  style = "height: 56px;",
                                  style = "margin-top: -12px;",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        shinydashboard::box(
                                              style = 'overflow-y: scroll; width: 100%; height: 40px; margin-top: -10px;',
                                              width = 12,
                                              HTML("<h6 style ='line-height: 18px;'><b style='color:white'>Fontes dos dados:</b> Secretarias estaduais de saúde e Ministério da Saúde. <br>
                                              <b style='color:white'>Dados disponíveis para download:</b> GitHub: <a href='https://github.com/wcota/covid19br'>Aqui</a>. <br>
                                              <b style='color:white'>Código:</b> GitHub: <a href='https://github.com/andrepvieira/coronavirus_brasil'>Aqui</a>. <br>
                                              <b style='color:white'>Desenvolvimento:</b> <a href='https://www.linkedin.com/in/andr%C3%A9-vieira-16095557/'>André Vieira</a>.</h6>")
                                        )
                                  )
                            )
                      ),
                      column(
                            width = 2,
                            style = 'padding:4px;',
                            div(
                                  class = "panel panel-default",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        style = "height: 300px;",
                                        h5(style = 'margin: -5px; color: rgb(255, 255, 255); text-align: center;', 
                                           "Total de mortes"),
                                        h1(style = "margin: 10px; font-size: 44px; font-weight: bold; color: rgb(255, 255, 255); text-align: center;", 
                                           textOutput("total_mortes")),
                                        
                                        DT::dataTableOutput('table_mortes', height = "100%")
                                  )
                            ),
                            ),
                      column(
                            width = 2,
                            style = 'padding:4px;',
                            div(
                                  class = "panel panel-default",
                                  div(
                                        class = str_glue("panel-body bg-default text-default"),
                                        style = "height: 300px;",
                                        h5(style = 'margin: -5px; color: rgb(255, 255, 255); text-align: center;', 
                                           "Total recuperado"),
                                        h1(style = "margin: 10px; font-size: 44px; font-weight: bold; color: rgb(112, 168, 0); text-align: center;", 
                                           "--"),
                                        p("Dados não disponíveis.")
                                        # DT::dataTableOutput('table_recuperado')
                                  )
                            ),
                            ),
                      column(
                            width = 4,
                            style = "margin-top: -8px;",
                            style = 'padding:4px;',
                            div(
                                  class = "panel panel-default",
                                  style = "margin-top: -12px;",
                                  style = "height: 275px;",
                                  
                                  div(
                                        tabsetPanel(
                                              tabPanel("Acumulado",
                                                       highcharter::highchartOutput("chart_acumulado", 
                                                                                    width = "100%",
                                                                                    height = "200px")
                                              ),
                                              tabPanel("Logarítmico",
                                                       highcharter::highchartOutput("chart_acumulado_log", 
                                                                                    width = "100%",
                                                                                    height = "200px")
                                              ),
                                              
                                              tabPanel("Diário",
                                                       highcharter::highchartOutput("chart_diario", 
                                                                                    width = "100%",
                                                                                    height = "200px")
                                              )
                                        )
                                  )
                            )
                      )
                      )
          )
          
       )
