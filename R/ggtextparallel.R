#' Create a ggtextparallel
#'
#' @param parallel_no integer from the No. column in gospel_parallels
#' @param lang language, "eng" for English, "grk" for Greek
#'
#' @return `ggplot2` object that facets the text pericopes
#' @export
#'
#' @examples
#' ggtextparallel(93)
ggtextparallel <- function(parallel_no, lang = "eng") {

  if(!parallel_no %in% internal_gospel_parallels$No.) {
    stop("Invalid parallel argument. Check gospel_parallels for valid numbers.")
  }

  p_df <- get_pericope(parallel_no, lang) %>%
    split(.$book) %>%
    purrr::map_df(function(x) {
      tibble::tibble(
        book = x$book,
        index = x$index,
        text = split_every(x$text, 9, " ")
      )
    }) %>%
    dplyr::group_by(book) %>%
    dplyr::mutate(x = 1,
           y = rev(dplyr::row_number(index)))

  titles <- get_plot_titles(parallel_no)

  max_col <- max(p_df$y)

  p_df %>%
    split(.$book) %>%
    purrr::map_df(function(x) {
      m <- max(x$y)
      diff <- max_col - m
      dplyr::mutate(x, new_y = y + diff)
    }) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(book = factor(book, levels = c("Matthew", "Mark", "Luke", "John"))) %>%
    ggplot2::ggplot(ggplot2::aes(x = x, y = new_y)) +
    ggplot2::geom_text(ggplot2::aes(label = text, hjust = 0)) +
    ggplot2::labs(title = titles$title,
         subtitle = titles$subtitle) +
    ggplot2::xlim(1, 6) +
    ggplot2::facet_wrap(~book) +
    theme_ggtextparallels()

}

get_pericope <- function(parallel_no, lang) {

  internal_gospel_parallels %>%
    dplyr::filter(No. == parallel_no) %>%
    tidyr::gather(book, text, -Pericope) %>%
    dplyr::select(-Pericope) %>%
    dplyr::filter(text != "",
           book != "No.") %>%
    dplyr::left_join(perseus_catalog, by = c("book" = "label")) %>%
    dplyr::filter(language == lang,
                  grepl("perseus", urn)) %>%
    dplyr::select(book, text, urn) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(index = reformat_index(text),
           text_url = purrr::map2(urn, index, get_text_url),
           text = extract_text(text_url)) %>%
    dplyr::ungroup() %>%
    dplyr::select(book, index, text)
}

get_plot_titles <- function(parallel_no) {
  texts <- gospel_parallels %>%
    dplyr::filter(No. == parallel_no)
  title <- texts$Pericope
  texts <- texts %>%
    dplyr::select(Matthew, Mark, Luke, John) %>%
    unlist()
  texts <- texts[texts != ""]
  subtitle <- purrr::map2_chr(names(texts), texts, paste) %>% paste(collapse = ", ")
  list(title = title, subtitle = subtitle)
}
