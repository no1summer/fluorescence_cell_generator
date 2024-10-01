classdef Centered_Cytoplasm_Model <CellGen_Object_Model
  %Centered_Cytoplasm_Model cytoplasm model plugin creating an elliptical
  %cell centered around an other object (typically a nucleus). 
  %The model for the shape itself is a variation on the one used by 
  % Lehmussola et al in Proceedings of the IEEE, Vol. 96, No. 8. 
  % (16 July 2008), pp. 1348-1360, doi:10.1109/JPROC.2008.925490
  %
  %Centered_Cytoplasm_Model Properties:
  %   radius - Average Cell Radius
  %     Default value : 15
  %     Range value : 0 to Inf
  %   eccentricity - Measure of Non-Uniformity: 0=spherical, 1=straight line
  %     Default value : 0.5
  %     Range value : 0 to 1
  %   randomness - Measure of Non-Uniformity: 0=elliptical, 1=random
  %     Default value : 0.1
  %     Range value : 0 to 1
  %   centered_around - The cytoplasm is centered around this 
  %   (usually a nucleus)
  %     Default value : -
  %
  %Usage:
  %%Create a new Object 'cytoplasm'
  %add_object(subpop{2},'cytoplasm');
  %
  %%Set the Centered_Cytoplasm_Model model
  %subpop{2}.objects.cytoplasm.model=Centered_Cytoplasm_Model;
  %
  %Set the parameters
  %set(subpop{2}.objects.cytoplasm.model,'radius',60);
  %set(subpop{2}.objects.cytoplasm.model,'eccentricity',0.6);
  %set(subpop{2}.objects.cytoplasm.model,'randomness',0.2);
  %
  %%The cytoplasm is drawn around the nucleus
  %set(subpop{2}.objects.cytoplasm.model,'centered_around',...
  %subpop{2}.objects.nucleus);
  %
  %
  %%
  
    
  
  properties
    radius;
    eccentricity;
    randomness;
    centered_around;
    description='An Elliptical Cytoplasm centered around a nucleus';
  end
  
  
  methods
    function obj=Centered_Cytoplasm_Model()
      obj.radius=Parameter('Cell Radius',50,CellGen_Class_Type.number,...
        [0,Inf],'Average Cell Radius');
      obj.eccentricity=Parameter('Cell Eccentricity',0.5,...
        CellGen_Class_Type.number,...
        [0,1],'Measure of Non-Uniformity: 0=spherical, 1=straight line');
      obj.randomness=Parameter('Extent of Variation',0.1,...
        CellGen_Class_Type.number,...
        [0,1],'Measure of Non-Uniformity: 0=elliptical,1= random');
      obj.centered_around=Parameter('Centered Around',[],...
        CellGen_Class_Type.cellgen_shape_model,...
        [],'The cytoplasm is centered around this (usually a nucleus)');
    end
    
    function output_shape=make_shape(obj,pos,current_image_mask,...
        prerendered_shapes)
      nucleus=prerendered_shapes{1};
      dists=bwdist(~nucleus);
      [nucRad,I]=max(dists(:));
      [nuc_center_x,nuc_center_y]=ind2sub(size(nucleus),I);
      step = 0.1;
      t = (0:step:1)'*2*pi;
      t1 = (obj.randomness.value*rand(size(t))+sin(t));
      t2 = sqrt(1-obj.eccentricity.value^2)*(obj.randomness.value*rand(size(t))+cos(t));
      t1(end) = t1(1);
      t2(end) = t2(1);
      theta=2*pi*rand();
      rotmat=[cos(theta) -sin(theta);sin(theta) cos(theta)];
      object = [t2';t1'];
      object=rotmat*object;
      dists=sum(object.^2,1);
      inds=find(dists<double(nucRad)/obj.radius.value);
      for i=1:length(inds)
        object(:,inds(i))=...
          object(:,inds(i))*double(nucRad)/(obj.radius.value*dists(inds(i)));
      end
      points=max(obj.radius.value,...
        double(nucRad))*object'+repmat([nuc_center_x,nuc_center_y],...
        size(object,2),1);
      object=points';
      pp_nuc = cscvn(object);
      object = ppval(pp_nuc, linspace(0,max(pp_nuc.breaks),1000));
      object = round(object);
      output_shape = roipoly(false(size(nucleus)),object(2,:),object(1,:));
      output_shape=output_shape|nucleus;
    end
    
    function pre_obj_list=prerendered_object_list(obj)
      pre_obj_list={obj.centered_around.value};
    end
    
  end
  
  
end
