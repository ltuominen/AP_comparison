# Clean data flupentixol 
library(tidyverse)
base <- '/Users/laurituominen/Documents/Research/AP_cortical_thickness_v2'

bl_file <- paste0(base, '/data/Flupentixol/Corrected_New_EONCKS_BL_MRI_20191129.csv')
m12_file <- paste0(base, '/data/Flupentixol/Corrected_New_EONCKS_M12_MRI_20191129.csv')
m24_file <- paste0(base, '/data/Flupentixol/Corrected_New_EONCKS_M24_MRI_20191129.csv')

bl <- read_csv(bl_file)
m12 <- read_csv(m12_file)
m24 <- read_csv(m24_file)


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

demo <- c( "Subject_ID", "Gender", "Age", "ScanSite", "Scanner_Sequence")
vars <- c(parcels, demo)
bl <- bl %>% select(matches(paste(vars , collapse = "|")))
names(bl) <- gsub('ROI_', '', names(bl))
m12 <- m12 %>% select(matches(paste(vars , collapse = "|")))
m24 <- m24 %>% select(matches(paste(vars , collapse = "|")))

dat <- merge()

