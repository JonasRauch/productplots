prodcalc <- function(data, formula, divider = mosaic(), cascade = 0, scale_max = TRUE, na.rm = FALSE) {
  vars <- parse_product_formula(formula)
  wt <- margin(data, vars$marg, vars$cond)
  if (na.rm) {
    wt <- wt[complete.cases(wt), ]
  }

  if (is.function(divider)) divider <- divider(ncol(wt) - 1)
  if (is.character(divider)) divider <- llply(divider, match.fun)
  
  max_wt <- if (scale_max) NULL else 1

  divide(wt, divider = rev(divider), cascade = cascade, max_wt = max_wt)
}

prodplot <- function(data, formula, divider = mosaic(), cascade = 0, scale_max = TRUE, na.rm = FALSE, subset, ...) {
  res <- prodcalc(data, formula, divider, cascade, scale_max, na.rm = na.rm)
  if (!missing(subset)) {
    sel <- eval(substitute(subset), res, parent.frame())
    res <- res[sel & !is.na(sel), ]
  }
  draw(res, ...)
}

draw <- function(df, alpha = 1, colour = "grey30") {
  ggplot(df, aes(xmin = l, xmax = r, ymin = b, ymax = t, order = level)) + 
    geom_rect(colour = colour, alpha = alpha) +
    scale_x_product(df) + 
    scale_y_product(df)
}

colour_weight <- list(
  aes(fill = .wt), 
  scale_fill_gradient("Weight", low = "grey80", high = "black"))

colour_level <- list(
  aes(fill = factor(level)),
  scale_fill_brewer("Level", pal = "Blues"))


