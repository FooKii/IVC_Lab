function  img_rgb = NCS_block_dec(Img_NCS_comb)
    img_rgb = blockproc(Img_NCS_comb, [8, 8], @(block_struct) NCS_dec(block_struct.data));
end

function blk_rgb = NCS_dec(blk)
    img_NCS = blk(:,:,1:3);
    T = blk(1:3,1:3,4);
    offset = blk(1:3,1,5);
    means = blk(1,1:3,6);
    blk_rgb = NewColorSpace_dec(img_NCS,T,offset,means);
end