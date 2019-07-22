function img_cell = transform_ycbcr2cell_5(img_ycbcr)
%% Transform Error_ycbcr with Cspace+ 420 into err_cell
%   Input         img_ycbcr
%   Output        img_cell
%% After experienment, Icbcr->RGB->Cspace better than Icbcr -> Cspace
[h,w,~] = size(img_ycbcr);
% First convert back to RGB
    img_rgb = ictYCbCr2RGB(img_ycbcr);
% Apply tranform into new color space
    %[Img_newColorSpace, T_pca, Offset_pca, means] = NewColorSpace_enc(img_rgb);
     img_NCS = NCS_block_enc(img_rgb);
% Apply 4:2:0 subsample
    img_chr_sub = Chroma_sub_420(img_NCS(:,:,1:3));
 
% Restruct into cells
    img_cell{1} = img_chr_sub(:,:,1);
    for i = 2:3
        layer = img_chr_sub(:,:,i);
        img_cell{i} = layer(1:h/2,1:w/2);
    end
    img_cell{4} = img_NCS(:,:,4);
    img_cell{5} = img_NCS(:,:,5);
    img_cell{6} = img_NCS(:,:,6);
end