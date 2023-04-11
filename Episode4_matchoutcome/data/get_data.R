# Script to generate the data used for Episode 3
library(fitzRoy)
library(lubridate)
library(stringr)
library(readxl)
library(dplyr)
library(ggplot2)
library(zoo)

# Use the fitzRoy back - limit to 2014 to 2019 because pre 2014 no data
# Post 2019, affected by covid.
get_season_ladder <- function(season){
  print(season)
  data <- purrr::map_df(1:23,function(x) fetch_ladder(season = season,round = x))
  return(data)
}

get_season_results <- function(season){
  print(season)
  data <- purrr::map_df(1:23,function(x) fetch_results(season = season,round_number = x))
  return(data)
}

ladder_data <- purrr::map_df(2014:2019,get_season_ladder)
results_data <-purrr::map_df(2014:2019,get_season_results)

# Result
home_win <- results_data %>%
  mutate(season = year(match.date)) %>%
  mutate(home_win = ifelse(homeTeamScore.matchScore.totalScore > awayTeamScore.matchScore.totalScore,1,0)) %>%
  select(season,
         match.name,
         round.roundNumber,
         home_win)


# Current ladder position
ladder_data_to_join <- ladder_data %>%
  mutate(round_before = round_number + 1) %>%
  select(team.providerId,
         season,
         position,
         round_before) %>%
  mutate(season = ifelse(round_before==24,season + 1, season),
         round_before= ifelse(round_before==24,1, round_before))

# winning streak
winning_streak <-ladder_data %>%
  mutate(round_before = round_number + 1) %>%
  select(team.providerId,
         season,
         round_before,
         lastFiveGamesRecord.wins) %>%
  mutate(season = ifelse(round_before==24,season + 1, season),
         round_before= ifelse(round_before==24,1, round_before))

# Rank of offense
rank_offense <- ladder_data %>%
  mutate(round_before = round_number + 1) %>%
  group_by(team.providerId) %>%
  arrange(season,round_number) %>%
  mutate(points_scored_that_match = ifelse(round_number ==1 , pointsFor, pointsFor - lag(pointsFor,1))) %>%
  group_by(team.providerId) %>%
  mutate(rolling_ave_points_scored = zoo::rollmean(points_scored_that_match,
                                                   k = 5,
                                                   fill = points_scored_that_match,
                                                   align = "right")) %>%
  group_by(season,round_number) %>%
  mutate(rank_offense = rank(rolling_ave_points_scored) ) %>%
  ungroup() %>%
  select(team.providerId,
         season,
         rank_offense,
         round_before)%>%
  mutate(season = ifelse(round_before==24,season + 1, season),
         round_before= ifelse(round_before==24,1, round_before))

# Rank of defense
rank_defense <- ladder_data %>%
  mutate(round_before = round_number + 1) %>%
  group_by(team.providerId) %>%
  arrange(season,round_number) %>%
  mutate(points_scored_that_match = ifelse(round_number ==1 , pointsAgainst, pointsAgainst - lag(pointsAgainst,1))) %>%
  group_by(team.providerId) %>%
  mutate(rolling_ave_points_scored = zoo::rollmean(points_scored_that_match,
                                                   k = 5,
                                                   fill = points_scored_that_match,
                                                   align = "right")) %>%
  group_by(season,round_number) %>%
  mutate(rank_defense = rank(rolling_ave_points_scored) ) %>%
  ungroup() %>%
  select(team.providerId,
         season,
         rank_defense,
         round_before)%>%
  mutate(season = ifelse(round_before==24,season + 1, season),
         round_before= ifelse(round_before==24,1, round_before))



left_join_on_home_and_away<-function(x,y,column_name){
   x %>%
  left_join(y,
            by = c("season"= "season",
                   "round.roundNumber"="round_before",
                   "match.homeTeamId" = "team.providerId")) %>%
    rename_with(~paste0(column_name,"_home") , column_name) %>%
    left_join(y,
              by = c("season"= "season",
                     "round.roundNumber"="round_before",
                     "match.awayTeamId" = "team.providerId")) %>%
    rename_with(~paste0(column_name,"_away") , column_name) %>%
    return()
}

final_results<- results_data %>%
  mutate(season = year(match.date)) %>%
  select(
    season,
    round.roundNumber,
    match.name,
    match.homeTeamId,
    match.awayTeamId
  ) %>%
  left_join_on_home_and_away(ladder_data_to_join,"position")%>%
  left_join_on_home_and_away(rank_defense,"rank_defense") %>%
  left_join_on_home_and_away(rank_offense,"rank_offense") %>%
  left_join_on_home_and_away(winning_streak,"lastFiveGamesRecord.wins") %>%
  mutate(del_position =-(position_home - position_away)/18,
         del_defense = -(rank_defense_home - rank_defense_away)/18,
         del_offense = (rank_offense_home - rank_offense_away)/18,
         del_winning = lastFiveGamesRecord.wins_home - lastFiveGamesRecord.wins_away) %>%
  select(    season,
             round.roundNumber,
             match.name,
             match.homeTeamId,
             match.awayTeamId,
             starts_with("del"))%>%
  ungroup() %>%
  left_join(home_win,
            by = c("season","round.roundNumber","match.name") )

final_results %>% write.csv(file.path('Episode4','data',"match_data.csv"),row.names = F)

# Doing a logistic regression in R
train_set = final_results %>% filter(season <2019)
test_set = final_results %>% filter(season ==2019)
mod <- glm(home_win ~ del_position+
            del_defense +
            del_offense +
            del_winning,
          family=binomial(link='logit'),
          data = train_set)

summary(mod)


# Print the oosample accuracy of the model
fitted.results <- predict(mod,test_set,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)
misClasificError <- mean(fitted.results != test_set$home_win,na.rm = T)
print(paste('Accuracy',1-misClasificError))

