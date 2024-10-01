classdef CellGen_Object <hgsetget
%CELLGEN_OBJECT   class representing any cellgen object
%  class reprensenting all cellgen object/shape (like a nucleus,
%  cytoplasm, nuclear body etc... ), so everything can
%  be be derived from this class.
%  property set and get interface.  hgsetget is a subclass of handle, so
%  any classes derived from hgsetget are handle classes.
%
%  classdef MyClass < CellGen_Object makes MyClass a subclass of 
%  CellGen_Object.
%
%  Classes that are derived from hgsetget inherit property description
%  and do inherit methods SET that perform a check to see if the value is
%  a PARAMETER.
%
%  CELLGEN_MODEL methods:
%    SET - Set MATLAB object property values performing a check to
%    see if the value is a PARAMETER .
%
%  See also hgsetget
%
%%
  
  
  properties
    model;
  end
  
  
  methods
    
    function obj=CellGen_Object()
      obj.model=[];
    end
    
  end
  
  
end
