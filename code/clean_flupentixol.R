# Clean data flupentixol 
library(tidyverse)
library(fs)
library(lme4)
library(lmerTest)

# load data
base <- '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'

files <- c(
  bl  = path(base, "data", "Flupentixol", "Corrected_New_EONCKS_BL_MRI_20191129.csv"),
  m12 = path(base, "data", "Flupentixol", "Corrected_New_EONCKS_M12_MRI_20191129.csv"),
  m24 = path(base, "data", "Flupentixol", "Corrected_New_EONCKS_M24_MRI_20191129.csv")
) %>% map(read_csv, show_col_types = FALSE)

# define parcels for some later use
parcels <- c("bankssts", "caudalanteriorcingulate", "caudalmiddlefrontal", "cuneus",
             "entorhinal", "fusiform", "inferiorparietal", "inferiortemporal",
             "isthmuscingulate", "lateraloccipital", "lateralorbitofrontal", "lingual",
             "medialorbitofrontal", "middletemporal", "parahippocampal", "paracentral",
             "parsopercularis", "parsorbitalis", "parstriangularis", "pericalcarine",
             "postcentral", "posteriorcingulate", "precentral", "precuneus",
             "rostralanteriorcingulate", "rostralmiddlefrontal", "superiorfrontal",
             "superiorparietal", "superiortemporal", "supramarginal", "frontalpole",
             "temporalpole", "transversetemporal", "insula") %>%
  paste0("_thickness")


# get variables 
demo <- c( "Subject_ID","V01_Type", "Gender", "Age")
keep_regex <- c(parcels, demo)

bl <- files$bl %>% select(matches(paste(keep_regex , collapse = "|"))) %>%
  filter(V01_Type==1)# remove CTR's 

m12 <- files$m12 %>% select(matches(paste(keep_regex , collapse = "|")))
m24 <- files$m24 %>% select(matches(paste(keep_regex , collapse = "|")))

# combine & remove those who don't have data at first timepoint 
dat <- bl %>%
  full_join(m12, by = "Subject_ID") %>%
  full_join(m24, by = "Subject_ID") %>% 
  filter(!is.na(V01_lh_bankssts_thickness)) %>% 
  select(!V01_Type)

# rename some variables
dat <- dat %>% 
  rename_with(~ str_remove(.x, "_thickness$")) %>%    
  rename_with(~ str_remove(.x, "^ROI_")) 

# rename some more
dat <- dat %>%
  rename(Age              = V01_Age,   
         Gender           = V01_Gender)

# pivot
dat_long <- dat %>%                                  
  pivot_longer(
    cols = matches("^V\\d{2}_"),                    
    names_to   = c("timepoint", "parcel"),          
    names_pattern = "V(\\d{2})_(.+)",               
    values_to  = "thickness"
  )  %>%
  mutate(timepoint = recode(timepoint,"01" = 1L,"09" = 2L,"13" = 3L,.default = NA_integer_)) %>%
  filter((!is.na(Subject_ID)))

# pivot again
dat_wide <- dat_long %>% pivot_wider(id_cols = c('Subject_ID', 'timepoint', 'Age', 'Gender'), 
                                     names_from = parcel, values_from = thickness)

# make sure things make sense 
dat_wide <- dat_wide %>% 
  mutate(
    across(c(Gender, Subject_ID), forcats::as_factor),
    timepoint = as.numeric(as.character(timepoint)),
    Age       = as.numeric(Age)
  )


## #stats 

#control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))

# sanity test -- 
model <- lmer(lh_bankssts ~ timepoint + Age + Gender + 
                (1 | Subject_ID), 
              data = dat_wide)
m <- summary(model)


parcels <- gsub("_thickness", "", parcels)

# fit 
within_group <- matrix(nrow=2*length(parcels), ncol=8)
# group difference 

i=1
for (hemi in c('lh', 'rh')){
  for (parcel in parcels){
    y=paste(hemi, parcel, sep='_')
    f <- reformulate(termlabels = c("timepoint", "Age", "Gender", "(1 | Subject_ID)"), response = y)
    m <- summary(lmer(f, data=dat_wide))
    
    within_group[i,1] <- y
    within_group[i,2] <- m$coefficients['timepoint','Estimate']
    within_group[i,3] <- m$coefficients['timepoint','t value']
    within_group[i,4] <- m$coefficients['timepoint','Pr(>|t|)']
    
    within_group[i,5] <- m$sigma
    within_group[i,6] <- m$coefficients["timepoint", "df"]
    within_group[i,7] <- as.numeric(within_group[i,2]) / as.numeric(within_group[i,5])
    J <- 1 - (3 / (4 * as.numeric(within_group[i,6]) - 1))
    within_group[i,8] <- J * as.numeric(within_group[i,7])
    i=i+1
    }
  
}


df <- data.frame(within_group)
names(df) <- c('parcel','estimate', 't-value', 'p-value', 'sigma', 'df', 'cohen_d', 'hedges_g')
file=path(base, "data", "Flupentixol", "Flupentixol_parcelwise.csv")
write.csv(df, file=file, row.names = FALSE)


