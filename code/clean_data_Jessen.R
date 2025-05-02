library('tidyverse')
library('fs')

# load data
base = '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'
S1 = read.csv(paste0(base, '/data/Amisulpride/Jessen_S1_Cortical_ROIS_at_baseline.csv'))
S2 = read.csv(paste0(base, '/data/Amisulpride/Jessen_S2_Cortical_ROIS_at_six-weeks.csv'))
S3 =  read.csv(paste0(base, '/data/Amisulpride/Jessen_S3_ROI_symmetrized_change.csv'))

annot = read.csv(paste0(base, '/annot/atlas-desikankilliany.csv'))
annot <- annot[annot['structure']=='cortex',]
annot$parcel<- paste0(annot$hemisphere, '_', annot$label)

# S1 
S1<-S1 %>% mutate(
  SZ_mean_base =as.numeric(sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 1)),
  SZ_SD_base =sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 2)
) %>% 
  mutate(
    SZ_SD_base = as.numeric(gsub('\\)', '', gsub('\\(', '', SZ_SD_base)))
  )

S1 <- S1 %>% mutate(ROI = tolower(ROI)) %>% 
  unite(parcel, c('Hemisphere', 'ROI'))

# S2
S2<-S2 %>% mutate(
  SZ_mean_6weeks =as.numeric(sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 1)),
  SZ_SD_6weeks =sapply(strsplit(Thickness.SZ..Mean..SD.., ' '), `[`, 2)
) %>%
  mutate(
    SZ_SD_6weeks = as.numeric(gsub('\\)', '', gsub('\\(', '', SZ_SD_6weeks)))
  )

S2 <- S2 %>% mutate(ROI = tolower(ROI)) %>% 
  unite(parcel, c('Hemisphere', 'ROI'))

bN = 56 # N of participants at t1
fN = 41 # N of participants at t2
# treating these as independent samples 


dat <- merge(S1,S2, by='parcel')
dat <- left_join(annot, dat, by='parcel' )
dat <- dat[,c('parcel', 'SZ_mean_base', 'SZ_SD_base', 'SZ_mean_6weeks', 'SZ_SD_6weeks')]
dat$parcel <- gsub('L_', 'lh_', dat$parcel )
dat$parcel <- gsub('R_', 'rh_', dat$parcel )

# SD pooled sp = sqrt( ((n1-1)*SD1^2 + (n2 -1)*SD2^2) / (n1+n2-2)
dat <- dat %>% mutate(
  sp = sqrt( ((bN-1)*SZ_SD_base^2 + (fN -1)*SZ_SD_6weeks^2) / (bN+fN-2)),
  J = 1- (3 / (4 * (bN+fN-2) -1))
  ) %>%
  mutate(
    cohen_d = ( ( SZ_mean_6weeks- SZ_mean_base)/ sp)
  ) %>%
  mutate(
    hedges_g = J * cohen_d
  )

file=path(base, "data", "Amisulpride", "Amisulpride_parcelwise.csv")
write.csv(dat, file=file, row.names = FALSE)
