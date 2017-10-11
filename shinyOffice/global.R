library(dplyr)
library(ggplot2)
library(plotly)

lines <- read.csv("office.csv", stringsAsFactors = F, header=T)
deleted <- lines %>% filter(deleted == TRUE)
lines <- lines %>% filter(deleted == FALSE)

top50 <- lines %>% group_by(speaker) %>% summarise(count = n()) %>% arrange(-count) %>% top_n(50)

season_ct <- lines %>% group_by(season) %>% summarise(count=n())
speaker_ct <- lines %>% group_by(season, speaker) %>% summarise(count=n())

ep_ct <- lines %>% group_by(season, episode) %>% summarise(count=n())
ep_speaker_ct <- lines %>% group_by(season, episode, speaker) %>% summarise(count=n())

library(data.table)
speaker_ct <- as.data.table(speaker_ct)
speaker_ct[, lineshares := count/sum(count),by=c("season")]
setorder(speaker_ct, season, -lineshares)
top_lineshares <- speaker_ct %>% group_by(season) %>% top_n(5)

ep_speaker_ct <- as.data.table(ep_speaker_ct)
ep_speaker_ct[, lineshares := count/sum(count), by=c("season", "episode")]
setorder(ep_speaker_ct, season, episode, -lineshares)

nodes_season <- 
  speaker_ct %>% 
  group_by(season) %>% 
  top_n(10) %>%
  select(season = season, id = speaker)

top_speakers <- unique(nodes_season$id)
#lines_top <- lines %>% filter(speaker %in% top_speakers)
lines_top <- lines

chars_in_scene <-
  lines_top %>% 
  group_by(season, episode, scene, speaker) %>% 
  summarise(count = n()) %>%
  select(-count)

people_per_scene <-
  chars_in_scene %>%
  group_by(season, episode, scene) %>%
  summarise(count = n())

small_groups <-
  people_per_scene %>% 
  filter(count %in% c(2,3,4)) %>%
  left_join(chars_in_scene, by=c("season" = "season", "episode" = "episode", "scene" = "scene")) %>%
  select(-count)

get_pairs <- function(x) {
  tbl_df(t(combn(x, 2)))
}

edges_season <-
  small_groups %>%
  group_by(season, episode, scene) %>%
  do(get_pairs(.$speaker)) %>%
  group_by(season, V1, V2) %>%
  summarise(count = n()) %>%
  arrange(season, -count)

library(igraph)
get_graph <- function(links_list, nodes_list, s, e=0){
  links <- links_list %>% filter(season == s)
  if(e == 0){
    links <- links %>% ungroup() %>% select(-season)
  } else {
    links <- links %>% filter(episode == e) %>% ungroup() %>% select(-season, -episode)
  }
  nodes <- nodes_list %>% filter(season == s)
  if(e == 0){
    nodes <- nodes %>% ungroup() %>% select(-season)
  } else {
    nodes <- nodes %>% filter(episode == e) %>% ungroup() %>% select(-season, -episode)
  }
  links <- links %>% filter(V1 %in% nodes$id & V2 %in% nodes$id)
  relationships <- graph_from_data_frame(d=links, vertices = nodes, directed = F)
  relationships
}

get_adjm <- function(links_list, nodes_list, s, e=0){
  relationships <- get_graph(links_list, nodes_list, s, e)
  adjm <- get.adjacency(relationships, attr="count", sparse=F)
  adjm
}

get_centrality <- function(links_list, nodes_list, s, e=0){
  relationships <- get_graph(links_list, nodes_list, s, e)
  cent <- eigen_centrality(relationships, weights = E(relationships)$count)
  tbl_df(cent$vector) %>% 
    tibble::rownames_to_column() %>% 
    mutate(season = s) %>%
    arrange(-value)
}

nodes_ep <- 
  ep_speaker_ct %>% 
  group_by(season, episode) %>% 
  top_n(10) %>%
  select(season = season, episode = episode, id = speaker)

edges_ep <-
  small_groups %>%
  group_by(season, episode, scene) %>%
  do(get_pairs(.$speaker)) %>%
  group_by(season, episode, V1, V2) %>%
  summarise(count = n()) %>%
  arrange(season, episode, -count)

library(tidyr)
ratings <- read.table("ratings.data", header=F, sep="", stringsAsFactors=F, colClasses=c("character", "character", "numeric", "character"), col.names=c("ep", "title", "rating", "count"))
ratings <- separate(ratings, ep, c("season", "episode"), "[.]")
ratings <- ratings %>% group_by(season) %>% mutate(episode = seq_along(season))
ratings$count <- as.numeric(gsub(",", "", ratings$count))