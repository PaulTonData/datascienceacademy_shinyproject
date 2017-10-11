## ui.R ##
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "The Office"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("paper-plane")),
      menuItem("Motivation", tabName = "motivation", icon = icon("question")),
      menuItem("Tools", icon = icon("wrench"),
               menuSubItem("Lineshares",
                           tabName = "lineshares",
                           icon = icon("line-chart")),
               menuSubItem("Co-occurrence",
                           tabName = "cooccurrence",
                           icon = icon("group")),
               menuSubItem("Social Graph",
                           tabName = "socialgraph",
                           icon = icon("diamond")),               
               menuSubItem("Centrality",
                           tabName = "centrality",
                           icon = icon("bullseye"))),
      menuItem("Episodes", tabName = "episodes", icon = icon("tv")),
      menuItem("Discussion", tabName = "discussion", icon = icon("commenting")),
      menuItem("Appendix", tabName = "appendix", icon = icon("sticky-note")))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                h2("Introduction"),
                tags$ul(
                  tags$li("American comedy series on NBC"),
                  tags$li("9 seasons, ~200 episodes"),
                  tags$li("Dataset -- all spoken lines from the scripts")
                )
              )),
      tabItem(tabName = "motivation",
              fluidRow(
                h2("Why do we care?"),
                tags$ul(
                  tags$li("People love TV"),
                  tags$li("Is The Office good?"),
                  tags$li("What do people like about it?"),
                  box(plotOutput("ratings")),
                  box(plotOutput("viewership"))
                )
              )),
      tabItem(tabName = "lineshares",
              fluidRow(
                h2("Lineshares"),
                p("# lines spoken by character / # lines spoken by all characters"),
                box(plotOutput("lineshare_main"))
              )),
      tabItem(tabName = "cooccurrence",
              fluidRow(
                h2("Co-occurrence"),
                p("# times two characters appear in scenes together"),
                selectizeInput("season",
                               "Select Season",
                               1:9),
                box(plotlyOutput("heat"))                
              )),
      tabItem(tabName = "socialgraph",
              fluidRow(
                h2("Social Graph"),
                p("Network visualization of co-occurrence"),
                selectizeInput("season4",
                               "Select Season",
                               1:9),
                box(plotOutput("socialgraph"))
              )),      
      tabItem(tabName = "centrality",
              fluidRow(
                h2("Centrality"),
                p("The influence or importance of a node in the social graph."),
                selectizeInput("season2",
                               "Select Season",
                               1:9),
                box(plotOutput("centrality"))
              )),
      tabItem(tabName = "episodes",
              h2("Episode Explorer"),
              fluidRow(
                column(2,
                  selectizeInput("season3",
                                 "Select Season",
                                 1:9)),
                column(2,
                  selectizeInput("episode",
                                 "Select Episode",
                                 1:6))),
              fluidRow(
                infoBoxOutput("titleBox"),
                infoBoxOutput("ratingBox"),
                infoBoxOutput("countBox")),
              fluidRow(
                box(plotOutput("ep_lineshare")),
                box(plotOutput("ep_centrality"))),
              fluidRow(
                box(plotOutput("ep_graph")))
              ),
      tabItem(tabName = "discussion",
                fluidRow(
                  h2("Discussion"),
                  tags$ul(
                    tags$li("So what?"),
                    tags$li("Reboots, spinoffs, revivals"),
                    tags$li("NLP - Tf-Idf, sentiment analysis"),
                    tags$li("other TV shows")
                  )                  
                )
              ),
      tabItem(tabName = "appendix",
              fluidRow(
                h2("Sources"),
                tags$ul(
                  tags$li("Dataset: https://www.reddit.com/r/datasets/comments/6yt3og/every_line_from_every_episode_of_the_office_us/"),
                  tags$li("IMDB User Ratings: http://www.imdb.com/title/tt0386676/epdate"),
                  tags$li("Eigenvector Centrality: https://en.wikipedia.org/wiki/Eigenvector_centrality"),
                  tags$li("Donald Knuth's analysis of Les Miserables: http://www-cs-faculty.stanford.edu/~knuth/sgb.html"),
                  tags$li("Game of Throns Network Analysis: https://gameofnodes.wordpress.com/2015/05/06/game-of-nodes-a-social-network-analysis-of-game-of-thrones/"),
                  tags$li("Analysis of Friends: http://www.whatwouldjackandchrissydo.com/a-data-analysis-of-the-tv-sitcom-friends/"),
                  tags$li("Another analysis of Friends: https://thelittledataset.com/2015/01/20/the-one-with-all-the-quantifiable-friendships/")
                )                  
              )
            )
    )
  )
))