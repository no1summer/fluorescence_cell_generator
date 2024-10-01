# CellGen
This is the repo for a synthetic image generator to generate image and labeled image pairs of yeast cells under fluorescence microscopy.

There are two parts in the repo

1. Cell generating algorithm + true segmentation label 
2. Comparison of two existing segmentation algorithm - cellprofiler and cellpose 

Cellprofiler using intensity threshold for segmentation while the cellpose is a pretrained deep learning method. 

My cell generating algorithm is developed inspired by the SimuCell.

Rajaram, Satwik, et al. "SimuCell: a flexible framework for creating synthetic microscopy images." Nature methods 9.7 (2012): 634-635.
