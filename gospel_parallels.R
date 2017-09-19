library(rvest)
library(tidyverse)
url <- "http://www.bible-researcher.com/parallels.html"
gospel_parallels <- read_html(url) %>%
  html_nodes(".s") %>%
  html_table() %>%
  bind_rows()

header <- gospel_parallels %>%
  slice(1) %>%
  unlist()
names(gospel_parallels) <- header

gospel_parallels <- gospel_parallels %>%
  filter(No. != "No.") %>%
  mutate_at(c("Matthew", "Mark", "Luke", "John"), stringr::str_replace_all, "[a-z]", "")

gospel_parallels$Matthew[48] <- "4.24-25"
gospel_parallels$Luke[59] <- "6.27-28"
gospel_parallels$Matthew[73] <- "7.15-20"
gospel_parallels$Luke[74] <- "13.25-27"
gospel_parallels$Matthew[82] <- "7.15-20"
gospel_parallels$Luke[85] <- "7.1-10"
gospel_parallels$Matthew[96] <- "9.27-31"
gospel_parallels$Matthew[97] <- "9.32-34"
gospel_parallels$Mark[98] <- "6.6"
gospel_parallels$Luke[98] <- "8.1"
gospel_parallels$Mark[99] <- "3.13-19"
gospel_parallels$Luke[99] <- "6.12-16"
gospel_parallels$Matthew[100] <- "10.17-25"



devtools::use_data(gospel_parallels)
internal_gospel_parallels <- gospel_parallels
devtools::use_data(internal_gospel_parallels, internal = TRUE)
