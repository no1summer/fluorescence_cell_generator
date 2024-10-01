%calculate the percentage of pixels the cellpose segment out of the true mask
accuracy(1:100)=0;
for i = 1:100
    cp_mask_img = imread (strcat('output_img/cellpose_img/image_',num2str(i,'%04g'),'_cp_masks.png'));
    true_mask = imread (strcat('output_img/true_mask/mask_',num2str(i,'%04g'),'.png'));
    accuracy(i) = length(intersect(find(cp_mask_img),find(true_mask)))/length(find(true_mask));
end 

disp(mean(accuracy));

% the result shows an accuracy of 99.46%