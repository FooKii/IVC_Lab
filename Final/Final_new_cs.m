clc; clear;
%% Parameter qScale to have multiple R-D points
k=1;
for qScale = 1
%% E5-1a, still Image compression, fore0020.bmp
foreman1st_rgb = double(imread('foreman0020.bmp'));
%% Tranform 1st frame into 420 form
[h,w,~] = size(foreman1st_rgb);
[Img_newColorSpace, T_pca1, Offset_pca1, means1] = NewColorSpace_enc(foreman1st_rgb);
img_chr_sub = Chroma_sub_420(Img_newColorSpace);
foreman1st_cell{1} = img_chr_sub(:,:,1);
for i = 2:3
   layer = img_chr_sub(:,:,i);
   foreman1st_cell{i} = layer(1:h/2,1:w/2);
end
%% Transmission
[bitnum, recon_1st_frame_CS_cell] = Transmission(...
    foreman1st_cell,1,0.5, 101); 
bitrate{1} = bitnum/(h*w);
% End
%% recon foreman 1st frame
%% recon is now cell, recon to 3 layer matrix
recon_1st = zeros(size(foreman1st_rgb));
recon_1st(:,:,1) = recon_1st_frame_CS_cell{1};
for i = 2:3
    layer = recon_1st(:,:,i);
    layer(1:h/2,1:w/2) = recon_1st_frame_CS_cell{i};
    recon_1st(:,:,i) = layer;
end
    
%% Transfered 1st Frame
img_CSub_recon = Chroma_recon_420(recon_1st);
foreman_1st_recon_rgb = NewColorSpace_dec(img_CSub_recon, T_pca1, Offset_pca1, means1);
mse = calcMSE(foreman1st_rgb,foreman_1st_recon_rgb);
PSNR_1st = calcPSNR(mse);
%% PSNR = 34.57
% Bitrate = 1.64
%% E5-1b Load frames and transform to YCbCr
%frame{1} = recon_1st_frame_ycbcr;
dec_frame_CSpace{1} = img_CSub_recon;
dec_frame_ycbcr{1} = ictRGB2YCbCr(foreman_1st_recon_rgb);
dataset_name = 'foreman00';
for i = 20 :40
    file_name = strcat(dataset_name, int2str(i),'.bmp');
    ori_rgb{i-19} = double(imread(file_name));
    [frame{i-19},T_pca{i-19}, Offset_pca{i-19},means{i-19}] = ...
        NewColorSpace_enc(double(imread(file_name)));
    frame_CSub{i-19} = Chroma_sub_420(frame{i-19});
    frame_ycbcr{i-19} = ictRGB2YCbCr(double(imread(file_name)));
end
%% E5-1c
%  Function SSD.m�� Apply on the first 2 frames for training Huffman
motion_vectors_index_1st_frame = SSD(dec_frame_ycbcr{1}, frame_ycbcr{2});

%% E5-1d
rec_2nd_frame_CS = SSD_rec(dec_frame_ycbcr{1}, motion_vectors_index_1st_frame);
%% Apply chroma subsampling before error_calculation
rec_2nd_sub = Chroma_sub_420(rec_2nd_frame_CS);
for i = 1:3
    Error_2nd_frame{i} = rec_2nd_sub(:,:,i) - frame_CSub{2}(:,:,i);
    if i > 1
        layer = Error_2nd_frame{i};
        Error_2nd_frame{i} = layer(1:h/2,1:w/2);
    end
end
%% E5-1e
% Train Huffman table using motion_vectors_index_1st_frame
h_mv = histogram(motion_vectors_index_1st_frame(:),1:82,'Normalization','probability');
pmf = h_mv.Values;
[BinaryTree_mv, HuffCode_mv, BinCode_mv, Codelengths_mv] = buildHuffman( pmf);
%% E5-1f
% Train Huffman table using Error_2nd_frame
% Encode the Error using Intra_encode from Chapter4.


Encoded_Error = IntraEncode_final(Error_2nd_frame, qScale);

% Min is -255 Max is 153 ==> take -300 ~ 1000
h_err = histogram(Encoded_Error,-600:1100,'Normalization','probability');
pmf = h_err.Values;
[BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err] = buildHuffman( pmf);
%% E5-1g
PSNR{1} = PSNR_1st;
% Implementation for the whole video sequence
for i = 2: length(frame)
    ref_im = dec_frame_ycbcr{i-1};
    im = frame_ycbcr{i};
    % START of Pseudo code: [err_im, MV] = motionEstimation(im1, ref_im)
    motion_vec_ind = SSD(ref_im, im);
    rec_im = SSD_rec(ref_im, motion_vec_ind); % rec_im in CSpace
    rec_im_Csub = Chroma_sub_420(rec_im);
    Error_ref = im - rec_im;
    %% Before error transfer to Chroma sub
    for in_loop = 1:3
    Error{in_loop} = frame_CSub{in_loop}(:,:,in_loop) - rec_im_Csub(:,:,in_loop);
        if in_loop > 1
            layer = Error{in_loop};
            Error{in_loop} = layer(1:h/2,1:w/2);
        end
    end
    %%
    bytestream_mv = enc_huffman(motion_vec_ind(:),BinCode_mv,Codelengths_mv);
    % Decode the motion_vecs
    Decoded_Motion_Vecs = dec_huffman(bytestream_mv, BinaryTree_mv, length(motion_vec_ind(:)));
    Decoded_Motion_Vecs = reshape(Decoded_Motion_Vecs',size(motion_vec_ind));
    % The Error_image's transfer will be simulated through a wrapper:
    % E4Mulestone.m
    [bitnum_frame, recon_frame_err_cell] = Transmission(Error,...
        0,qScale,601,BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err);
    % Now consider both mv_bytestream and err_bytestream for the bitrate
    bits_number = numel(bytestream_mv)* 8 + bitnum_frame;
    bitrate_frame{i} = bits_number/(h*w);
    % Recon the frame{i} in YCbCr
    recon_pred = SSD_rec(ref_im, Decoded_Motion_Vecs);
    % recon = recon_pred + error
    %% RECON cell to matrix
    recon_frame_err = zeros(size(foreman1st_rgb));
    recon_frame_err(:,:,1) = recon_frame_err_cell{1};
    for in_loop = 2:3
        layer = recon_frame_err(:,:,in_loop);
        layer(1:h/2,1:w/2) = recon_frame_err_cell{in_loop};
        recon_frame_err(:,:,in_loop) = layer;
    end
    recon_err = Chroma_recon_420(recon_frame_err);
    %%
    dec_frame_ycbcr{i} = recon_pred + recon_err;
    %% Now calculate the PSNR
    %frame_recon_rgb = NewColorSpace_dec(dec_frame_CSpace{i}, T_pca{i}, Offset_pca{i}, means{i});
    frame_recon_rgb = ictYCbCr2RGB(dec_frame_ycbcr{i});
    Ori_RGB = ori_rgb{i};
    %% for debug
    subplot(1,2,1)
imshow(uint8(frame_recon_rgb));
subplot(1,2,2)
imshow(uint8(Ori_RGB));
%%
    MSE = calcMSE(Ori_RGB, frame_recon_rgb);
    PSNR{i} = calcPSNR(MSE);
end
Final_bitrate{k} = mean([bitrate_frame{1:length(frame)}]);
Final_PSNR{k} = mean([PSNR{1:length(frame)}]);
k=k+1;
end