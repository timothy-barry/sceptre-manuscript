# set code dir and offsite dir
code_dir <- paste0(.get_config_path("LOCAL_CODE_DIR"), "sceptre-manuscript")
offsite_dir <- .get_config_path("LOCAL_SCEPTRE_DATA_DIR")

to_source <- paste0(code_dir, c("/sceptre_paper/analysis_drivers/analysis_drivers_xie/paths_to_dirs.R", "/sceptre_paper/utilities/verify_all_packages_available.R"))
for (f_to_source in to_source) source(f_to_source)
packages <- c("purrr", "stringr")
for (package in packages) suppressPackageStartupMessages(library(package, character.only = TRUE))

# Hardcode the directories to create.
sub_dirs <- c(create_parent_directories("data/xie/raw"), create_parent_directories("data/xie/precomp/gRNA"), "data/xie/precomp/gene", "data/xie/processed",
              create_parent_directories("results/xie/sceptre"), "results/xie/negative_binomial", "results/xie/bulk_rna_seq", "figures", create_parent_directories("logs/xie")) %>% unique()

dirs_to_create <- paste0(offsite_dir, "/", sub_dirs)
check_directories(dirs_to_create)
