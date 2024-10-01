function cellgen_result=cellgen_engine(cellgen_params,number_of_images)

%cellgen_engine  function
%  [cellgen_result] = cellgen_engine(cellgen_params, number_of_images)
%
%   The cellgen_params parameter .
%   The number_of_images parameter .
%
%
%%

if(nargin==1)
  number_of_images=1;
end

number_of_subpopulations=length(cellgen_params.subpopulations);

%Initial checks to see if necessary items have been defined
for subpop=1:number_of_subpopulations
  if(~isempty(properties(cellgen_params.subpopulations{subpop}.objects)))
    shapes=properties(cellgen_params.subpopulations{subpop}.objects);
    for i=1:length(shapes)
      if(isempty(...
          cellgen_params.subpopulations{subpop}.objects.(shapes{i}).model))
        cellgen_params.notifier.message=...
          [shapes{i} ' In Subpopulation ' num2str(subpop)...
          ' Has No Model Defined'];
        disp(cellgen_params.notifier.message);
        notify(cellgen_params.notifier,'error_thrown');
        refresh;
        error(cellgen_params.notifier.message);
        
      elseif(~isa(...
          cellgen_params.subpopulations{subpop}.objects.(shapes{i}).model,...
          'CellGen_Object_Model'))
        cellgen_params.notifier.message=[shapes{i}...
          ' In Subpopulation ' num2str(subpop)...
          ' Has Model Of Incorrect Class'];
        disp(cellgen_params.notifier.message);
        notify(cellgen_params.notifier,'error_thrown');
        refresh;
        error(cellgen_params.notifier.message);
        
      end
    end
    
  else
    cellgen_params.notifier.message=['Subpopulation '...
      num2str(subpop) ' Has No Objects Defined'];
    disp(cellgen_params.notifier.message);
    notify(cellgen_params.notifier,'error_thrown');
    refresh;
    error(cellgen_params.notifier.message);
    
  end
  
  if(isempty(properties(cellgen_params.subpopulations{subpop}.markers)))
    cellgen_params.notifier.message=[' In Subpopulation '...
      num2str(subpop) ' No Marker Has Been Defined'];
    disp(cellgen_params.notifier.message);
    notify(cellgen_params.notifier,'error_thrown');
    refresh;
    error(cellgen_params.notifier.message);
  end
  
  if(isempty(cellgen_params.subpopulations{subpop}.placement))
    disp(['In Subpopulation ' num2str(subpop)...
      ' Placement Not Defined:Using Random']);
    cellgen_params.subpopulations{subpop}.placement=...
      Random_Placement();
  end
  
end

for subpop=1:number_of_subpopulations
  cellgen_params.subpopulations{subpop}.calculate_shape_draw_order;
  cellgen_params.subpopulations{subpop}.calculate_marker_draw_order;
end

if(~isfield(cellgen_params,'overlap'))
  cellgen_params.overlap= Overlap_Specification;
  disp(['Overlap Not Defined. Assuming No Overlap Allowed'...
    ' Between Cells.']);
end
cellgen_params.overlap.construct_overlap_matrix(...
  cellgen_params.subpopulations);
