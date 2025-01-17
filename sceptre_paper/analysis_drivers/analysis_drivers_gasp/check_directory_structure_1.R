args <- commandArgs(trailingOnly = TRUE)
code_dir <- if (is.na(args[1])) "/Users/timbarry/Box/SCEPTRE/SCEPTRE/" else args[1]
to_source <- paste0(code_dir, c("/sceptre_paper/analysis_drivers/analysis_drivers_gasp/file_paths_to_dirs.R", "/sceptre_paper/utilities/verify_all_packages_available.R"))
for (f_to_source in to_source) source(f_to_source)
packages <- c("purrr", "stringr")
for (package in packages) suppressPackageStartupMessages(library(package, character.only = TRUE))

# Hardcode the directories to create.
sub_dirs <- c(create_parent_directories("data/gasperini/raw"), create_parent_directories("data/gasperini/precomp/gRNA"), "data/gasperini/precomp/gene", "data/gasperini/processed",
  create_parent_directories("data/functional"), "data/functional/HIC", "data/functional/ChIP-seq", "data/functional/GeneHancer",
  create_parent_directories("results/gasperini/sceptre"), "results/gasperini/negative_binomial", "results/gasperini/enrichment",
  "figures", create_parent_directories("logs/gasperini")) %>% unique()

dirs_to_create <- paste0(offsite_dir, "/", sub_dirs)
check_directories(dirs_to_create)
