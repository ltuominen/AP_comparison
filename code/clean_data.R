library('tidyverse')

# load data
base = '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'
lh_file = paste0(base, '/data/STOPPD/lh_aparc_stats.txt')
rh_file = paste0(base, '/data/STOPPD/rh_aparc_stats.txt')
demo_file =  paste0(base, '/data/STOPPD/STOPPD_final_clinical.csv')

lh= read_delim(lh_file, delim='\t')
rh = read_delim(rh_file, delim='\t')
demo = read_delim(demo_file, delim=',')

# oh la la! 
lh <- lh %>%
  mutate(
    STUDYID = sapply(strsplit(lh.aparc.thickness, "_"), `[`, 3),
    site =  sapply(strsplit(lh.aparc.thickness, "_"), `[`, 2),
    timepoint = sapply(strsplit(lh.aparc.thickness, "_"), 
                                function(x) {
                                  p4 <- x[4]                 
                                  split_by_dot <- strsplit(p4, "\\.")[[1]]
                                  split_by_dot[1]
                         }
    ))

# rh 
rh <- rh %>%
  mutate(
    STUDYID = sapply(strsplit(rh.aparc.thickness, "_"), `[`, 3),
    site =  sapply(strsplit(rh.aparc.thickness, "_"), `[`, 2),
    timepoint = sapply(strsplit(rh.aparc.thickness, "_"), 
                       function(x) {
                         p4 <- x[4]                 
                         split_by_dot <- strsplit(p4, "\\.")[[1]]
                         split_by_dot[1]
                       }
    ))

dat <- merge(demo, rh)
dat <- merge(dat, lh)
dat$time <- ifelse(dat$timepoint=='02', dat$dateDiff, 0)

dat <- dat %>% relocate("STUDYID", "site", "timepoint","time") %>% select(!c(rh.aparc.thickness, lh.aparc.thickness, BrainSegVolNotVent, PlotLabel, eTIV))

write_csv(dat, paste0(base, '/data/STOPPD/STOPPD_merged.csv'))
