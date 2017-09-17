#' ggtextparallels theme
#'
#' @param base_size base_size
#' @param base_family base_family
#'
#' @return a `ggplot2` theme
#' @noRd
#'
#' @import ggplot2
#'
theme_ggtextparallels <- function(base_size = 12, base_family = "Helvetica"){
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      strip.text = element_text(face = "italic"),
      #strip.text.x = element_text(size = 18, colour = "grey"),
      #panel.grid.major = element_blank(),
      legend.key=element_rect(colour = NA, fill = NA),
      strip.background = element_rect(colour="black", fill="lightgrey"),
      panel.grid = element_blank(),
      panel.border = element_rect(fill = NA, colour = "lightblue", size = 1),
      #panel.background = element_rect(fill = "white", colour = "black"),
      panel.spacing.x = unit(0, "lines")
    )
}
