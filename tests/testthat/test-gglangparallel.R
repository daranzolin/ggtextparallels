context("gglangparallel")

test_that("Can successfully plot langs eng-ESV, por-NTLH, and spa-RVR1960", {
  skip_on_cran()

  expect_true(inherits(gglangparallel(c("eng-ESV", "spa-RVR1960", "por-NTLH"), book = "john", verses = "1:1-5"), "ggplot"))

})

test_that("invalid versions fail", {
  skip_on_cran()

  expect_error(
    gglangparallel(versions = "fdsdfsfsd", book = "romans", verses = "1:1-5"),
    "Invalid version argument. Check biblesearch_versions for valid version ID")
})
