function Img_NCS_comb = NCS_block_enc(img_rgb)
    Img_NCS_comb = blockproc(img_rgb, [8, 8], @(block_struct) NCS_enc(block_struct.data));
end

function blk_comb = NCS_enc(blk)
    [Img_newColorSpace, T_pca, Offset_pca, means] = NewColorSpace_enc(blk);
    blk_comb = zeros([8 8 3]);
    blk_comb = Img_newColorSpace;
    blk_comb(1:3,1:3,4) = T_pca;
    blk_comb(1:3,1,5) = Offset_pca;
    blk_comb(1,1:3,6) = means;
end