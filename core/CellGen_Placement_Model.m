classdef CellGen_Placement_Model <CellGen_Model
%CELLGEN_PLACEMENT_MODEL   The template class from which all plugins for
% object (cells, nucleus etc) placement are derived.
%
%CELLGEN_PLACEMENT_MODEL methods:
%       pick_positions      - A function that returns the position
%       where an object will be placed
%
%   See also  CellGen_Model,Clustered_Placement, Random_Placement
%
%
%%
  
  
  methods (Abstract)
    pos=pick_positions(numeric)
  end
  
  
end
