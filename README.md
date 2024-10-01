# CellGen
This is the repo for a synthetic image generator to generate image and labeled image pairs of yeast cells under fluorescence microscopy.

There are two parts in the repo

**1. Cell generating algorithm + true segmentation label**

**2. Comparison of two existing segmentation algorithm - cellprofiler and cellpose**


Cellprofiler using intensity threshold for segmentation while the cellpose is a pretrained deep learning method. 

**_McQuin, Claire, et al. "CellProfiler 3.0: Next-generation image processing for biology." PLoS biology 16.7 (2018): e2005970._**
**_Stringer, Carsen, et al. "Cellpose: a generalist algorithm for cellular segmentation." Nature methods 18.1 (2021): 100-106._**


My cell generating algorithm is developed inspired by the SimuCell.

**_Rajaram, Satwik, et al. "SimuCell: a flexible framework for creating synthetic microscopy images." Nature methods 9.7 (2012): 634-635._**

There are some library required for running the matlab file

For random_sample function, machine learning package is required. 

For curve fitting, cscvn package is required. 

