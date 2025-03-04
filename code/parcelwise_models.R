library('tidyverse')

parcels = c('bankssts_thickness','caudalanteriorcingulate_thickness',
           'caudalmiddlefrontal_thickness', 'cuneus_thickness',
           'entorhinal_thickness', 'fusiform_thickness',
           'inferiorparietal_thickness', 'inferiortemporal_thickness',
           'isthmuscingulate_thickness', 'lateraloccipital_thickness',
           'lateralorbitofrontal_thickness', 'lingual_thickness',
           'medialorbitofrontal_thickness', 'middletemporal_thickness',
           'parahippocampal_thickness', 'paracentral_thickness',
           'parsopercularis_thickness', 'parsorbitalis_thickness',
           'parstriangularis_thickness', 'pericalcarine_thickness',
           'postcentral_thickness', 'posteriorcingulate_thickness',
           'precentral_thickness', 'precuneus_thickness',
           'rostralanteriorcingulate_thickness',
           'rostralmiddlefrontal_thickness', 'superiorfrontal_thickness',
           'superiorparietal_thickness', 'superiortemporal_thickness',
           'supramarginal_thickness', 'frontalpole_thickness',
           'temporalpole_thickness', 'transversetemporal_thickness',
           'insula_thickness')

# load data
base = '/Users/laurituominen/Documents/Research/STOP-PD'
lh_file = paste0(base, '/data/lh_aparc_stats.txt')
rh_file = paste0(base, '/data/rh_aparc_stats.txt')
demo_file =  paste0(base, '/data/STOPPD_final_clinical.csv')

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

lh_parcels = paste0('lh_', parcels)


lh_long <- 
  
  lh %>% 
  select( -c(lh.aparc.thickness, lh_MeanThickness_thickness, BrainSegVolNotVent, eTIV ))


lh %>% select(!all_of(c(lh.aparc.thickness, lh_MeanThickness_thickness, BrainSegVolNotVent, eTIV)))


lh %>%
  select((c("lh.aparc.thickness", "lh_bankssts_thickness"))

%>%
  pivot_longer( cols = lh_parcels, names_to = 'parcel', values_to = 'thickness')


df_delta <- lh %>%
  group_by(STUDYID) %>%
  summarize(
    all_of(
      lh_parcels, 
      ~ .[timepoint == 02] - .[timepoint == 01],  # subtract timepoint 1 from timepoint 2
      .names = "delta_{.col}"
    )
  )


lh$lh.aparc.thickness
