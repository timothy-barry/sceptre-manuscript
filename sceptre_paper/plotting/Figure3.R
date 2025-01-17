# Reproduce Figure 3 from Katsevich, Barry, and Roeder (2020).
args <- commandArgs(trailingOnly = TRUE)
code_dir <- if (is.na(args[1])) "~/research_code/sceptre-manuscript/" else args[1]
require(katsevich2020)
require(cowplot)
source(paste0(code_dir, "/sceptre_paper/plotting/load_data_for_plotting.R"))
fig3_dir <- paste0(manuscript_figure_dir, "/Figure3")

# subfigure a: simulation results
p_thresh <- 1e-8
qq_data <- simulation_results %>%
  group_by(method, dataset_id) %>%
  mutate(r = rank(p_value, ties.method = "first"), expected = ppoints(n())[r],
         clower = qbeta(p=(1-ci)/2, shape1 = r, shape2 = n()+1-r),
         cupper = qbeta(p=(1+ci)/2, shape1 = r, shape2 = n()+1-r)) %>%
  ungroup() %>%
  mutate(pvalue = ifelse(p_value < p_thresh, p_thresh, p_value),
         facet_label = factor(x = as.character(dataset_id), levels = c("2", "1", "3", "4"), labels = c("Correct model", "Dispersion too large", "Dispersion too small", "Zero inflation")),
         method = factor(x = as.character(method), levels = c("sceptre", "negative_binomial", "scMAGeCK"), labels = c("SCEPTRE", "Fixed dispersion NB", "scMAGeCK")))
qq_data <- qq_data[qq_data$method != 'scMAGeCK', ]
qq_data$method = factor(as.character(qq_data$method), levels = c('SCEPTRE', 'Negative Binomial'))

p_a <- qq_data %>%
  ggplot(aes(x = expected, col = method, y = pvalue, ymin = clower, ymax = cupper)) +
  geom_ribbon(alpha = 0.2, color = NA) +
  geom_abline(intercept = 0, slope = 1) +
  geom_point(size = 1, alpha = 0.5) +
  xlab("Expected null p-value") +
  ylab("Observed p-value") +
  ggtitle("Simulated negative control pair") +
  scale_colour_manual(values = setNames(plot_colors[c("sceptre", "hf_nb")], NULL), name = "Method") +
  guides(color = guide_legend(override.aes = list(alpha = 1))) +
  scale_x_continuous(trans = revlog_trans(base = 10)) +
  scale_y_continuous(trans = revlog_trans(base = 10)) +
  facet_wrap(.~facet_label, nrow = 1) +
  theme_bw() + theme(
    legend.position = c(0.15, 0.8),
    legend.title = element_blank(),
    panel.spacing.x = unit(1.25, "lines"),
    plot.title = element_text(hjust = 0.5),
    strip.background = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line())

# ggsave(filename = paste0(fig3_dir, "/figure3a.pdf"), plot = p_a, device = "pdf", scale = 1, width = 8, height = 2.75)

# subfigure b: p-values for gasperini NTCs
df_NTC <- rbind(select(original_results_gasp, gene_id, grna_group, pvalue = pvalue.raw, site_type) %>% mutate(method = "Monocle NB"),
                select(resampling_results_gasp, gene_id, grna_group, pvalue = p_value, site_type) %>% mutate(method = "SCEPTRE"),
                select(likelihood_results_gasp,  gene_id, grna_group, pvalue, site_type) %>% mutate(method = "Hafemeister NB")) %>% 
          filter(site_type == "NTC") %>% mutate_at(.vars = c("gene_id", "grna_group", "site_type"), .funs = factor) %>% 
          mutate(method = factor(x = as.character(method), levels = c("Monocle NB", "Hafemeister NB", "SCEPTRE"), labels = c("Monocle NB", "Hafemeister NB", "SCEPTRE"))) %>% 
          arrange(method)
df1 <- df_NTC %>%
  group_by(method) %>%
  dplyr::mutate(r = rank(pvalue), expected = ppoints(n())[r],
         clower = qbeta(p=(1-ci)/2, shape1 = r, shape2 = n()+1-r),
         cupper = qbeta(p=(1+ci)/2, shape1 = r, shape2 = n()+1-r)) %>%
  ungroup() %>% mutate()
