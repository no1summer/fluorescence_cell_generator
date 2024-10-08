classdef Parameter <hgsetget
%PARAMETER class used to define parameters passed from user to CellGen
%plugins.
%The Parameter class is used by CellGen as an interface to accept all
%information input from users.  The Parameter class defines the name,
%type,allowed values, and a description of the input variable.
%
%Parameter properties:
%  name           - a string defining the name of the variable 
%    (this is the name seen in the GUI)
%  value          - default value of the variable (this is used if
%    the value is not specified by the user). The type must match 
%    the variable 'type'.
%  type           - the class/type of the input variable. Allowed 
%    types are defined in CellGen_Class_Type.
%  allowed_values - allowed values for this input variable. The 
%    format depends on the variable 'type'
%  description    - a short string description of the variable. 
%    This will show up as a tooltip in the GUI
%
%Usage:
%overlap=Overlap_Specification;
%overlap.AddOverlap({subpop{1}.objects.cytoplasm,...
%  subpop{2}.objects.cytoplasm},0.05);
%cellgen_data.overlap=overlap;
%
%Parameter events:
%  Parameter_Set      - This is triggered by the script when value 
%    of a parameter is set.
%
%   See also hgsetget, CellGen_Class_Type, isMatFile,
%   CellGen_Model,SLML_Nucleus_Model,Clustered_Placement
%
%%
  
  
  properties
    % NAME a string defining the name of the variable (this is the name 
    %seen in the GUI)
    name
    % TYPE the class/type of the input variable. Allowed types are 
    %defined in CellGen_Class_Type.
    type
    % ALLOWED_VALUES allowed values for this input variable. The format 
    %depends on the variable 'type'
    %       -   CellGen_Class_Type.number: [min,max]
    %       -   CellGen_Class_Type.cellgen_marker_model: [] this is not
    %       needed since it is checked automatically
    %       -   CellGen_Class_Type.cellgen_shape_model: [] this is not
    %       needed since it is checked automatically
    %       -   CellGen_Class_Type.list:
    %       {'opt1','opt2','opt3'} a cell array of strings specifying 
    %       different choices
    %       -   CellGen_Class_Type.file_name: @checkerFunction, a handle
    %           to a function
    %       that checks if the input is valid (see isMatFile as an example
    %           of checkerFunction)
    allowed_values
    % DESCRIPTION a short string description of the variable. This will
    %   show up as a tooltip in the GUI
    description
    
  end
  
  
  properties(Access=private)
    value_private;
  end
  properties(Dependent)
    %VALUE default value of the variable (this is used if the value is
    %not specified by the user). The type must match the variable 'type'.
    value
  end
  
  
  events
    % PARAMETER_SET This is triggered by the script when value of a
    % parameter is set.
    %     It can be used to do pre-processing before the
    %     engine is executed. See SLML_Nucleus_Model and
    %     Clustered_Placement for examples.
    %     Usage: addlistener(obj.filename,'Parameter_Set',@obj.update_model);
    Parameter_Set
  end
  
  
  methods
    
    function obj=Parameter(name,value,type,allowed_values,description)
      obj.name=name;
      obj.value=value;
      obj.type=type;
      if(exist('allowed_values','var'))
        obj.allowed_values=allowed_values;
      end
      if(exist('description','var'))
        obj.description=description;
      end
    end
    
    function value = get.value(obj)
      value = obj.value_private;
    end
    
    function set.value(obj,val)
      if(obj.type==CellGen_Class_Type.number)
        if(val<obj.allowed_values(1)|| val>obj.allowed_values(2))
          error('Value is outside allowed range');
        end
      elseif(obj.type==CellGen_Class_Type.file_name)
        if(~isa(obj.allowed_values,'function_handle'))
          error('allowed_values not a function_handle');
        end
        if(~obj.allowed_values(val))
          error('Not a valid file type');
        end
      elseif(obj.type==CellGen_Class_Type.cellgen_marker_model)
        if(~isa(val,'Marker_Operation_Queue'))
          error('Not a valid marker');
        end
      elseif(obj.type==CellGen_Class_Type.cellgen_shape_model)
        if(~isa(val,'CellGen_Object'))
          error('Not a valid shape');
        end
      elseif(obj.type==CellGen_Class_Type.list)
        if(~ismember(val,obj.allowed_values))
          error('Not a valid list option');
        end
      end
      obj.value_private=val;
    end
  end
  
  
end
