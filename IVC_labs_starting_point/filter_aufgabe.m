img =double(imread('data/images/satpic1.bmp'));
% normalization
img = img/256;
% with prefilter
%pre_filtered = prefilterlowpass2d(img);
% without prefilter
 pre_filtered = img;

% show image
subplot(1,3,1);                                                 % prepare to show two images in one window (left)
imagesc(img);                               % show original image
axis image;                                                     % set aspect ratio
title('Original Image')                                         % draw title
    
subplot(1,3,2);                                                 % prepare to show two images in one window (right)
imagesc(pre_filtered,[0,1]);                          % show reconstructed image
axis image;                                                     % set aspect ratio
title('prefiltered Image')  

% down sample
ds_img = downsample(pre_filtered,2);
ds_img = downsample(permute(ds_img,[2 1 3]),2);
% upsample
us_img = upsample(ds_img,2);
us_img = upsample(permute(us_img,[2 1 3]),2);

% post filet
post = prefilterlowpass2d(us_img);
% energy * 4
post = post.*4;
% show reconstructed image
subplot(1,3,3);                                                 % prepare to show two images in one window (right)
imagesc(post,[0,1]);                          % show reconstructed image
axis image;                                                     % set aspect ratio
title('Reconstructed Image') 
% crop the size
% recon = post(3:514,3:514,:);  % change for not prefiltered
mse = calcMSE(img,post);
psnr = calcPSNR(mse);

% with prefilter: PSNR = 27.3 dB
% without prefilter: PSNR = 27.5 dB
% filter w2 with prefilter = 28.6 dB
% filter w2 without prefilter = 26.44 dB
% comment: w2 allows more frequency 