cellgen_result=struct;
for img_num=1:number_of_images
  %Stores the subpopulation number of each cell
  subpopulation_number_of_cell=zeros(cellgen_params.number_of_cells,1);
  %Stores the shape of every object in every cell. indexed by cell number
  object_structure=struct;
  %Generating cell-wise object shapes
  current_image_mask=false(cellgen_params.cellgen_image_size);
  cell_masks=cell(cellgen_params.number_of_cells,1);
  full_result=cell(length(cellgen_params.overlap.ordered_shape_list),1);
  for cell_number=1:cellgen_params.number_of_cells
    current_cell=struct;
    %Replace by function with specified weights
    subpopulation_number=...
      discrete_prob(cellgen_params.population_fractions);
    subpopulation_number_of_cell(cell_number)=subpopulation_number;
    draw_order=(cellgen_params.subpopulations{...
      subpopulation_number}.object_draw_order);
    number_of_objects=length(draw_order);
    overlap_acceptable=false;
    iteration_counter=0;
    
    while(~overlap_acceptable)
      
      overlap_acceptable=true;
      for object_number=1:number_of_objects
        prerendered_shapes_in_cell=cell(0);
        prerendered_shape_names=...
          cellgen_params.subpopulations{...
          subpopulation_number}.object_dependancy_struct.(...
          draw_order{object_number});
        for i=1:length(prerendered_shape_names)
          prerendered_shapes_in_cell{i}=...
            current_cell.(prerendered_shape_names{i});
        end
        pos=cellgen_params.subpopulations{...
          subpopulation_number}.placement.pick_positions(...
          current_image_mask);
        shape=cellgen_params.subpopulations{...
          subpopulation_number}.objects.(...
          draw_order{object_number}).model ...
          .make_shape([pos(1),pos(2)],current_image_mask,...
          prerendered_shapes_in_cell);
        current_cell.(draw_order{object_number})=shape;
        obj_num=cellgen_params.overlap.shape_to_number_map{...
          subpopulation_number}(draw_order{object_number});
        if(~overlap_check(full_result,shape,...
            cellgen_params.overlap.overlap_matrix,obj_num))
          overlap_acceptable=false;
          %disp('check failed');
        end
      end
      
      iteration_counter=iteration_counter+1;
      if(iteration_counter>255)
        cellgen_params.notifier.message=...
          ['Cannot Fit Any More Cells: Rendering With '...
          num2str(cell_number-1) ' cells'];
        disp(cellgen_params.notifier.message);
        refresh;
        number_of_cells=cell_number-1;%What if zero?
        subpopulation_number_of_cell=...
          subpopulation_number_of_cell(1:number_of_cells);
        cell_masks=cell_masks(1:number_of_cells);
        object_structure=object_structure(1:number_of_cells);
        break;
        %error('cannot fit in any more cells');
        %disp('cannot fit in any more cells');
      end
      
    end
    
    if(overlap_acceptable)
      shapes=fieldnames(current_cell);
      cell_masks{cell_number}=false(cellgen_params.cellgen_image_size);
      for i=1:length(shapes)
        current_image_mask=current_image_mask|current_cell.(shapes{i});
        cell_masks{cell_number}=cell_masks{cell_number}|current_cell.(shapes{i});
        object_structure(cell_number).(shapes{i})=sparse(current_cell.(shapes{i}));
        obj_num=cellgen_params.overlap.shape_to_number_map{subpopulation_number}(shapes{i});
        full_result{obj_num}=[full_result{obj_num} {sparse(current_cell.(shapes{i}))}];
      end
      number_of_cells=cell_number;
    else
      break;
    end
    
    
  end
  final_mask=current_image_mask;
  overlap_counter=zeros(cellgen_params.cellgen_image_size);
  for cell_number=1:number_of_cells
    overlap_counter=overlap_counter+cell_masks{cell_number};
  end      
  marker_structure=struct;
  for cell_number=1:number_of_cells
    
    subpopulation_number=subpopulation_number_of_cell(cell_number);
    
    %draw_order=(cellgen_params.subpopulations{subpopulation_number}.marker_draw_order);
    number_of_marker_shapes=length(cellgen_params.subpopulations{...
      subpopulation_number}.marker_draw_order_objects);
    %calculate mask from other cells
    other_cells_mask=(overlap_counter-cell_masks{cell_number})>0;
    %other_cells_mask=false(cellgen_params.cellgen_image_size);
    %for i=1:number_of_cells
    %  if(i~=cell_number)
    %    other_cells_mask=other_cells_mask|cell_masks{i};
    %  end
    %end
    
    for marker_shape_counter=1:number_of_marker_shapes
      
      temp=cellgen_params.subpopulations{...
        subpopulation_number}.marker_draw_order_names{marker_shape_counter};
      marker_name=temp{1};
      shape_name=temp{2};
      operations=cellgen_params.subpopulations{...
        subpopulation_number}.marker_draw_order_objects{...
        marker_shape_counter}.operations;
      number_of_operations=length(operations);
      current_marker=sparse(cellgen_params.cellgen_image_size(1),...
        cellgen_params.cellgen_image_size(2));
      for operation_number=1:number_of_operations
        op=operations{operation_number};
        needed_shapes=op.needed_shape_list();
        shapes_passed=cell(length(needed_shapes),1);
        for i=1:length(needed_shapes)
          shape_name1= cellgen_params.subpopulations{...
            subpopulation_number}.find_shape_name(needed_shapes{i});
          shapes_passed{i}=object_structure(cell_number).(shape_name1);
        end
        needed_marker_shapes=op.prerendered_marker_list();
        markers_passed=cell(length(needed_marker_shapes),1);
        for i=1:length(needed_marker_shapes)
          [marker_name1 shape_name1]=...
            cellgen_params.subpopulations{...
            subpopulation_number}.find_marker_name(needed_marker_shapes{i});
          markers_passed{i}=marker_structure(cell_number).(...
            shape_name1).(marker_name1);
        end
        current_shape_mask=object_structure(cell_number).(shape_name);
        current_marker=op.Apply(current_marker,current_shape_mask,...
          other_cells_mask,shapes_passed,markers_passed);
      end
      marker_structure(cell_number).(shape_name).(marker_name)=...
        sparse(current_marker);
    end
  end
  
  %composite images
  compositing_matrices=cell(number_of_subpopulations,1);
  composite_cell_images=struct;
  blurred_cell_images=struct;
  for subpop=1:number_of_subpopulations
    cells_in_subpop=find(subpopulation_number_of_cell==subpop);
    shapes=properties(cellgen_params.subpopulations{subpop}.objects);
    object_masks=cell(length(cells_in_subpop),length(shapes));
    for cell_number=1:length(cells_in_subpop)
      for shape_number=1:length(shapes)
        object_masks{cell_number,shape_number}=...
          object_structure(cells_in_subpop(cell_number)).(shapes{shape_number});
      end
    end
    if(isempty(cellgen_params.subpopulations{subpop}.compositing))
      cellgen_params.subpopulations{subpop}.compositing=Default_Compositing();
      disp(['Compositing Not Defined For Subpopulation '...
        num2str(subpop) '. Using Defaults.']);
    end
    compositing_matrices{subpop}=cellgen_params.subpopulations{...
      subpop}.compositing.calculate_compositing_matrix(object_masks);
    %     composite_cell_images()
    
    for cell_number=1:length(cells_in_subpop)
      %         composite=sparse(cellgen_params.cellgen_image_size(1),cellgen_params.cellgen_image_size(2));
      weight_masks=cell(length(shapes),1);
      %         composite_mask=false(cellgen_params.cellgen_image_size(1),cellgen_params.cellgen_image_size(2));
      number_shapes_overlapped=sparse(...
        cellgen_params.cellgen_image_size(1),...
        cellgen_params.cellgen_image_size(2));
      for shape_number1=1:length(shapes)
        number_shapes_overlapped=number_shapes_overlapped+double(...
          object_structure(cells_in_subpop(cell_number)).(...
          shapes{shape_number1}));
        weight_masks{shape_number1}=sparse(...
          cellgen_params.cellgen_image_size(1),...
          cellgen_params.cellgen_image_size(2));
      end
      max_overlap=max(number_shapes_overlapped(:));
      
      for shape_number1=1:length(shapes)
        temp_mask=(number_shapes_overlapped==1)&object_structure(...
          cells_in_subpop(cell_number)).(shapes{shape_number1});
        weight_masks{shape_number1}(temp_mask)=compositing_matrices{...
          subpop}(shape_number1,shape_number1);
        for shape_number2=1:shape_number1-1
          for overlap_number=2: max_overlap
            temp_mask=(number_shapes_overlapped==overlap_number)&...
              object_structure(cells_in_subpop(cell_number)).(...
              shapes{shape_number1})&...
              object_structure(cells_in_subpop(cell_number)).(...
              shapes{shape_number2});
            weight_masks{shape_number1}(temp_mask)=...
              weight_masks{shape_number1}(temp_mask)+...
              compositing_matrices{subpop}(shape_number1,...
              shape_number2)/nchoosek( overlap_number,2);
            weight_masks{shape_number2}(temp_mask)=...
              weight_masks{shape_number2}(temp_mask)+...
              compositing_matrices{subpop}(shape_number2,...
              shape_number1)/nchoosek( overlap_number,2);
          end
        end
      end
      markers=properties(cellgen_params.subpopulations{subpop}.markers);
      for marker_number=1:length(markers)
        composite_cell_images(cells_in_subpop(cell_number)).(...
          markers{marker_number})=...
          sparse(cellgen_params.cellgen_image_size(1),...
          cellgen_params.cellgen_image_size(2));
        for shape_number=1:length(shapes)
          composite_cell_images(cells_in_subpop(cell_number)).(...
            markers{marker_number})=...
            composite_cell_images(cells_in_subpop(cell_number)).(...
            markers{marker_number})+...
            weight_masks{shape_number}.*...
            marker_structure(cells_in_subpop(cell_number)).(...
            shapes{shape_number}).(markers{marker_number});
        end
      end
      
      
    end
    
    markers=properties(cellgen_params.subpopulations{subpop}.markers);
    
    operation_list=cellgen_params.subpopulations{subpop}.cell_artifacts;
    %     if(~isempty(operation_list))
    %
    %     end
    if(~isempty(cells_in_subpop))
      temp=cell(length(cells_in_subpop),length(markers));
      for marker_number=1:length(markers)
        for cell_number=1:length(cells_in_subpop)
          temp{cell_number,marker_number}=composite_cell_images(...
            cells_in_subpop(cell_number)).(markers{marker_number});
        end
      end
      
      for op_number=1:length(operation_list)
        
        temp=operation_list{op_number}.Apply(temp);
      end
      
      
      for marker_number=1:length(markers)
        for cell_number=1:length(cells_in_subpop)
          
          blurred_cell_images(cells_in_subpop(cell_number)).(...
            markers{marker_number})=temp{cell_number,marker_number};
        end
      end
    end
    
    
    
    
  end
  
  color_group_struct=calculate_color_groups(cellgen_params.subpopulations);
  color_names=fieldnames(color_group_struct);
  combined_cell_images=struct;
  
  for color_number=1:length(color_names)
    
    temp_intensity_list=cell(0);
    marker_list=color_group_struct.(color_names{color_number});
    counter=1;
    for i=1:size(marker_list,1)
      cells_in_subpop=find(subpopulation_number_of_cell==marker_list{i,1});
      for cell_number=1:length(cells_in_subpop)
        temp_intensity_list{counter}=blurred_cell_images(...
          cells_in_subpop(cell_number)).(marker_list{i,2});
        counter=counter+1;
      end
    end
    
    
    combined_cell_images.(color_names{color_number})=...
      merge_cell_intensities(temp_intensity_list,0.85);
    
  end
  
  temp=cell(length(color_names),1);
  for color_number=1:length(color_names)
    temp{color_number}= combined_cell_images.(color_names{color_number});
  end
  
  if(isfield(cellgen_params,'image_artifacts'))
    operation_list=cellgen_params.image_artifacts;
    for op_num=1:length(operation_list)
      temp=operation_list{op_num}.Apply(temp);
    end
    
  else
    disp('Image Level Artifacts Not Defined. Assuming None.');
    
  end
  for color_number=1:length(color_names)
    combined_cell_images.(color_names{color_number})=temp{color_number};
  end
  
  
  combined_channel_image=zeros(cellgen_params.cellgen_image_size(1),...
    cellgen_params.cellgen_image_size(2),3);
  for color_number=1:length(color_names)
    
    combined_channel_image(:,:,1)=...
      min(combined_channel_image(:,:,1)+...
      Colors.(color_names{color_number}).R*...
      combined_cell_images.(color_names{color_number}),1);
    combined_channel_image(:,:,2)=...
      min(combined_channel_image(:,:,2)+...
      Colors.(color_names{color_number}).G*...
      combined_cell_images.(color_names{color_number}),1);
    combined_channel_image(:,:,3)=...
      min(combined_channel_image(:,:,3) +...
      Colors.(color_names{color_number}).B*...
      combined_cell_images.(color_names{color_number}),1);
  end
  
  cellgen_result(img_num).subpopulation_numbers_of_cells=...
    subpopulation_number_of_cell;
  cellgen_result(img_num).RGB_image=combined_channel_image;
  cellgen_result(img_num).mask_of_object_by_cell=object_structure;
  cellgen_result(img_num).marker_on_object_by_cell=marker_structure;
  cellgen_result(img_num).channel_images=combined_cell_images;
end
