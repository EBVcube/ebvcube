#'@importFrom utils packageVersion
.onAttach <- function(lib, pkg) {
  packageStartupMessage("ebvcube package version ", utils::packageVersion('ebvcube'))
  terra::gdal(warn=2)
}
