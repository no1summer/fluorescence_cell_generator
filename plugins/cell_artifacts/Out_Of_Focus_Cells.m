classdef Out_Of_Focus_Cells <CellGen_CellArtifact_Operation
%Out_Of_Focus_Cells cell artifact plugin used to make a specified
%subpopulation's fraction of cells blurred, to mimic an out of focal
%plane effect.
%
%Out_Of_Focus_Cells Properties:
%   fraction_blurred - Proportion of cell which will blured for the 
%   specific subpopulation.
%     Default value : 0.1
%     Range value   : 0 to 1
%   blur_radius      - Blur radius in pixels. 1 is pretty small,
%   chosen to produce a very slight smoothing effect on all cells.
%     Default value : 10
%     Range value   : 0 to Inf
%
%Usage:
%op=Out_Of_Focus_Cells();
%set(op,'fraction_blurred',1);
%set(op,'blur_radius',2);
%subpop{1}.add_cell_artifact(op);
%
%
%%

  properties
    fraction_blurred
    blur_radius
    description=['Blur a Subset of Cells. Fraction of blurred cells'...
      ', and the amount of blurring can be specified'];
  end
  
  
  methods
    function obj=Out_Of_Focus_Cells()
      obj.fraction_blurred=Parameter('Fraction of Blurred Cells',...
        0.1,CellGen_Class_Type.number, [0,1],...
        'Fraction of Cells that are out of focus [0-none, 1-all]');
      obj.blur_radius=Parameter('Blur Radius (in pixels) ',10,...
        CellGen_Class_Type.number, [0,Inf],...
        ['Sigma of Gaussian Blur Performed on Cells '...
        '[0- no blur, Infinity-complete blur]']);
    end
    
    function output_images=Apply(obj,input_images)
      [number_of_cells,number_of_markers]=size(input_images);
      output_images=cell(number_of_cells,number_of_markers);
      sigma=obj.blur_radius.value;
      [x_max,y_max]=size(input_images{1,1});
      
      for cell_number=1:number_of_cells
        is_blurred=(discrete_prob([obj.fraction_blurred.value,...
          1-obj.fraction_blurred.value])==1);
        if(is_blurred)
          for marker_number=1:number_of_markers
            temp=zeros(x_max,y_max);            
            [row,col]=find(input_images{cell_number,marker_number}>0);
            % This may be too lenient. Maybe 3*sigma, also with
            % replicate in blurring, do we need to go out so far?
            x1=max(min(row)-4*sigma,1);
            x2=min(max(row)+4*sigma,x_max);
            y1=max(min(col)-4*sigma,1);
            y2=min(max(col)+4*sigma,y_max);            
            cropped_img=input_images{cell_number,...
              marker_number}(x1:x2,y1:y2);
            h=fspecial('gaussian',sigma,4*sigma);
            blurred_img=imfilter(full(cropped_img),h,'replicate');
            temp(x1:x2,y1:y2)=blurred_img;
            output_images{cell_number,marker_number}=temp;
          end
        else
          for marker_number=1:number_of_markers
            output_images{cell_number,marker_number}=...
              input_images{cell_number,marker_number};
          end
        end
      end      
    end
    
  end
  
  
end
