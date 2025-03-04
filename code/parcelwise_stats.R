library(lme4)
library(lmerTest)
library('nlme')
'''
primary analysis associated with change in gray matter structure (cortical thickness).Time was measured (interval between scans,in days),and a treatment-group by time interaction was modeled,
with sex and age as covariates.A fixed intercept was included,along with a random intercept to account for within-participant variability 
and one to account for sit evariability.Scan site is included in the error term rather than as a covariate,because as a covariate 
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
base = '/Users/laurituominen/Documents/Research/STOP-PD'
dat_file = paste0(base, '/data/STOPPD_merged.csv')

dat <- read.csv(dat_file)

# define as factors 
dat$sex <- as.factor(dat$sex)
dat$randomization <- as.factor(dat$randomization)
dat$site_x <- as.factor(dat$site_x)
dat$STUDYID <- as.factor(dat$STUDYID)



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

formula <- reformulate(termlabels =  c("Total_ap_exposure","Age","Sex","group","eTIV.x"), response = "rh_isthmuscingulate_thickness_delta" )
?reformulate

for (hemi in c('lh', 'rh')){
  for (parcel in parcels){
    y=paste(hemi, parcel, 'delta', sep='_')
    f <- reformulate(termlabels = c("1+ randomization * dateDiff + age + sex + (1 | STUDYID) + (1 | site_x)"),  response = y )
    
    print(f)
    m <- lmer(f, data=dat)
  }
    
}


# model: thickness ~ 1+ randomization * dateDiff + age + sex, random =~ 1|STUDYID + site_x

