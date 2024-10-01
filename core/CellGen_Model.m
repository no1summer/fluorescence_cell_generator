classdef CellGen_Model <hgsetget
%CELLGEN_MODEL Template abstract class for all cellgen models
%  Template abstract class for all cellgen models, so everything can
%  be be derived from this class.
%  property set and get interface.  hgsetget is a subclass of handle, so
%  any classes derived from hgsetget are handle classes.
%  classdef MyClass < CellGen_Model makes MyClass a subclass of
%  CellGen_Model.
%  Classes that are derived from hgsetget inherit property description 
%  and do inherit methods SET that perform a check to see if the value is a
%  PARAMETER .
%
%CELLGEN_MODEL methods:
%  SET - Set MATLAB object property values performing a check to see
%    if the value is a PARAMETER .
%
%  See also hgsetget
%
%%
  
  
  properties (Abstract)
    description
  end
  
  
  methods
    
    function obj= set(obj,varargin)
      p = inputParser;
      p.KeepUnmatched = true;
      p.parse(varargin{:});
      chosen_fields=fieldnames(p.Unmatched);      
      for i=1:length(chosen_fields)
        %Following works only from Matlab version 2011a, not before
        %if(isprop(obj,chosen_fields{i}))
        %So replaced by:
        if any(strcmp(chosen_fields{i}, properties(obj)))
          if(isa(obj.(chosen_fields{i}),'Parameter'))
            obj.(chosen_fields{i}).value=p.Unmatched.(chosen_fields{i});
          else
            obj.(chosen_fields{i})=p.Unmatched.(chosen_fields{i});
          end
        else
          error([chosen_fields{i} ' is not a valid property']);
        end
      end
      for i=1:length(chosen_fields)
        if(isa(obj.(chosen_fields{i}),'Parameter'))          
          notify(obj.(chosen_fields{i}),'Parameter_Set');
        end
      end
    end
    
  end
  
  
end

