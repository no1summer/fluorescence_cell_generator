# CellGen
This is the repo for a synthetic image generator to generate image and labeled image pairs of yeast cells under fluorescence microscopy.

There are two parts in the repo

**1. Cell generating algorithm + true segmentation label**

**2. Test of existing deep learning cell segmentation algorithm - cellpose**

## Part 1. CellGen

My cell generating algorithm is developed inspired by the SimuCell.

**_Rajaram, Satwik, et al. "SimuCell: a flexible framework for creating synthetic microscopy images." Nature methods 9.7 (2012): 634-635._**

Depending on your matlab package, there might be some additional library required for running 'cellgen_single_marker.m'

For random_sample function, machine learning package is required. 

For curve fitting, cscvn package is required. 

Running 'cellgen_single_marker.m' should give you two images, one is generated cell image and the other one is the mask image

![https://github.com/no1summer/fluorescence_cell_generator/blob/main/example_figure1.tif]
![https://github.com/no1summer/fluorescence_cell_generator/blob/main/example_figure2.tif]

Then I will run 'cellgen_single_marker_runinbatch.m' which generate 100 cell images as well as true mask in its the subfolder. 

## Part 2. Cellpose segmentation on the generated cell images

This is the command I use for running the cellpose over generated images
'''
python -m cellpose --dir ~/output_img/ --pretrained_model cyto3 --diameter 20 --save_png --verbose --no_npy --savedir ~/output_img/cellpose_img
'''
Here I am using pretrained model cyto3. 

Then I run the 'cellpose_accuracy.m' which calculates the percentage of the cellpose mask out of the true mask.

The result shows an accuracy of 99.46%.

