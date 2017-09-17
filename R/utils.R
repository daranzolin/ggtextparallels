reformat_index <- function(x) {
  parts <- stringr::str_split(x, "[.-]")[[1]]
  ch <- parts[1]
  start <- paste(ch, parts[2], sep = ".")
  fin <- paste(ch, parts[3], sep = ".")
  paste(start, fin, sep = "-")
}

get_text_url <- function(text_urn, text_index) {
  BASE_URL <- "http://cts.perseids.org/api/cts"
  httr::modify_url(BASE_URL,
                   query = list(
                     request = "GetPassage",
                     urn = paste(text_urn, text_index, sep = ":"
                                 )
                     )
                   )
}

extract_text <- function(text_url) {

  res <- httr::GET(text_url,
                   httr::user_agent(
                     "ggpericope - https://github.com/daranzolin/ggpericope")
  )
  if (res$status_code == 500) stop("Nothing available for that URN.")
  httr::stop_for_status(res)
  r_list <- res %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  purrr::map(r_list$reply$passage$TEI$text$body$div,
                     ~ paste(unlist(.), collapse = " ")) %>%
    stringr::str_replace_all("\\s+", " ") %>%
    stringr::str_replace_all("\\*", "") %>%
    stringr::str_trim()
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

split_every <- function(x, n, pattern, collapse = pattern, ...) {
  x_split <- strsplit(x, pattern, perl = TRUE, ...)[[1]]
  out <- character(ceiling(length(x_split) / n))
  for (i in seq_along(out)) {
    entry <- x_split[seq((i - 1) * n + 1, i * n, by = 1)]
    out[i] <- paste0(entry[!is.na(entry)], collapse = collapse)
  }
  out
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