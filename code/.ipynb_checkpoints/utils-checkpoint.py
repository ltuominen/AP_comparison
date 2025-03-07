import os 
from nibabel.freesurfer.io import read_annot
import numpy as np
import pandas as pd

def get_annot_labels(annot, subjects_dir=None):
    subjects_dir = subjects_dir or os.environ.get('SUBJECTS_DIR')
    if not subjects_dir:
        raise EnvironmentError("SUBJECTS_DIR is not set. Please set the environment variable or pass it as an argument.")
    
    aparc = os.path.join(os.environ['SUBJECTS_DIR'], 'fsaverage', 'label', annot)
    labels, _ , _ = read_annot(aparc)
    labels = [i-1 if i>3 else i for i in labels] # good lord
    return(labels)

def rois2maps(lh_dat, rh_dat, column, lh_labels, rh_labels): 
    lh_dat.index = range(1, len(lh_dat) + 1)
    lh_dict = lh_dat[column].to_dict()
    lh_map = np.array([lh_dict.get(index) for index in lh_labels], dtype=np.float64)
    
    rh_dat.index = range(1, len(rh_dat) + 1)
    rh_dict = rh_dat[column].to_dict()
    rh_map = np.array([rh_dict.get(index) for index in rh_labels], dtype=np.float64)

    lhrh_map = {'left': lh_map, 'right': rh_map}
    return(lhrh_map)
