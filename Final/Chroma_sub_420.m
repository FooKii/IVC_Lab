function img_chr_sub = Chroma_sub_420(img_CS)
%%  Chroma subsampling using 4:2:0
%   Input       Img_CS                            Image in new ColorSpace
%   Output      Img_chr_sub                       Chroma subsampled image
%% Blkprocess
    [h,w,~] = size(img_CS);
    img_chr_sub = blockproc(img_CS, [2, 4], @(block_struct) chr_sub(block_struct.data));
    for i = 2:3
       layer = img_chr_sub(:,:,i);
       new_layer = zeros(size(layer));
       layer(layer==9999) = [];
       new_layer(1:h/2,1:w/2) = reshape(layer,[h/2,w/2]);
       img_chr_sub(:,:,i) = new_layer;
       
    end
end

function blk_chr_sub = chr_sub(blk)
%% This function applies 4:2:0 chroma subsampling
    blk_chr_sub = 9999*ones(size(blk));
    blk_chr_sub(:,:,1) = blk(:,:,1);
    for i = 2:3
        blk_chr_sub(1,1,i) = blk(1,1,i);
        blk_chr_sub(1,2,i) = blk(1,3,i);
    end
end

