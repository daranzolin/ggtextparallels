#' Create a ggtextparallel
#'
#' @param parallel_no integer from the No. column in gospel_parallels.
#' @param version translation version from versions object. "grc" for koine greek.
#' @param words_per_row how many words are displayed per row.
#'
#' @return `ggplot2` object that facets the text pericopes
#' @export
#'
#' @examples
#' ggtextparallel(93, version = "eng-ESV")
#' ggtextparallel(17, version = "grc", words_per_row = 5)
ggtextparallel <- function(parallel_no, version = NULL, words_per_row = 7) {

  if(!parallel_no %in% internal_gospel_parallels$No.) {
    stop("Invalid parallel argument. Check gospel_parallels for valid numbers.")
  }
  if (!version %in% internal_biblesearch_versions$id && !version == "grc") {
    stop("Invalid version argument. Check biblesearch_versions for valid version ID")
  }

  raw_parallel <- get_pericope(parallel_no, version)

  p_df <- raw_parallel %>%
    split(.$book) %>%
    purrr::map_df(function(x) {
      tibble::tibble(
        book = x$book,
        index = x$index,
        text = split_every(x$text, words_per_row, " ")
      )
    }) %>%
    dplyr::group_by(book) %>%
    dplyr::mutate(x = 1,
           y = rev(dplyr::row_number(index))) %>%
    dplyr::ungroup()

  titles <- get_plot_titles(parallel_no, version)

  max_col <- max(p_df$y)

  p_df <- p_df %>%
    split(.$book) %>%
    purrr::map_df(function(x) {
      m <- max(x$y)
      diff <- max_col - m
      dplyr::mutate(x, new_y = y + diff)
    }) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(book = factor(book, levels = c("Matthew", "Mark", "Luke", "John")))

  max_ylim <- max(p_df$new_y)
  common_words <- paste(extract_common_words(raw_parallel), collapse = ", ")

    ggplot2::ggplot(p_df, ggplot2::aes(x = x, y = new_y)) +
    ggplot2::geom_text(ggplot2::aes(label = text, hjust = 0)) +
    ggplot2::labs(title = titles$title,
         subtitle = titles$subtitle,
         caption = paste("Common words:", common_words)
         ) +
    ggplot2::xlim(1, 6) +
    ggplot2::ylim(-10, max_ylim) +
    ggplot2::facet_wrap(~book, nrow = 1) +
    theme_ggtextparallels()

}

get_pericope <- function(parallel_no, version) {

  #Greek text comes from Perseus Digital Library
  if (version == "grc") {
    xt <- internal_gospel_parallels %>%
      dplyr::filter(No. == parallel_no) %>%
      tidyr::gather(book, text, -Pericope) %>%
      dplyr::select(-Pericope) %>%
      dplyr::filter(text != "",
                    book != "No.") %>%
      dplyr::left_join(perseus_catalog, by = c("book" = "label")) %>%
      dplyr::filter(language == version,
                    grepl("perseus", urn)) %>%
      dplyr::select(book, text, urn) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(index = reformat_index(text),
                    text_url = purrr::map2(urn, index, get_text_url),
                    text = extract_text(text_url)) %>%
      dplyr::ungroup() %>%
      dplyr::select(book, index, text)

  } else {

    #All other versions come from BIBLESEARCH API

    x <- internal_gospel_parallels %>%
      dplyr::filter(No. == parallel_no) %>%
      tidyr::gather(book, verses, -Pericope) %>%
      dplyr::filter(verses != "",
                    book != "No.") %>%
      dplyr::select(book, verses)

    xt <- process_biblesearch_text(versions = version, books = x$book, verses = x$verses)

    if (version == "spa-RVR1960") {
      return(xt)
    } else {
      xt <- xt %>%
        dplyr::mutate(first_verse_number = get_first_verse_number(index)) %>%
        dplyr::rowwise() %>%
        dplyr::mutate(text = new_text(first_verse_number, text))
    }
  }
  xt
}

get_plot_titles <- function(parallel_no, version) {
  texts <- gospel_parallels %>%
    dplyr::filter(No. == parallel_no)
  if (version == "grc") {
    version <- "(Koine Greek)"
  } else {
    version <- paste0("(", stringr::str_split(version, "-")[[1]][2], ")")
  }
  title <- paste(texts$Pericope, version)
  texts <- texts %>%
    dplyr::select(Matthew, Mark, Luke, John) %>%
    unlist()
  texts <- texts[texts != ""]
  subtitle <- purrr::map2_chr(names(texts), texts, paste) %>% paste(collapse = ", ")
  list(title = title, subtitle = subtitle)
}
