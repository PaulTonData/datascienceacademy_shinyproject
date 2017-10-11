## server.R ##
library(plotly)

shinyServer(function(input, output, session){
  observe({
    eps <- ep_ct %>% filter(season == input$season3)
    updateSelectizeInput(
      session, "episode",
      choices = eps$episode,
      selected = 1)
  })  
  
  main <- 
    ggplot(top_lineshares, aes(x=reorder(speaker, -lineshares), y=lineshares)) +
    geom_bar(aes(fill=speaker), stat="identity") +
    facet_wrap(~season, drop=T, scales="free_x") +
    guides(fill=F) +
    xlab("speaker")

  viewership <- 
    ggplot(ratings, aes(x=seq_along(count), y=count)) + 
    geom_line(aes(color=season)) +
    xlab("episode") +
    coord_cartesian(ylim = c(0, 6000)) 
  
  rating_plot <- 
    ggplot(ratings, aes(x=seq_along(rating), y=rating)) + 
    geom_line(aes(color=season)) +
    xlab("episode") + 
    coord_cartesian(ylim = c(4, 10))
    
  output$plot1 <- renderPlot({plot(1:10)})
  output$lineshare_main <- renderPlot({main})
  output$heat <- renderPlotly({
    adjm <- get_adjm(edges_season, nodes_season, input$season)
    heat <- plot_ly(x= rownames(adjm), y= colnames(adjm), z=adjm, type="heatmap", colorscale="Hot")
    heat
  })
  output$socialgraph <- renderPlot({
    relationships <- get_graph(edges_season, nodes_season, input$season4)
    plot(relationships)
  })
  output$centrality <- renderPlot({
    cent <- get_centrality(edges_season, nodes_season, input$season2)
    ggplot(cent, aes(x=reorder(rowname, -value), y=value)) + 
      geom_bar(aes(fill=rowname), stat="identity") +
      xlab("speaker") +
      ylab("centrality")
  })
  output$ratings <- renderPlot(rating_plot)
  output$viewership <- renderPlot(viewership)

  output$titleBox <- renderInfoBox({
    ep <- ratings %>% filter(season == input$season3 & episode == input$episode)
    infoBox("Title", ep$title, icon=icon("list"), fill=T)
  })
  output$ratingBox <- renderInfoBox({
    ep <- ratings %>% filter(season == input$season3 & episode == input$episode)
    season_rating <- ratings_avgs %>% filter(season == input$season3)
    infoBox("Rating", paste(ep$rating, round(season_rating$rating, 2), sep="/"), icon=icon("thumbs-up", lib="glyphicon"), fill=T, color="purple")
  })
  output$countBox <- renderInfoBox({
    ep <- ratings %>% filter(season == input$season3 & episode == input$episode)
    season_count <- ratings_avgs %>% filter(season == input$season3)
    infoBox("Count", paste(ep$count, round(season_count$count, 1), sep="/"), fill=T, color="yellow")
  })
  
  output$ep_lineshare <- renderPlot({
    ep_shares <- 
      ep_speaker_ct %>% 
      filter(season == input$season3 & episode == input$episode) %>%
      arrange(-lineshares) %>%
      top_n(10)
    
    ggplot(ep_shares, aes(x=reorder(speaker, -lineshares), y = lineshares)) + 
      geom_bar(aes(fill=speaker), stat="identity") +
      xlab("speaker")
  })
  output$ep_centrality <- renderPlot({
    cent <- get_centrality(edges_ep, nodes_ep, input$season3, input$episode)
    ggplot(cent, aes(x=reorder(rowname, -value), y=value)) + 
      geom_bar(aes(fill=rowname), stat="identity") +
      xlab("speaker") +
      ylab("centrality")
  })
  output$ep_graph <- renderPlot({
    relationships <- get_graph(edges_ep, nodes_ep, input$season3, input$episode)
    plot(relationships)
  })
})