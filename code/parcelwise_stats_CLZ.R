library(tidyverse)

# load data
base = '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'
lh_file = paste0(base, '/data/CLZ44/stats/lh_aparc_stats.txt')
rh_file = paste0(base, '/data/CLZ44/stats/rh_aparc_stats.txt')

lh= read_delim(lh_file, delim='\t')
rh = read_delim(rh_file, delim='\t')

# extract STUDYID and timepoint from filename
lh <- lh %>% mutate(
  STUDYID = sapply(strsplit(lh.aparc.thickness, "_"), `[`, 1),
  timepoint = sapply(strsplit(lh.aparc.thickness, "_"), 
                     function(x) {
                       p4 <- x[2]                 
                       split_by_dot <- strsplit(p4, "\\.")[[1]]
                       split_by_dot[1]
                     }
) )

rh <- rh %>% mutate(
  STUDYID = sapply(strsplit(rh.aparc.thickness, "_"), `[`, 1),
  timepoint = sapply(strsplit(rh.aparc.thickness, "_"), 
                     function(x) {
                       p4 <- x[2]                 
                       split_by_dot <- strsplit(p4, "\\.")[[1]]
                       split_by_dot[1]
                     }
  ) )

# merge 
dat <- merge(lh, rh, by=c('STUDYID', 'timepoint'))
dat <- dat %>% relocate("STUDYID", "timepoint")  %>% 
  select(!contains(c("rh.aparc.thickness", "lh.aparc.thickness", "lh_MeanThickness_thickness" ,"rh_MeanThickness_thickness" ,"BrainSegVolNotVent","eTIV")))



# gather means and sd's
stats <- dat %>% select(!c("STUDYID")) %>%
  group_by(timepoint) %>%
  summarize(
    across(
      .cols = everything(),
      .fns = list(mean = mean, sd = sd)
    )
  )

# reorganize 
stats <- stats %>% pivot_longer(
  cols = -timepoint,
  names_to = c("parcel", "metric"),    
  names_pattern = "(.*)_(mean|sd)$",   
  values_to = "value"
) %>%
  pivot_wider(
    id_cols      = parcel,
    names_from   = c(timepoint, metric),
    values_from  = value
  ) %>%
  rename(
    mean_POCL = POCL_mean,
    sd_POCL   = POCL_sd,
    mean_PRCL = PRCL_mean,
    sd_PRCL   = PRCL_sd
  )

stats <- stats %>% relocate(parcel, mean_PRCL, sd_PRCL, mean_POCL, sd_POCL)

# calculate effect sizes 
stats <- stats %>% 
  mutate(
  cohen_d = (mean_POCL - mean_PRCL) / 
    sqrt( (sd_PRCL^2 + sd_POCL^2) / 2 )
) %>% 
  mutate(
    hedges_g =  cohen_d * (1 - 3 / (4 * 84 - 9))
  )

file=paste0(base, '/data/CLZ44/stats/parcelwise_effectsize.csv')
write.csv(stats, file=file, row.names = FALSE)

