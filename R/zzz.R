.onAttach <- function(lib, pkg) {
  packageStartupMessage("ebvcube package version ", packageVersion('ebvcube'))
  terra::gdal(warn=2)
}
