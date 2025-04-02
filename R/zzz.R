#'@importFrom utils packageVersion
.onAttach <- function(lib, pkg) {
  # terra::gdal(warn=2)
  packageStartupMessage("ebvcube ", utils::packageVersion('ebvcube'))
}
