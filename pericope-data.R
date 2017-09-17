library(rvest)
url <- "http://www.bible-researcher.com/parallels.html"
pericopes <- read_html(url) %>%
  html_nodes(".s") %>%
  html_table() %>%
  bind_rows()

header <- pericopes %>%
  slice(1) %>%
  unlist()
names(pericopes) <- header

pericopes <- pericopes %>%
  filter(No. != "No.") %>%
  mutate_at(c("Matthew", "Mark", "Luke", "John"), stringr::str_replace_all, "[a-z]", "")
