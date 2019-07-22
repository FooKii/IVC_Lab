Lena_rgb       = double(imread('lena.tif'));
[Img_newColorSpace, T_pca, Offset_pca, means] = NewColorSpace_enc(Lena_rgb);
lena_ycbcr = ictRGB2YCbCr(Lena_rgb);
img_chr_sub = Chroma_sub_420(lena_ycbcr);
img_ycbcr_recon = Chroma_recon_420(img_chr_sub);
Lena_recon = ictYCbCr2RGB(img_ycbcr_recon);
mse = calcMSE(Lena_rgb,Lena_recon);
PSNR_ycbcr = calcPSNR(mse);

lena_ycocg = ictrgb2ycocg(Lena_rgb);
img_chr_sub = Chroma_sub_420(lena_ycocg);
img_ycocg_recon = Chroma_recon_420(img_chr_sub);
lena_recon = ictycocg2rgb(img_ycocg_recon);
mse = calcMSE(Lena_rgb,lena_recon);
PSNR_ref_cocg = calcPSNR(mse);
%% Test chroma subsampling
img_chr_sub = Chroma_sub_420(Img_newColorSpace);
img_CSub_recon = Chroma_recon_420(img_chr_sub);
Lena_recon_ncs = NewColorSpace_dec(img_CSub_recon, T_pca, Offset_pca, means);
%Lena_recon = ictYCbCr2RGB(Lena_recon);
 mse = calcMSE(Lena_rgb,Lena_recon_ncs);
 PSNR_ref = calcPSNR(mse);

 img_NCS = NCS_block_enc(Lena_rgb);
 img_chr_sub = Chroma_sub_420(img_NCS(:,:,1:3));
img_CSub_recon = Chroma_recon_420(img_chr_sub);
img_CSub_recon(:,:,4:6) = img_NCS(:,:,4:6);
Lena_recon_ncs = NCS_block_dec(img_CSub_recon);
 mse = calcMSE(Lena_rgb,Lena_recon_ncs);
 PSNR_NCS = calcPSNR(mse);
