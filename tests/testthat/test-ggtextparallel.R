context("ggtextparallel")

test_that("Can successfully plot parallel 37", {
  skip_on_cran()

  expect_true(inherits(ggtextparallel(49, lang = "grc"), "ggplot"))

})

test_that("invalid parallel numbers fail", {
  skip_on_cran()

  expect_error(
    ggtextparallel(parallel_no = 99999),
    "Invalid parallel argument. Check gospel_parallels for valid numbers.")
})
