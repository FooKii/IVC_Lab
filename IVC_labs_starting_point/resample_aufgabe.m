img =double(imread('data/images/sail.tif'));
% normalization
img = img/256;
% wrap round
wrapper = padarray(img, [4, 4], 'symmetric', 'both');
% filter
   % which filter to use??
  % resample using for loop?
recon = img;
for i = 1:3
        d1 = resample(wrapper(:,:,i), 1, 2, 3);
        % resample in second axis
        d = resample(d1', 1, 2, 3);
        % upsample now
        d = d(3:386, 3:258);
        d = padarray(d, [2 2], 'symmetric', 'both');
        u1 = resample(d, 2, 1, 3);
        up = resample(u1', 2, 1, 3);
        recon(:,:,i) = up(5:516, 5:772);
end



% show image
subplot(1,3,1);                                                 % prepare to show two images in one window (left)
imagesc(img);                               % show original image
axis image;                                                     % set aspect ratio
title('Original Image')                                         % draw title
    
subplot(1,3,2);                                                 % prepare to show two images in one window (right)
imagesc(recon,[0,1]);                          % show reconstructed image
axis image;                                                     % set aspect ratio
title('reconstructed Image')  
% Calculate PSNR
mse = calcMSE(img, recon);
psnr = calcPSNR(mse);

% sail.tif => 30.7 dB
% lena.tif => 33.67 dB