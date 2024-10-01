classdef CellGen_ImageArtifact_Operation <CellGen_Model
%CellGen_ImageArtifact_Operation template class from which all
%plugins for adding artifacts to an image are derived.
%
%CellGen_ImageArtifact_Operation methods:
%  Apply - function that returns a a cell array(#colors,1).
%    Each element of the cell is a matrix(image_height,image_width).
%    The value of each element of this matrix is the pixel intensity of
%    all the cells(biological) for one color channel.
%
%See also  CellGen_Model,
%Add_Basal_Brightness, Linear_Image_Gradient
%
%
%%
  
  
  properties
  end
  
  
  methods (Abstract)
    Apply(numeric);
  end
  
  
end
