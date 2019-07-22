% %--------------------------
% %------E2-2, b)------------
% %--------------------------
% img = double(imread('data/images/lena.tif'));
% joint_pmf = stats_joint(img);
% H_joint = calc_joint_entropy(joint_pmf);
% %--------------------------
% %------E2-3, b)------------
% %--------------------------
% img = double(imread('data/images/lena.tif'));
% cond_pmf = stats_cond(img);
% H_cond = calc_cond_entropy(cond_pmf);
% %--------------------------
% %------E2-4, Predictor-----
% %--------------------------
% img = double(imread('data/images/lena.tif'));
% % get error-matrix
% [x,y]=size(img);
% for i = 1:y-1
%     e(:,i) = img(:,i) - img(:,i+1);
% end
% % calc H_err
% pmf_eror = stats_marg(e);
% H_error = calc_entropy(pmf_eror,pmf_eror);
% %--------------------------
% %----E2-4,b) min-Predictor-
% %--------------------------
% a1 = 7/8;
% a2 = -1/2;
% a3 = 5/8;
% img = double(imread('data/images/lena.tif'));
% [x,y,z]=size(img);
% d1 = zeros(x,y);
% d2 = d1;
% d3=d2;
% ycbcr = ictRGB2YCbCr(img);
% yy = ycbcr(:,:,1);
% cb = ycbcr(:,:,2);
% cr = ycbcr(:,:,3);
% for i = 2:x
%     for j = 2:y
%         d1(i,j)=a1*yy(i,j-1)+a2*yy(i-1, j-1)+a3*yy(i-1,j);
%     end
% end
% e_entropy= yy - d1;
% a1 = 3/8;
% a2 = -1/4;
% a3 = 7/8;
% for i = 2:x
%     for j = 2:y
%         d2(i,j)=a1*cb(i,j-1)+a2*cb(i-1, j-1)+a3*cb(i-1,j);
%     end
% end
% e_entropy = [e_entropy;cb-d2];
% for i = 2:x
%     for j = 2:y
%         d3(i,j)=a1*cr(i,j-1)+a2*cr(i-1, j-1)+a3*cr(i-1,j);
%     end
% end
% e_entropy = [e_entropy;cr-d3];
% %e_entropy = e_entropy(2:end, 2:end);
% pmf_entropy = stats_marg(e_entropy); % changed plot range from [0 256] tp [-128 128]
% H_err_entropy = calc_entropy(pmf_entropy,pmf_entropy);
%--------------------------
%----E2-5   Huffman coding-
%--------------------------
 %?? change to lena_small.tif?
 img = double(imread('data/images/lena_small.tif'));
 a1 = 7/8;
a2 = -1/2;
a3 = 5/8;
[x,y,z]=size(img);
d1 = zeros(x,y);
d2 = d1;
d3=d2;
ycbcr = ictRGB2YCbCr(img);
yy = ycbcr(:,:,1);
cb = ycbcr(:,:,2);
cr = ycbcr(:,:,3);
for i = 2:x
    for j = 2:y
        d1(i,j)=a1*yy(i,j-1)+a2*yy(i-1, j-1)+a3*yy(i-1,j);
    end
end
e_entropy= yy - d1;
a1 = 3/8;
a2 = -1/4;
a3 = 7/8;
for i = 2:x
    for j = 2:y
        d2(i,j)=a1*cb(i,j-1)+a2*cb(i-1, j-1)+a3*cb(i-1,j);
    end
end
e_entropy = [e_entropy;cb-d2];
for i = 2:x
    for j = 2:y
        d3(i,j)=a1*cr(i,j-1)+a2*cr(i-1, j-1)+a3*cr(i-1,j);
    end
end
e_entropy = [e_entropy;cr-d3];
pmf_entropy = stats_marg(e_entropy);
 % take the pmf from last question
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( pmf_entropy);
%ANSWER%%
% # of codewords 256
% # max. length = 21
% # min. length = 4

