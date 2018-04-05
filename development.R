require(devtools)
require(testthat)
require(R.rsp)

options(error = NULL)

load_all()
test()

roxygen2::roxygenize()

build_vignettes()
