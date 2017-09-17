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
devtools::use_data(gospel_parallels)
internal_gospel_parallels <- gospel_parallels
devtools::use_data(internal_gospel_parallels, internal = TRUE)
