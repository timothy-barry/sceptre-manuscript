# Load sceptre
suppressPackageStartupMessages(library(sceptre))

# directory file paths
offsite_dir <- .get_config_path("LOCAL_SCEPTRE_DATA_DIR")

# Define variables for fps to common directories.
processed_dir <- paste0(offsite_dir, "/data/gasperini/processed")
gene_precomp_dir <- paste0(offsite_dir, "/data/gasperini/precomp/gene")
gRNA_precomp_dir <- paste0(offsite_dir, "/data/gasperini/precomp/gRNA")
results_dir <- paste0(offsite_dir, "/results/gasperini/sceptre")
raw_data_dir <- paste0(offsite_dir, "/data/gasperini/raw")
log_dir <- paste0(offsite_dir, "/logs/gasperini")
results_dir_negative_binomial <- paste0(offsite_dir, "/results/gasperini/negative_binomial")
