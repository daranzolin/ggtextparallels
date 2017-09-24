#' Create a ggtextparallel by versions
#'
#' @param versions valid versions obtained from biblesearch_versions
#' @param book book, e.g. "genesis", "mark", "romans"
#' @param passage text, e.g. "1:1-5", "1.1-5"
#' @param words_per_row words displayed per rown
#'
#' @return a ggplot2 object
#' @export
#'
#' @examples
gglangparallel <- function(versions, book, verses, words_per_row = 6) {

  if (!any(versions %in% internal_biblesearch_versions$id) && !version == "grc") {
    stop("Invalid version argument. Check biblesearch_versions for valid version ID")
  }

  xt <- process_biblesearch_text(versions = versions, books = book, verses = verses)

  l_df <- xt %>%
    dplyr::mutate(version = versions) %>%
    split(.$version) %>%
    purrr::map_df(function(x) {
      tibble::tibble(
        version = x$version,
        index = x$index,
        text = split_every(x$text, words_per_row, " ")
      )
    }) %>%
    dplyr::group_by(version) %>%
    dplyr::mutate(x = 1,
                  y = rev(dplyr::row_number(index))) %>%
    dplyr::ungroup()

  max_col <- max(l_df$y)

  l_df <- l_df %>%
    split(.$version) %>%
    purrr::map_df(function(x) {
      m <- max(x$y)
      diff <- max_col - m
      dplyr::mutate(x, new_y = y + diff)
    }) %>%
    dplyr::ungroup()

  max_ylim <- max(l_df$new_y)

  ggplot2::ggplot(l_df, ggplot2::aes(x = x, y = new_y)) +
    ggplot2::geom_text(ggplot2::aes(label = text, hjust = 0)) +
    ggplot2::labs(title = paste(stringr::str_to_title(book), verses),
                  subtitle = paste("Versions:", paste(versions, collapse = ", "))
                  ) +
    ggplot2::xlim(1, 6) +
    ggplot2::ylim(-10, max_ylim) +
    ggplot2::facet_wrap(~version, nrow = 1) +
    theme_ggtextparallels()
}


