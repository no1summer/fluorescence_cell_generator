classdef CellGen_Compositing_Model<CellGen_Model
%CellGen_Compositing_Model   The template class from which all plugins
%for defining object models (shapes of cells, nuclei) are defined.
%
%CellGen_Compositing_Model methods:
%  calculate_compositing_matrix - A function that returns a matrix
%    containing describing how object the marker level overlap between
%    the different objects.
%
%USED BY THE ENGINE EXCLUSIVELY, DEFINED BY THE COMPOSITING PLUGINS
%
%See also  CellGen_Model, Centered_Nucleus_Model, SLML_Nucleus_Model
%
%
%%

  
  methods (Abstract)
    object_compositing_matrix=calculate_compositing_matrix(cell);
  end
  
  
end
