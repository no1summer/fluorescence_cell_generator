classdef Clustered_Placement <CellGen_Placement_Model
  %Clustered_Placement placement plugin used to for cell clusters
  %
  %Clustered_Placement Properties:
  %   number_of_clusters - Number Of Clusters Of Cells in Image
  %     Default value : 2
  %     Range value : 0 to 500
  %   clustering_probability - Probability that a cell will be placed close
  %   to a cluster (otherwise position is random)
  %     Default value : 0.9
  %     Range value : 0 to 1
  %   cluster_width - Positions are selected with gaussian probability
  %   distributions of this width (in pixels) centered at the clusters
  %     Default value : 200
  %     Range value : 1 to Inf
  %   boundary - Boundary Of Image Inside Which No Cells Will be Centered in
  %   pixels
  %     Default value : 100
  %     Range value : 0 to Inf
  %
  %Usage:
  %%Set the Model Placement
  %%Placement refers to the position of cell in an image.
  %%Cells in different subpopulations can display different patterns of
  %%placement (e.g, one type of cells may be clustered or placed randomly)
  %%Placement for cells in a subpopulation are specified through the
  %%placement property in subpopulation, which you need to set the the
  %%appropriate placement model.
  %%Models for placments are classes of type CellGen_Placement_Model, and
  %%are implemented via plugins (usually placed in the 'plugins/placement/'
  %%directory).
  %%Here we choose to have cells placed close to form cluster, and so choose
  %%the 'Clustered_Placement' model.
  %subpop{1}.placement=Clustered_Placement();
  %
  %%Number of clusters of cells in image
  %set(subpop{1}.placement,'number_of_clusters',10);
  %
  %%Positions are selected with gaussian probability
  %%distributions of this width (in pixels) centered at the clusters.
  %set(subpop{1}.placement,'cluster_width',200);
  %
  %%The boundary is the number of pixels around the edge of the image where
  %%no cells are placed.
  %set(subpop{1}.placement,'boundary',100);
  %
  %%Probability that the cell is part of the cluster, non-clustered cells are
  %%placed randomly.
  %set(subpop{1}.placement,'clustering_probability',0.8);
  %
  %
  %%

    
  
  properties
    number_of_clusters;
    clustering_probability;
    cluster_width;
    boundary;
    description='Cells are placed to form clusters';
  end
  
  
  properties (Access=private)
    cluster_positions
  end
  
  
  methods
    function obj=Clustered_Placement()
      obj.number_of_clusters=Parameter('Number Of Clusters',2,CellGen_Class_Type.number,...
        [0,500],'Number Of Clusters Of Cells in Image');
      obj.clustering_probability=Parameter('Clustering Probability',0.9,CellGen_Class_Type.number,...
        [0,1],'Probability that a cell will be placed close to a cluster (otherwise position is random)');
      obj.cluster_width=Parameter('Cluster Width',200,CellGen_Class_Type.number,...
        [1,Inf],'Positions are selected with gaussian probability distributions of this width centered at the clusters');
      obj.boundary=Parameter('Image Boundary',100,CellGen_Class_Type.number,...
        [0,Inf],'Boundary Of Image Inside Which No Cells Will be Centered');
      obj.cluster_positions=rand(obj.number_of_clusters.value,2);
      addlistener(obj.number_of_clusters,'Parameter_Set',@obj.update_cluster_positions);
    end
    
    function pos=pick_positions(obj,full_image_mask,current_cell_mask)
      [max_x,max_y]=size(full_image_mask);
      prob=rand();
      if(prob<obj.clustering_probability.value)
        clusternum=randi(obj.number_of_clusters.value);
        cx=round(obj.boundary.value+obj.cluster_positions(clusternum,1)*(max_x-2*obj.boundary.value));
        cy=round(obj.boundary.value+obj.cluster_positions(clusternum,2)*(max_y-2*obj.boundary.value));
        temp_img=false(max_x,max_y);
        temp_img(cx,cy)=true;
        dists=bwdist(temp_img);%% Possible speed up using meshgrid and explicit calculation?
        %Disallowed regions
        dists(full_image_mask)=Inf;
        dists(1:obj.boundary.value,:)=Inf;
        dists(:,1:obj.boundary.value)=Inf;
        dists(max_x-obj.boundary.value+1:max_x,:)=Inf;
        dists(:,max_y-obj.boundary.value+1:max_y)=Inf;
        %Generate points with given probability
        probs=exp(-dists.^2/obj.cluster_width.value^2);
        probs=probs(:)/sum(probs(:));
        chosen_pixel=discrete_prob(probs');
        [x,y]=ind2sub([max_x,max_y],chosen_pixel);
        pos=[x,y];
      else
        temp_img=true(max_x,max_y);
        temp_img(full_image_mask)=false;
        temp_img(1:obj.boundary.value,:)=false;
        temp_img(:,1:obj.boundary.value)=false;
        temp_img(max_x-obj.boundary.value+1:max_x,:)=false;
        temp_img(:,max_y-obj.boundary.value+1:max_y)=false;
        available_pixels=find(temp_img);
        chosen_pixel=randsample(available_pixels,1);
        [x,y]=ind2sub([max_x,max_y],chosen_pixel);
        pos=[x,y];
      end
    end
    
    function obj=update_cluster_positions(obj,passed_variable,passed_event)
      
      obj.cluster_positions=rand(obj.number_of_clusters.value,2);
      disp('cluster positions selected');
    end
    
  end
  
  
end
