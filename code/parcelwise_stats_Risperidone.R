# process & stats data for risperidone 
library(tidyverse)
library(fs)
library(lme4)
library(lmerTest)

# load data
base <- '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'

dat <- read_csv(path(base, "data", "Risperidone", "Risperidone_data.csv"), show_col_types = FALSE) %>%
  filter(Group==2) %>% select(!c("...75", "Estimated_Total_Intracranial_Volume"))

dat <- dat %>% 
  rename_with(~ str_remove(.x, "_thickness$"))

dat <- dat %>% 
  mutate(
    across(c(Gender, Master_ID), forcats::as_factor),
    Week = as.numeric(as.character(Week)),
    Age       = as.numeric(Age)
  )


parcels <- c("bankssts", "caudalanteriorcingulate", "caudalmiddlefrontal", "cuneus",
             "entorhinal", "fusiform", "inferiorparietal", "inferiortemporal",
             "isthmuscingulate", "lateraloccipital", "lateralorbitofrontal", "lingual",
             "medialorbitofrontal", "middletemporal", "parahippocampal", "paracentral",
             "parsopercularis", "parsorbitalis", "parstriangularis", "pericalcarine",
             "postcentral", "posteriorcingulate", "precentral", "precuneus",
             "rostralanteriorcingulate", "rostralmiddlefrontal", "superiorfrontal",
             "superiorparietal", "superiortemporal", "supramarginal", "frontalpole",
             "temporalpole", "transversetemporal", "insula") 



# sanity test -- 
model <- lmer(lh_bankssts ~ Week + Age + Gender + 
                (1 | Master_ID), 
              data = dat)
m <- summary(model)


# fit 
within_group <- matrix(nrow=2*length(parcels), ncol=8)
# group difference 

i=1
for (hemi in c('lh', 'rh')){
  for (parcel in parcels){
    y=paste(hemi, parcel, sep='_')
    f <- reformulate(termlabels = c("Week", "Age", "Gender", "(1 | Master_ID)"), response = y)
    m <- summary(lmer(f, data=dat))
    
    within_group[i,1] <- y
    within_group[i,2] <- m$coefficients['Week','Estimate']
    within_group[i,3] <- m$coefficients['Week','t value']
    within_group[i,4] <- m$coefficients['Week','Pr(>|t|)']
    
    within_group[i,5] <- m$sigma
    within_group[i,6] <- m$coefficients["Week", "df"]
    within_group[i,7] <- as.numeric(within_group[i,2]) / as.numeric(within_group[i,5])
    J <- 1 - (3 / (4 * as.numeric(within_group[i,6]) - 1))
    within_group[i,8] <- J * as.numeric(within_group[i,7])
    i=i+1
  }
  
}


df <- data.frame(within_group)
names(df) <- c('parcel','estimate', 't-value', 'p-value', 'sigma', 'df', 'cohen_d', 'hedges_g')
file=path(base, "data", "Risperidone", "Risperidone_parcelwise.csv")
write.csv(df, file=file, row.names = FALSE)

