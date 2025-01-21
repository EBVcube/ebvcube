#BEFORE SUBMITTING TO CRAN
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

#1. update date AND version number in DESCRIPTION file
#2. update News.md
#3. update the CITATION.cff
cffr::cff_write(dependencies=FALSE)
#4. run lintr
lintr::lint_dir()
#5. check all URLs
urlchecker::url_check()
#6. document + manual + readme
devtools::document()
devtools::build_manual(path='C:\\Users\\lq39quba\\Desktop\\package\\ebvcube\\inst\\docs')
devtools::build_readme()
#7. update Rbuildignore -> new manual version
#8. Again, run tests and examples + check
devtools::test()
devtools::run_examples()
devtools::check()

# Check package as CRAN
# rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))

# Check content
#install.packages('checkhelper', repos = 'https://thinkr-open.r-universe.dev')
# checkhelper::find_missing_tags()
# # _Check that you let the house clean after the check, examples and tests
# all_files_remaining <- checkhelper::check_clean_userspace()
# all_files_remaining

# Check spelling
# usethis::use_spell_check()
# spelling::spell_check_package()


# Check URL are correct
# install.packages('urlchecker', repos = 'https://r-lib.r-universe.dev')

# urlchecker::url_update()

# Upgrade version number
# usethis::use_version(which = c("patch", "minor", "major", "dev")[1])

# check on other distributions
# _rhub
# cran_prep <- rhub::check_for_cran()
# cran_prep$cran_summary()
# devtools::check_rhub()
# rhub::check_on_windows(check_args = "--force-multiarch")
# rhub::check_on_solaris()
# # _win devel
# devtools::check_win_devel()

# # Check reverse dependencies
# # remotes::install_github("r-lib/revdepcheck")
# install.packages('revdepcheck', repos = 'https://r-lib.r-universe.dev')
# usethis::use_git_ignore("revdep/")
# usethis::use_build_ignore("revdep/")
#
# devtools::revdep()
# library(revdepcheck)
# In another session
# id <- rstudioapi::terminalExecute("Rscript -e 'revdepcheck::revdep_check(num_workers = 4)'")
# rstudioapi::terminalKill(id)
# # See outputs
# revdep_details(revdep = "pkg")
# revdep_summary()                 # table of results by package
# revdep_report() # in revdep/
# # Clean up when on CRAN
# revdep_reset()


# Add comments for CRAN
# usethis::use_cran_comments(open = rlang::is_interactive())


#MANUALLY
#update date in DESCRIPTION
#upgraded version number correctly?
#news uptodate?

# Verify you're ready for release, and release
# devtools::release()

# shiny app
shiny,
shinyFiles,
shinyWidgets,
bslib,
remove stuff from Rbuildignore
