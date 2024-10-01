classdef CellGen_Class_Type
%CELLGEN_CLASS_TYPE   The template class from which all
%plugins for adding artifacts to individual cells are derived.
%
%CELLGEN_CLASS_TYPE enumeration:
%  CellGen type allowed for plugin's arguments.
%    -number: A integer or double
%    -cellgen_shape_model: any CellGen_Object_Model object that you can
%      find in plugins/shape/
%    -cellgen_marker_model: any Marker_Operation_Queue containing
%      objects from plugins/marker. Defne a marker on a shape done by a
%      series of operations.
%    -list: any kind of list, usually string list.
%    -file_name: a file path (used to load SLML MATLAB files).
%
%See also  CellGen_Model,Cell_Staining_Artifacts, Out_Of_Focus_Cells
%
%
%%
  
    
    enumeration
        number,cellgen_shape_model,cellgen_marker_model,list,file_name
    end
end