%--------------------------
%----E2-6   MILESTONE------
%ANSWER:
%------bitrate 7.28/pixel-- OR 7.3088 OR 8.0296
%---compression-ratio 3.2967
%---PSNR 37.5
%--------------------------
img = double(imread('data/images/lena.tif'));

ycbcr = ictRGB2YCbCr(img);
%?? prefilter?%
Y = ycbcr(:,:,1);
cb = ycbcr(:,:,2);
cb_sampled = resample(cb,1,2,3);
cb_sampled = resample(cb_sampled', 1, 2, 3);
cr = ycbcr(:,:,3);
cr_sampled = resample(cr,1,2,3);
cr_sampled = resample(cr_sampled', 1, 2, 3);
% prediction error Y
[x,y]=size(Y);
diff_y = zeros(size(Y));
pred_y = diff_y;
for i = 2:x
    for j = 2:y
        pred_y(i,j)=a1*Y(i,j-1)+a2*Y(i-1, j-1)+a3*Y(i-1, j);
    end
end
diff_y = Y - pred_y;
diff_y = diff_y(2:end,2:end);
% prediction error cb
[x,y]=size(cb_sampled);
diff_cb = zeros(size(cb_sampled));
pred_cb = diff_cb;
for i = 2:x
    for j = 2:y
        pred_cb(i,j)=a1*cb_sampled(i,j-1)+a2*cb_sampled(i-1, j-1)+a3*cb_sampled(i-1, j);
    end
end
diff_cb =  cb_sampled - pred_cb;
diff_cb = diff_cb(2:end,2:end);
% prediction error cr
[x,y]=size(cr_sampled);
diff_cr = zeros(size(cr_sampled));
pred_cr = diff_cr;
for i = 2:x
    for j = 2:y
        pred_cr(i,j)=a1*cr_sampled(i,j-1)+a2*cr_sampled(i-1, j-1)+a3*cr_sampled(i-1, j);
    end
end
diff_cr = cr_sampled - pred_cr;
diff_cr = diff_cr(2:end,2:end);
% put the ycbcr together
data = round([diff_y(:);diff_cb(:);diff_cr(:)]); % to be transmitte
[s,sss] = size(data);
bytestream = enc_huffman(data+256,BinCode,Codelengths);
%%%DECODE
decoded = dec_huffman(bytestream, BinaryTree, s)-256;
% add up with the prediction

% get ycbcr component
recon_y = Y;
recon_y(2:end,2:end) = reshape(decoded(1:511*511),[511,511]);
recon_y = recon_y + pred_y;
recon_cb = cb_sampled;
recon_cb(2:end,2:end) = reshape(decoded(511*511+1:511*511+255*255),[255,255]);
recon_cb = recon_cb + pred_cb;
recon_cr = cr_sampled;
recon_cr(2:end,2:end) = reshape(decoded(511*511+255*255+1:end),[255,255]);
recon_cr = recon_cr + pred_cr;
% upsample
recon_ycbcr = zeros(size(ycbcr));
recon_ycbcr(:,:,1) = recon_y;
cb_up = resample(recon_cb, 2, 1, 3);
cb_up = resample(cb_up', 2, 1, 3);
recon_ycbcr(:,:,2) = cb_up;
cr_up = resample(recon_cr, 2, 1, 3);
cr_up = resample(cr_up', 2, 1, 3);
recon_ycbcr(:,:,3) = cr_up;
recon_rgb = ictYCbCr2RGB(recon_ycbcr);
subplot(1,2,1);                                                 % prepare to show two images in one window (left)
imshow(uint8(img));                               % show original image
axis image;                                                     % set aspect ratio
title('Original Image')                                         % draw title
    
subplot(1,2,2);                                                 % prepare to show two images in one window (right)
imshow(uint8(recon_rgb));                          % show reconstructed image
axis image;                                                     % set aspect ratio
title('reconstructed Image')  
%%% calc PSNR
mse = calcMSE(img,recon_rgb);
psnr = calcPSNR(mse);
