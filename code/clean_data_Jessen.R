library('tidyverse')

# load data
base = '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'
S1 = read.csv(paste0(base, '/data/Jessen/Jessen_S1_Cortical_ROIS_at_baseline.csv'))
S2 = read.csv(paste0(base, '/data/Jessen/Jessen_S2_Cortical_ROIS_at_six-weeks.csv'))
S3 =  read.csv(paste0(base, '/data/Jessen/Jessen_S3_ROI_symmetrized_change.csv'))

strsplit(S1['Thickness.SZ..Mean..SD..'], ' ') 

# S1 
S1<-S1 %>% mutate(
  SZ_mean_base =as.numeric(sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 1)),
  SZ_SD_base =sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 2)
) %>% 
  mutate(
    SZ_SD_base = as.numeric(gsub('\\)', '', gsub('\\(', '', SZ_SD_base)))
  )

S1 <- S1 %>% 
  unite(parcel, c('Hemisphere', 'ROI'))

# S2
S2<-S2 %>% mutate(
  SZ_mean_6weeks =as.numeric(sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 1)),
  SZ_SD_6weeks =sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 2)
) %>%
  mutate(
    SZ_SD_6weeks = as.numeric(gsub('\\)', '', gsub('\\(', '', SZ_SD_6weeks)))
  )

S2 <- S2 %>% 
  unite(parcel, c('Hemisphere', 'ROI'))

dat <- merge(S1,S2, by='parcel')
dat <- dat[,c('parcel', 'SZ_mean_base', 'SZ_SD_base', 'SZ_mean_6weeks', 'SZ_SD_6weeks')]
dat <- dat %>% mutate(
  cohen_d = ( ( SZ_mean_6weeks- SZ_mean_base)/ sqrt( (SZ_SD_base^2 + SZ_SD_6weeks^2)/2))
)

write_csv(dat, paste0(base, '/data/jessen/jessen_cohend.csv'))

