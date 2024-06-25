
library(tidyverse)

file_path <- "StormEvents_details-ftp_v1.0_d2001_c20220425.csv.gz"
data <- read_csv(file_path, compression = 'gzip')

columns <- c('BEGIN_YEARMONTH', 'EPISODE_ID', 'STATE', 'STATE_FIPS', 'CZ_NAME', 'CZ_TYPE', 'CZ_FIPS', 'EVENT_TYPE')
data <- data[columns]

data <- data %>% arrange(STATE)

data <- data %>% mutate(STATE = str_to_title(STATE), CZ_NAME = str_to_title(CZ_NAME))

data <- data %>% filter(CZ_TYPE == 'C') %>% select(-CZ_TYPE)

data <- data %>% mutate(STATE_FIPS = str_pad(STATE_FIPS, width = 3, side = "left", pad = "0"),
                        CZ_FIPS = str_pad(CZ_FIPS, width = 3, side = "left", pad = "0"))
data <- data %>% unite(FIPS, STATE_FIPS, CZ_FIPS, sep = "")

data <- data %>% rename_all(tolower)

state_info <- data.frame(
  state = state.name,
  region = state.region,
  area = state.area
)

event_counts <- data %>% count(state)

merged_data <- merge(event_counts, state_info, by = "state")

ggplot(merged_data, aes(x = reorder(state, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Number of Storm Events per State in 2001", x = "State", y = "Number of Events") +
  theme_minimal()

ggsave("storm_events_2001.png")

write_csv(merged_data, "storm_events_2001.csv")