p_thresh <- 1e-8
p_b <- df1 %>% filter(-log10(expected) > 2 | row_number() %% subsampling_factor == 0) %>% mutate(clower = ifelse(method == "SCEPTRE", clower, NA), cupper = ifelse(method == "SCEPTRE", cupper, NA)) %>%
  mutate(pvalue = ifelse(pvalue < p_thresh, p_thresh, pvalue)) %>%
  ggplot(aes(x = expected, y = pvalue, group = method, ymin = clower, ymax = cupper)) +
  geom_point(aes(color = method), size = 1, alpha = 0.5) +
  geom_ribbon(alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1) +
  scale_colour_manual(values = c(plot_colors[["gasperini_nb"]], plot_colors[["hf_nb"]], plot_colors[["sceptre"]])) +
  scale_x_continuous(trans = revlog_trans(base = 10)) + scale_y_continuous(trans = revlog_trans(base = 10)) +
  xlab(expression(paste("Expected null p-value"))) +
  ylab(expression(paste("Observed p-value"))) +
  ggtitle("Gasperini negative control pairs") +
  theme_bw() + theme(legend.position = c(0.25, 0.85),
                     legend.background = element_rect(fill = "transparent", colour = NA),
                     legend.title = element_blank(),
                     panel.grid = element_blank(),
                     strip.background = element_blank(),
                     panel.border = element_blank(),
                     axis.line = element_line(),
                     plot.title = element_text(hjust = 0.5)) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))
# ggsave(filename = paste0(fig3_dir, "/figure3b.pdf"), plot = p_b, device = "pdf", scale = 1, width = 4, height = 3)

# new subfigure c: negative control for Xie data
likelihood_results_xie <- likelihood_results_xie %>% rename(site_type = type)
monocle_results_xie <- monocle_results_xie %>% dplyr::rename(site_type = type)

df_NTC <- rbind(select(original_results_xie, gene_id, gRNA_id, pvalue = raw_p_val, site_type) %>% mutate(method = "Virtual FACS"),
                select(resampling_results_xie, gene_id, gRNA_id, pvalue = p_value, site_type) %>% mutate(method = "SCEPTRE"),
                select(likelihood_results_xie,  gene_id, gRNA_id, pvalue = p_value, site_type) %>% mutate(method = "Negative Binomial"), 
                select(monocle_results_xie, gene_id, gRNA_id, pvalue = p_value, site_type) %>% mutate(method = 'Monocle NB')  ) %>% 
  filter(site_type == "negative_control") %>% mutate_at(.vars = c("gene_id", "gRNA_id", "site_type"), .funs = factor) %>% 
  mutate(method = factor(x = as.character(method), levels = c("Virtual FACS", "Negative Binomial", "SCEPTRE", "Monocle NB"), labels = c("Virtual FACS", "Negative Binomial", "SCEPTRE", "Monocle NB"))) %>%
  arrange(method)

df1 <- df_NTC %>%
  group_by(method) %>%
  dplyr::mutate(r = rank(pvalue), expected = ppoints(n())[r],
         clower = qbeta(p=(1-ci)/2, shape1 = r, shape2 = n()+1-r),
         cupper = qbeta(p=(1+ci)/2, shape1 = r, shape2 = n()+1-r)) %>%
  ungroup() %>% mutate()

p_thresh <- 1e-8
p_xie_neg <- df1 %>% filter(-log10(expected) > 0 | row_number() %% subsampling_factor == 0) %>% 
  mutate(clower = ifelse(method == "SCEPTRE", clower, NA), cupper = ifelse(method == "SCEPTRE", cupper, NA)) %>%
  mutate(pvalue = ifelse(pvalue < p_thresh, p_thresh, pvalue)) %>%
  ggplot(aes(x = expected, y = pvalue, group = method, ymin = clower, ymax = cupper)) +
  geom_point(aes(color = method), size = 1, alpha = 0.5) +
  geom_ribbon(alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1) +
  scale_colour_manual(values = setNames(plot_colors[c("hypergeometric", "hf_nb", "sceptre", "gasperini_nb")], NULL), name = "Method") +
  scale_x_continuous(trans = revlog_trans(base = 10)) + 
  scale_y_continuous(trans = revlog_trans(base = 10)) +
  xlab(expression(paste("Expected null p-value"))) +
  ylab(expression(paste("Observed p-value"))) +
  ggtitle("Xie negative control pairs") +
  theme_bw() + theme(
    legend.position = c(0.25, 0.8),
    #legend.title = element_blank(), 
    legend.background = element_rect(fill = "transparent", colour = NA),
    legend.title = element_blank(),
    panel.grid = element_blank(),
    strip.background = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line(),
    plot.title = element_text(hjust = 0.5)) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))
#ggsave(filename = paste0(fig3_dir, "/figure_xie_neg.pdf"), plot = p_xie_neg, device = "pdf", scale = 1, width = 5, height = 3)

# subfigure d: gasperini positive controls
combined_results <- rbind(
  original_results_gasp %>%
    mutate(pvalue.empirical = ifelse(beta > 0, 1, pvalue.empirical)) %>%
    select(gene_id, target_site, quality_rank_grna, site_type, pvalue.empirical) %>%
    dplyr::rename(pvalue = pvalue.empirical) %>%
    mutate(method = "Original"),
  resampling_results_gasp %>%
    select(gene_id, target_site, quality_rank_grna, site_type, p_value) %>%
    dplyr::rename(pvalue = p_value) %>%
    mutate(method = "SCEPTRE"))
