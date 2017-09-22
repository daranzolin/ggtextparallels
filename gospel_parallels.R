library(rvest)
library(tidyverse)
urls <- c("http://www.bible-researcher.com/parallels.html",
          "http://www.bible-researcher.com/parallels2.html",
          "http://www.bible-researcher.com/parallels3.html")

gospel_parallels <- urls %>%
  map(read_html) %>%
  map(html_nodes, ".s") %>%
  map(html_table) %>%
  map_df(bind_rows)

header <- gospel_parallels %>%
  slice(1) %>%
  unlist()
names(gospel_parallels) <- header

gospel_parallels <- gospel_parallels %>%
  filter(No. != "No.") %>%
  mutate_at(c("Matthew", "Mark", "Luke", "John"), stringr::str_replace_all, "[a-z]", "")

# Need to do some additional manual cleaning
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


devtools::use_data(gospel_parallels, biblesearch_versions, internal = FALSE, overwrite = TRUE)
internal_gospel_parallels <- gospel_parallels
internal_biblesearch_versions <- biblesearch_versions
devtools::use_data(internal_gospel_parallels, internal_biblesearch_versions, perseus_catalog, internal = TRUE, overwrite = TRUE)
