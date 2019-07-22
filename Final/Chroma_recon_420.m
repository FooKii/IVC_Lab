function img_CSub_recon = Chroma_recon_420(img_chr_sub)
%%  Reconstruct 4:2:0 Chroma subsampled images
%   Input       Img_chr_sub                       Chroma subsampled image
%   Output      img_CSub_recon                    Reconstructed Chroma subsampled image
%% recon the layer strcture
    [h,w,~] = size(img_chr_sub);
    for i = 2:3
       layer = img_chr_sub(:,:,i);
       quarter = layer(1:h/2,1:w/2);
       new_layer = blockproc(quarter, [1, 2], @(block_struct) restruct_layer(block_struct.data));
       img_chr_sub(:,:,i) = new_layer;
    end
%% Blkprocess
    img_CSub_recon = blockproc(img_chr_sub, [2, 4], @(block_struct) recon_chr_sub(block_struct.data));
end

function blk_restruct = restruct_layer(blk)
    new_blk = zeros([2,4]);
    new_blk(1,1) = blk(1);
    new_blk(1,2) = blk(2);
    blk_restruct = new_blk;
end

function blk_recon = recon_chr_sub(blk)
%% This function reconstructed 4:2:0 chroma subsampled image
    blk_recon = blk;
    for i = 2:3
        blk_recon(1:2,1:2,i) = blk(1,1,i);
        blk_recon(1:2,3:4,i) = blk(1,2,i);
    end
end