#' Read data from an EBV netCDF
#'
#' @description Read one or more layers from one datacube of the netCDF file.
#'   Decide between in-memory array, in-memory SpatRaster or an array-like
#'   object (DelayedMatrix) pointing to the on-disk netCDF file. The latter is
#'   useful for data that exceeds your memory.
#'
#' @param filepath Character. Path to the netCDF file.
#' @param datacubepath Character. Optional. Default: NULL. Path to the datacube
#'   (use [ebvcube::ebv_datacubepaths()]). Alternatively, you can use the
#'   scenario and metric argument to define which cube you want to access.
#' @param entity Character or Integer. Default is NULL. If the structure is 3D,
#'   the entity argument is set to NULL. Else, specify one or more entities
#'   of the 4D structure of the EBV netCDFs by name or index.
#' @param timestep Integer or character. Select one or several timestep(s).
#'   Either provide an integer value or list of values that refer(s) to the
#'   index of the timestep(s) (minimum value: 1) or provide a date or list of
#'   dates in ISO format, such as '2015-01-01'.
#' @param type Character. Choose between 'a', 'r' and 'da'. The first returns an
#'   array or matrix object. The 'r' indicates that a SpatRaster object from the
#'   terra package will be returned (default). The latter ('da') returns a
#'   DelayedArray or DelayedMatrix object.
#' @param scenario Character or integer. Optional. Default: NULL. Define the
#'   scenario you want to access. If the EBV netCDF has no scenarios, leave the
#'   default value (NULL). You can use an integer value defining the scenario or
#'   give the name of the scenario as a character string. To check the available
#'   scenarios and their name or number (integer), use
#'   [ebvcube::ebv_datacubepaths()].
#' @param metric Character or integer. Optional. Define the metric you want to
#'   access. You can use an integer value defining the metric or give the name
#'   of the scenario as a character string. To check the available metrics and
#'   their name or number (integer), use [ebvcube::ebv_datacubepaths()].
#' @param sparse Logical. Default: FALSE. Set to TRUE if the data contains a lot
#'   empty raster cells. Only relevant for DelayedArray return value.
#' @param ignore_RAM Logical. Default: FALSE. Checks if there is enough space in
#'   your memory to read the data. Can be switched off (set to TRUE).
#' @param verbose Logical. Default: TRUE. Turn off additional prints by setting
#'   it to FALSE.
#'
#' @note For working with the DelayedMatrix take a look at
#'   [DelayedArray::DelayedArray()] and the
#'   \href{https://www.rdocumentation.org/packages/HDF5Array/versions/1.0.2/topics/DelayedArray-utils}{DelayedArray-utils}.
#'
#'
#'
#' @return Array, SpatRaster or DelayedArray object containing the data of the
#'   corresponding datacube and timestep(s). With multiple entities,
#'   the result includes every combination of entity and timestep.
#'   A SpatRaster has one layer per combination, grouped by entity and
#'   named by entity and date. Arrays and delayed arrays have
#'   dimensions `[row, column, time, entity]`, even with one timestep.
#' @export
#'
#' @examples
#' #set path to EBV netCDF
#' file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
#' #get all datacubepaths of EBV netCDF
#' datacubes <- ebv_datacubepaths(file, verbose=FALSE)
#'
#' \donttest{
#' #read data as DelayedArray
#' cSAR.delayedarray <- ebv_read(filepath = file, datacubepath = datacubes[1,1],
#'                               entity = 1, timestep = c(1,3), type='da',
#'                               sparse = TRUE)
#' #read data as SpatRaster
#' cSAR.raster <- ebv_read(filepath = file,entity = 1, timestep = "2000-01-01",
#'                         type='r', metric = 1)
#'
#' #read multiple entities and timesteps as a SpatRaster
#' cSAR.raster <- ebv_read(filepath = file, datacubepath = datacubes[1,1],
#'                         entity = c(3, 1), timestep = c(2, 1), type = "r")
#'
#' #read data as Array
#' cSAR.array <- ebv_read(filepath = file, datacubepath = datacubes[1,1],
#'                               entity = 1, timestep = 1, type='a')
#' }
ebv_read <- function(filepath, datacubepath = NULL,  entity=NULL, timestep=1,
                     type='r', scenario = NULL, metric = NULL,
                     sparse=FALSE, ignore_RAM = FALSE, verbose = FALSE){

  ####initial tests start ----
  # ensure file and all datahandles are closed on exit
  withr::defer(
    if(exists('hdf')){
      if(rhdf5::H5Iis_valid(hdf)==TRUE){rhdf5::H5Fclose(hdf)}
    }
  )
  #are all arguments given?
  if(missing(filepath)){
    stop('Filepath argument is missing.')
  }

  #check verbose
  if(checkmate::checkLogical(verbose, len=1, any.missing=FALSE) != TRUE){
    stop('Verbose must be of type logical.')
  }

  #check logical arguments
  if(checkmate::checkLogical(sparse, len=1, any.missing=FALSE) != TRUE){
    stop('sparse must be of type logical.')
  }
  if(checkmate::checkLogical(ignore_RAM, len=1, any.missing=FALSE) != TRUE){
    stop('ignore_RAM must be of type logical.')
  }

  #filepath check
  if (checkmate::checkCharacter(filepath) != TRUE){
    stop('Filepath must be of type character.')
  }
  if (checkmate::checkFileExists(filepath) != TRUE){
    stop(paste0('File does not exist.\n', filepath))
  }
  if (!endsWith(filepath, '.nc')){
    stop(paste0('File ending is wrong. File cannot be processed.'))
  }

  # type test
  if (checkmate::checkCharacter(type) != TRUE){
    stop('Type must be of type character.')
  }
  if (! type %in% c('da', 'r', 'a')){
    stop('Type must be "da", "r" or "a". Check help page for more information.')
  }

  #file closed?
  # ebv_i_file_opened(filepath, verbose)

  #datacubepath check
  #1. make sure anything is defined
  if(is.null(datacubepath) && is.null(scenario) && is.null(metric)){
    stop('You need to define the datacubepath or the scenario and metric.
       Regarding the second option: If your EBV netCDF has no scenario,
       leave the argument empty.')
  }else if(!is.null(datacubepath)){
    #2. check datacubepath
    # open file
    hdf <- rhdf5::H5Fopen(filepath, flags = "H5F_ACC_RDONLY")
    if (checkmate::checkCharacter(datacubepath) != TRUE) {
      stop('Datacubepath must be of type character.')
    }
    if (rhdf5::H5Lexists(hdf, datacubepath) == FALSE ||
        !stringr::str_detect(datacubepath, 'ebv_cube')) {
      stop(paste0('The given datacubepath is not valid:\n', datacubepath))
    }
    #close file
    rhdf5::H5Fclose(hdf)
  } else if(!is.null(metric)){
    #3. check metric&scenario
    datacubepaths <- ebv_datacubepaths(filepath, verbose=verbose)
    datacubepath <- ebv_i_datacubepath(scenario, metric,
                                       datacubepaths, verbose=verbose)
  }

  #get properties
  prop <- ebv_properties(filepath, datacubepath, verbose=verbose)

  #check file structure
  is_4D <- ebv_i_4D(filepath)
  # for a 3D cube, count one slice per timestep in the read loop and RAM check.
  # only 4D reads use an entity index to select data from the file.
  entity_index <-  1L
  if(is_4D){
    #check entity
    entity_names <- prop@general$entity_names
    entity_index <- ebv_i_entity_indices(entity, entity_names)
    # ebv_i_entity(entity, entity_names)
  }
  #timestep check -> in case of ISO, get index
  timestep <- ebv_i_date(timestep, prop@temporal$dates)
  n_time <- length(timestep)
  if (n_time == 0L){
    stop("Select at least one timestep")
  }
  n_entity <-  length(entity_index)
  multi_entity <- n_entity > 1L

  if(multi_entity){
    # look up labels and dates using the same indices as the data reads
    # arrays use them as dimension names, and rasters use them as layer metadata.
    entity_labels <- entity_names[entity_index]
    selected_dates <- prop@temporal$dates[timestep]
    slice_dimnames <- list(
      row = NULL, column = NULL,
      time = as.character(selected_dates), entity = entity_labels
    )
  }

  #######initial test end ----

  #get fillvalue
  fillvalue <- prop@ebv_cube$fillvalue

  if (type=='da'){
    #return delayed array ----
    #get type
    type.long <- prop@ebv_cube$type
    #get numeric type
    type.short <- ebv_i_type_r(type.long)

    #read as H5Array
    all <- HDF5Array::HDF5Array(
      filepath = filepath,
      name =datacubepath,
      as.sparse = sparse,
      type = type.short
      )

    #rotate data
    if (multi_entity) {
      #keep all four dimensions, even when only one timestep is selected
      selected <- all[, , timestep, entity_index, drop = FALSE]
      #the file stores colums before rows. Swap the spatial axes to return
      #[row, column, time, entity]. The permutation remains delayed.
      h5array <- DelayedArray::aperm(selected, c(2L, 1L, 3L, 4L))
      #convert the files's missing-value marker to NA when one is defined
      if (!is.na(fillvalue[1])) {
        h5array <- replace(h5array, h5array == fillvalue[1], NA)
      }
      dimnames(h5array) <- slice_dimnames
    } else if (is_4D) {

      #4D structure
      if (length(timestep)>1){
        #select entity cube
        entity_part <- all[, , timestep, entity_index]
        #rotate matrix
        h5array <- DelayedArray::aperm(DelayedArray::aperm(entity_part, 3:1), c(2, 3, 1))
        #replace NA value
        h5array <- replace(h5array, h5array==fillvalue[1], NA)
      }
      else{
        #select slice
        h5array <- all[, , timestep, entity_index]
        #rotate matrix
        h5array <- t(h5array[, , drop=FALSE])
        #replace NA value
        h5array <- replace(h5array, h5array==fillvalue[1], NA)
      }
    } else{
      #3D strucuture
      if (length(timestep)>1){
        #rotate matrix
        h5array <- DelayedArray::aperm(DelayedArray::aperm(all, 3:1), c(2, 3, 1))
        #replace NA value
        h5array <- replace(h5array, h5array==fillvalue[1], NA)
      }
      else{
        h5array <- all[, , timestep]
        #rotate matrix
        h5array <- t(h5array[, , drop=FALSE])
        #replace NA value
        h5array <- replace(h5array, h5array==fillvalue[1], NA)
      }
    }
    #return any in-memory object ----
  } else if (type=='a' || type=='r') {
    #check needed RAM
    if (!ignore_RAM){
      type.long <- prop@ebv_cube$type
      ebv_i_check_ram(prop@spatial$dimensions, timestep, entity_index, type.long)
    } else{
      if(verbose){
        print('RAM capacities are ignored.')
      }
    }

    #return in memory array ----
    #allocate one spatial layer per entity and timestep combination.
    spatial_dims <- prop@spatial$dimensions[1:2]
    h5array <- array(dim = c(spatial_dims, n_time * n_entity))

    #read all selected timesteps for one entity before moving to the next
    for (entity_pos in seq_along(entity_index)) {
      for (time_pos in seq_along(timestep)) {
        #read the full spatial grid at one timestep. the file uses
        #column, row, time order, with an entity axis only for 4D cubes
        start <- c(1L, 1L, timestep[time_pos])
        count <- c(rev(spatial_dims), 1L)
        if (is_4D) {
          start <- c(start, entity_index[entity_pos])
          count <- c(count, 1L)
        }
        part <- rhdf5::h5read(filepath, datacubepath, start = start, count = count)
        #put rows first and conver the file's missing value marker to NA.
        mat <- t(matrix(part, nrow = spatial_dims[2], ncol = spatial_dims[1]))
        mat[match(mat, fillvalue, nomatch = 0L) == 1L] <- NA

        #file indices select what to read. Positions in the request decide where
        #to store it. With two timesteps, entity_pos = 2 starts at layer 3.
        layer <- (entity_pos - 1L) * n_time + time_pos
        h5array[, , layer] <- mat
      }
    }

    # raster output uses the layer axis directly. For array output, split that axis
    # into time and entity. Time varies festest within each entity.
    if (type == "a" && multi_entity) {
      dim(h5array) <- c(spatial_dims, n_time, n_entity)
      dimnames(h5array) <- slice_dimnames
    }

    if(type=='r'){
      # return SpatRaster object ----

        extent <- terra::ext(c(prop@spatial$extent[1], prop@spatial$extent[2],
                    prop@spatial$extent[3], prop@spatial$extent[4]))
        h5array <- terra::rast(h5array, crs=prop@spatial$wkt2, extent=extent)


      #set nodata value
        # print(fillvalue)
        if(!is.na(fillvalue)){
          h5array <- terra::classify(h5array, cbind(fillvalue, NA))
        }
        if (multi_entity) {
          # read the full data sequence for each entity. Repeat each entity name
          # once per timestep. Both vectors follow the order of the read loop.
          layer_dates <- rep(selected_dates, times = n_entity)
          layer_entities <- rep(entity_labels, each = n_time)
          names(h5array) <- make.unique(paste(layer_entities, layer_dates, sep = " - "))
          terra::time(h5array) <- layer_dates
        }
    }

  } else {
    stop('Something went terribly wrong. Check your type argument.')
  }

  return(h5array)
}
