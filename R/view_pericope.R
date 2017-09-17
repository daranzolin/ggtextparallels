view_pericope <- function(pericope_no) {

  p_df <- get_pericope(pericope_no) %>%
    split(.$book) %>%
    map_df(function(x) {
      tibble(
        book = x$book,
        index = x$index,
        text = split_every(x$text, 9, " ")
      )
    }) %>%
    group_by(book) %>%
    mutate(x = 1,
           y = rev(row_number()))

  titles <- get_plot_titles(pericope_no)

  max_col <- max(p_df$y)

  p_df %>%
    split(.$book) %>%
    map_df(function(x) {
      m <- max(x$y)
      diff <- max_col - m
      mutate(x, new_y = y + diff)
    }) %>%
    ungroup() %>%
    mutate(book = factor(book, levels = c("Matthew", "Mark", "Luke", "John"))) %>%
    ggplot(aes(x = x, y = new_y)) +
    geom_text(aes(label = text, hjust = 0)) +
    labs(title = titles$title,
         subtitle = titles$subtitle) +
    xlim(1, 5) +
    facet_wrap(~book) +
    theme_ggpericope()

}

get_pericope <- function(pericope_no) {

  pericopes %>%
    filter(No. == pericope_no) %>%
    gather(book, text, -Pericope) %>%
    select(-Pericope) %>%
    filter(text != "",
           book != "No.") %>%
    left_join(perseus_catalog, by = c("book" = "label")) %>%
    filter(language == "eng") %>%
    select(book, text, urn) %>%
    rowwise() %>%
    mutate(index = reformat_index(text),
           text_url = map2(urn, index, get_text_url),
           text = extract_text(text_url)) %>%
    ungroup() %>%
    select(book, index, text)
}

get_plot_titles <- function(pericope_no) {
  texts <- pericopes %>%
    filter(No. == pericope_no)
  title <- texts$Pericope
  texts <- texts %>%
    select(Matthew, Mark, Luke, John) %>%
    unlist()
  texts <- texts[texts != ""]
  subtitle <- map2_chr(names(texts), texts, paste) %>% paste(collapse = ", ")
  list(title = title, subtitle = subtitle)
}
