classdef CellGen_Object_Model <CellGen_Model
%CELLGEN_object_model   The template class from which all plugins for
% defining object models (shapes of cells, nuclei) are defined.
%
%CELLGEN_OBJECT_MODEL methods:
%  make_shape     - A function that returns a binary
%    mask(image_height,image_width) of the shape of the object
%    being drawn.
%  prerendered_object_list - A function that returns a cell array
%    containing all the other objects (nuclei, cells etc) that are
%    required by the make_shape function. Each element is  of type
%    CellGen_Object. This function is used internally by the engine to
%    determine the order in which objects should be drawn.
%
%   See also  CellGen_Model,
%   Centered_Nucleus_Model, SLML_Nucleus_Model
%
%
%%
    
  
  methods (Abstract)    
    make_shape(numeric);
    obj_list=prerendered_object_list(CellGen_Object);
  end
  
  
end

