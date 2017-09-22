context("ggtextparallel")

test_that("Can successfully plot parallel 37", {
  skip_on_cran()

  expect_true(inherits(ggtextparallel(parallel_no = 49, version = "grc"), "ggplot"))

})

test_that("invalid parallel numbers fail", {
  skip_on_cran()

  expect_error(
    ggtextparallel(parallel_no = 99999, version = "eng-ESV"),
    "Invalid parallel argument. Check gospel_parallels for valid numbers.")
})
