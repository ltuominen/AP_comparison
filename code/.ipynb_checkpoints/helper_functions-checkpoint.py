# functions 
import os 
from nibabel.freesurfer.io import read_annot

def get_annot_labels(annot):
    aparc = os.path.join(os.environ['SUBJECTS_DIR'], 'fsaverage', 'label', annot)
    labels, _ , _ = read_annot(aparc)
    labels = [i-1 if i>3 else i for i in labels] # good lord
    return(labels)


#def assign_values(data, hemi, labels):
#    data = data[data['region'].str.contains(hemi)]
#    data.index = range(1, len(data) + 1)
#    partial_r_dict = data['partial_r'].to_dict()
#    partial_r_dict.update([(0,0), (-1,0)])
#    map = np.array([partial_r_dict.get(index) for index in labels])
#    return(map)
