function [Img_newColorSpace, T_pca, Offset_pca, means] = NewColorSpace_enc(img_rgb)
%% This function transform an RGB Image into a new color_space
%  Input       Img_rgb (16*16*3)              Original image in RGB format
%  Output      Img_newColorSpace (16*16*3)    Transformed image in new Color Space
%  Output      T_pca                          Tranfrom Matrix
%  Output      Offset_pca                     Offset for the value range
%  Output      means                          mean value of each layer
%% PCA - Preparation: Centralise
    [h,w,d] = size(img_rgb);
    training_data = zeros(h*w, d);
    for i = 1:d
        layer = img_rgb(:,:,i);
        % RGB_Stack(i,:) = layer(:) - mean(layer(:)); % Stack for latter use
        means(i) = mean(layer(:));
        training_data(:,i) = layer(:) - means(i);
    end
%% Apply PCA
     % coeff should be [3, 3]
    cov_mat = cov(training_data);
    [V,D] = eig(cov_mat);
    [D,I] = sort(diag(D),'descend');
    V = V(:, I);
    % New basis by first d
    T_pca = V';
%% Get Matrix T and Offset
    T_pca(1,:) = T_pca(1,:)/norm(T_pca(1,:), 1)*219/255;
    Scale_cb = (224/255)/(sum(abs(T_pca(2,:))));
    T_pca(2,:) = T_pca(2,:).* Scale_cb;
    T_pca(3,:) = T_pca(3,:).* Scale_cb;
    Offset_pca = zeros([3,1]);
    Offset_pca(1) = 16;
    Offset_pca(2) = -1*sum_neg(T_pca(2,:))*255+16;
    Offset_pca(3) = -1*sum_neg(T_pca(3,:))*255+16;
   
%% Apply the Color Space transform
    Img_stacked = T_pca * training_data';% + Offset_pca;
    for i = 1:d
        Img_newColorSpace(:,:,i) = reshape(Img_stacked(i,:), [h,w]);  % Should be 16x16x3
    end
end

function Neg_sum = sum_neg(vec)
%% Sum up all the negative elements
    Neg_sum = 0;
    for i = 1: size(vec,2)
        if vec(i) < 0;
            Neg_sum = Neg_sum + vec(i);
        end
    end
end