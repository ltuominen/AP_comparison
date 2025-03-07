library(lme4)
library(lmerTest)


'''
primary analysis associated with change in gray matter structure (cortical thickness).Time was measured (interval between scans,in days),and a treatment-group by time interaction was modeled,
with sex and age as covariates.A fixed intercept was included,along with a random intercept to account for within-participant variability 
and one to account for site variability.Scan site is included in the error term rather than as a covariate,because as a covariate 
it would be modeled to an arbitrary reference site. Treatment group is a binary categorical variable (olanzapine or placebo arm).
'''

'''
# Load the lme4 package
library(lme4)

# Fit the mixed-model regression:
# - Fixed effects: time, treatment, their interaction, sex, and age.
# - Random intercepts: one for each participant and one for each scan site.
model <- lmer(grayMatter ~ time * treatment + sex + age + 
              (1 | participantID) + (1 | site), 
              data = yourData)

# View the model summary
summary(model)
'''


# load data
base = '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'
dat_file = paste0(base, '/data/STOPPD/STOPPD_merged.csv')

dat <- read.csv(dat_file)

# define as factors 
dat$sex <- as.factor(dat$sex)
dat$randomization <- as.factor(dat$randomization)
dat$site_x <- as.factor(dat$site)
dat$STUDYID <- as.factor(dat$STUDYID)
dat$time <- as.numeric(dat$time)
dat$age <- as.numeric(dat$age)


# parcels 
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


# sanity test -- Ok!
model <- lmer(1+ lh_MeanThickness_thickness ~ time * randomization + sex + age + 
                (1 | STUDYID) + (1 | site), 
              data = dat)
m <- summary(model)

control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))


group_difference <- matrix(nrow=2*length(parcels), ncol=3)
# group difference 
i=1
for (hemi in c('lh', 'rh')){
  for (parcel in parcels){
    y=paste(hemi, parcel, sep='_')
    f <- reformulate(termlabels = c("randomization * time + age + sex + (1 | STUDYID) + (1 | site)"),  response = y )
    m <- summary(lmer(f, data=dat, , control = control))
    
    group_difference[i,1] = y
    group_difference[i,2] = m$coefficients[6,4]
    group_difference[i,3] = m$coefficients[6,5]
    i=i+1
  }
    
}
df <- data.frame(group_difference)
names(df) <- c('parcel','t-value', 'p-value')
file=paste0(base, '/data/STOPPD/parcelwise_groupdifference.csv')
write.csv(df, file=file, row.names = FALSE)


# pre-post only in OLZ group 

dat_OLZ <- dat[dat$randomization =='O', ]

# sanity
model <- lmer(lh_MeanThickness_thickness ~ time + sex + age + 
                (1 | STUDYID) + (1 | site), 
              data = dat_OLZ)
m <- summary(model)

within_group <- matrix(nrow=2*length(parcels), ncol=3)
# group difference 
i=1
for (hemi in c('lh', 'rh')){
  for (parcel in parcels){
    y=paste(hemi, parcel, sep='_')
    f <- reformulate(termlabels = c("time + age + sex + (1 | STUDYID) + (1 | site)"),  response = y )
    m <- summary(lmer(f, data=dat_OLZ, , control = control))
    
    within_group[i,1] = y
    within_group[i,2] = m$coefficients[2,4]
    within_group[i,3] = m$coefficients[2,5]
    i=i+1
  }
  
}

df <- data.frame(within_group)
names(df) <- c('parcel','t-value', 'p-value')
file=paste0(base, '/data/STOPPD/parcelwise_withingroup.csv')
write.csv(df, file=file, row.names = FALSE)
