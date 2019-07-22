% 1.3 color-transform
% p. 50% ?
% bitrate = 12
% psnr = 27.6 dB
img =double(imread('data/images/sail.tif'));
% normalization
img = img/256;
ycbcr = ictRGB2YCbCr(img);

for i = 2:3
    ds_img = resample(ycbcr(:,:,i),1,2,3);
    ds_img = resample(ds_img',1,2,3);
    cmps(:,:,i) = ds_img;
end

% reconstruction
recon = zeros(size(img));
recon(:,:,1) = ycbcr(:,:,1);
for i = 2:3
    us_img = resample(cmps(:,:,i),2,1,3);
    us_img = resample(us_img',2,1,3);
    recon(:,:,i) = us_img;
end
rgb = ictYCbCr2RGB(recon);

subplot(1,2,1);                                                 % prepare to show two images in one window (left)
imagesc(img);                               % show original image
axis image;                                                     % set aspect ratio
title('Original Image')                                         % draw title
    
subplot(1,2,2);                                                 % prepare to show two images in one window (right)
imagesc(rgb,[0,1]);                          % show reconstructed image
axis image;                                                     % set aspect ratio
title('reconstructed Image')  
% PSNR
mse = calcMSE(img,rgb);
psnr = calcPSNR(mse);