library(tidyr)
p_d <- combined_results %>%
  mutate(pvalue = ifelse(pvalue == 0, 1e-17, pvalue)) %>%
  filter(site_type %in% c("selfTSS")) %>%
  spread(method, pvalue) %>%
  ggplot(aes(x = Original, y = SCEPTRE)) +
  geom_point(colour = "royalblue4") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  scale_x_continuous(trans = revlog_trans(base = 10)) +
  scale_y_continuous(trans = revlog_trans(base = 10)) + theme_bw() +
  xlab("Original empirical p-value") + ylab("SCEPTRE p-value") + ggtitle("Gasperini positive control pairs") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line())

# subfigure e: bulk RNA-seq confirmation
p_vals_bulk <- mutate(p_vals_bulk, rejected_bulk = p_value_adj < 0.1)
resampling_results_xie_with_names <- resampling_results_xie_with_names %>% filter(enh_names == "ARL15-enh")
resampling_results_xie_for_bulk <- resampling_results_xie_with_names %>% select(p_value, gene_names) %>%
  mutate(p_value_adj = p.adjust(p_value, method = "BH"), rejected_sceptre = p_value_adj < 0.1)
to_plot <- inner_join(p_vals_bulk, resampling_results_xie_for_bulk, by = "gene_names") %>%
  rename(bulk_pval_adj = p_value_adj.x, bulk_pval = p_value.x, sceptre_pval_adj = p_value_adj.y, sceptre_pval = p_value.y) %>%
  mutate(is_arl15 = (gene_names == "ARL15"))

p_e <- ggplot(data = to_plot, mapping = aes(x = bulk_pval, y = sceptre_pval, col = is_arl15)) +
  geom_point(alpha = 0.5) +
  scale_colour_manual(values = c("grey60", "firebrick3")) +
  scale_x_continuous(trans = revlog_trans(base = 10)) +
  scale_y_continuous(trans = revlog_trans(base = 10)) +
  geom_vline(xintercept = filter(to_plot, !rejected_bulk) %>% pull(bulk_pval) %>% min(), col = "royalblue4", linetype = "dashed") +
  geom_hline(yintercept = filter(to_plot, !rejected_sceptre) %>% pull(sceptre_pval) %>% min(), col = "royalblue4", linetype = "dashed") +
  theme_bw() + theme(plot.title = element_text(hjust = 0.5),
                     legend.background = element_rect(fill = "transparent", color = NA),
                     panel.grid = element_blank(),
                     panel.border = element_blank(),
                     axis.line = element_line(), legend.position = "none") +
  xlab("Bulk RNA-seq p-value") + ylab("SCEPTRE p-value") + ggtitle("Xie bulk RNA-seq validation") +
  geom_point(mapping = aes(x = bulk_pval, y = sceptre_pval), data = filter(to_plot, is_arl15), size = 2) +
  annotate(geom = "text", x = 1e-12, y = 1e-14, label = "ARL15", col = "firebrick3")

if (FALSE) {
  require(gap)
  qqunif(u = p_vals_bulk$p_value, type = "unif", logscale = TRUE, col = "blue", lcol = "red", ci = TRUE, main = "ARL15-enh bulk QQ-plot")
}

# Legend
# ex <- tibble(x = 1:5, y = 1:5, Method = c("SCEPTRE", "Monocle NB", "Improved NB", "Virtual FACS", "scMAGeCK")) %>% mutate(Method = factor(x = Method, levels = c("SCEPTRE", "Monocle NB", "Improved NB", "Virtual FACS", "scMAGeCK"), labels = c("SCEPTRE", "Monocle NB", "Improved NB", "Virtual FACS", "scMAGeCK")))
#p_vert <- ggplot(data = ex, mapping = aes(x = x, y = y, col = Method)) + geom_point() + scale_colour_manual(values = setNames(plot_colors[c("sceptre", "gasperini_nb", "hf_nb", "hypergeometric", "scMAGeCK")], NULL), name = "Method") + theme_bw() + theme(legend.title = element_blank())
# legend <- get_legend(plot = p_vert)
#ggsave(plot = legend, filename = paste0(manuscript_figure_dir, "/Figure3/vert_legend.pdf"), width = 1.5, height = 1.5)
# library(patchwork)
# p_c <- p_xie_neg + inset_element(legend, left = 0.1, right = 0.4, bottom = 0.45, top = 0.95)

# Arrange figure 3 through cowplot
middle_row <- plot_grid(p_b, p_xie_neg, align = "hv", nrow = 1, ncol = 2, labels = c("b", "c"),  hjust = -4)
bottom_row <- plot_grid(p_d, p_e, align = "hv", nrow = 1, ncol = 2, labels = c("d", "e"), hjust = -4)
final_plot <- plot_grid(p_a, middle_row, bottom_row, nrow = 3, labels = c("a", "", ""), hjust = -4, rel_heights = c(0.8, 1, 0.8))
#save(final_plot, file = 'Figure3_plot.RData')
ggsave(filename = paste0(manuscript_figure_dir, "/Figure3/subfigures_a_thru_e.pdf"), plot = final_plot, device = "pdf",
       scale = 1, width = 7, height = 8)
