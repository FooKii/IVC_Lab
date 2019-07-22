clc; clear;
%% Parameter qScale to have multiple R-D points
k=1;
for qScale = 0.2:0.2:2
%% E5-1a, still Image compression, fore0020.bmp
foreman1st_rgb = double(imread('foreman0020.bmp'));
[h,w,~] = size(foreman1st_rgb);
%% Tranform 1st frame with hq-JPEG 
img = double(imread('foreman0020.bmp'));
[PSNR_1st_frame, bitrate_1st_frame, num_irr, recon_1st_frame] = E4Milestone(img,0,0,0,0,701,qScale); % Use Lena_small
%% E5-1b Load frames and transform to YCbCr
recon_1st_frame_ycbcr = ictRGB2YCbCr(recon_1st_frame);
%frame{1} = recon_1st_frame_ycbcr;
dec_frame_ycbcr{1} = recon_1st_frame_ycbcr;

%% Transfered 1st Frame
foreman_1st_recon_rgb = ictYCbCr2RGB(recon_1st_frame_ycbcr);
mse = calcMSE(foreman1st_rgb,foreman_1st_recon_rgb);
PSNR_1st = calcPSNR(mse);
bitrate_frame{1} = bitrate_1st_frame;
%% PSNR = 34.57
% Bitrate = 1.64
%% E5-1b Load frames and transform to YCbCr
%frame{1} = recon_1st_frame_ycbcr;
dataset_name = 'foreman00';
for i = 20 :40
    file_name = strcat(dataset_name, int2str(i),'.bmp');
    ori_rgb{i-19} = double(imread(file_name));
    frame_ycbcr{i-19} = ictRGB2YCbCr(double(imread(file_name)));
end
%% debug
%dec_frame_ycbcr{1} = frame_ycbcr{1};
%% E5-1c
%  Function SSD.m�� Apply on the first 2 frames for training Huffman
motion_vectors_index_1st_frame = SSD(dec_frame_ycbcr{1}, frame_ycbcr{2});

%% E5-1d
rec_2nd_frame_ycbcr = SSD_rec(dec_frame_ycbcr{1}, motion_vectors_index_1st_frame);
%% Apply chroma subsampling before error_calculation
Error_2nd_frame = rec_2nd_frame_ycbcr - frame_ycbcr{2};
%% Transform Error into Cspace+ 420
error_transformed_cell = transform_ycbcr2cell_5(Error_2nd_frame);
error_transformed_cel3{1} = error_transformed_cell{1};
error_transformed_cel3{2} = error_transformed_cell{2};
error_transformed_cel3{3} = error_transformed_cell{3};
Encoded_Error = IntraEncode_final_err(error_transformed_cel3, qScale);
%% E5-1e
% Train Huffman table using motion_vectors_index_1st_frame
h_mv = histogram(motion_vectors_index_1st_frame(:),1:82,'Normalization','probability');
pmf = h_mv.Values;
[BinaryTree_mv, HuffCode_mv, BinCode_mv, Codelengths_mv] = buildHuffman( pmf);
%% E5-1f
% Train Huffman table using Error_2nd_frame
% Encode the Error using Intra_encode from Chapter4.
% Min is -255 Max is 153 ==> take -300 ~ 1000
h_err = histogram(Encoded_Error,-600:1100,'Normalization','probability');
pmf = h_err.Values;
[BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err] = buildHuffman( pmf);
%% E5-1g
PSNR{1} = PSNR_1st;
% Implementation for the whole video sequence
for i = 2: length(frame_ycbcr)
    ref_im = dec_frame_ycbcr{i-1};
    im = frame_ycbcr{i};
    % START of Pseudo code: [err_im, MV] = motionEstimation(im1, ref_im)
    motion_vec_ind = SSD(ref_im, im);
    rec_im = SSD_rec(ref_im, motion_vec_ind); % rec_im in CSpace
    Error_ycbcr = im - rec_im;
    %% Before error transfer to Chroma sub
    Error_cell = transform_ycbcr2cell_5(Error_ycbcr);
    Error_cell3{1} = Error_cell{1};
    Error_cell3{2} = Error_cell{2};
    Error_cell3{3} = Error_cell{3};
    %%
%     bytestream_mv = enc_huffman(motion_vec_ind(:),BinCode_mv,Codelengths_mv);
    bit_num_mv = codeLength(motion_vec_ind(:),Codelengths_mv);
    % Decode the motion_vecs
%     Decoded_Motion_Vecs = dec_huffman(bytestream_mv, BinaryTree_mv, length(motion_vec_ind(:)));
    Decoded_Motion_Vecs = motion_vec_ind;
    % The Error_image's transfer will be simulated through a wrapper:
    % E4Mulestone.m
    [bitnum_frame, recon_frame_err_cell] = Transmission_err(Error_cell3,...
        0,qScale,601,BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err);
    % Now consider both mv_bytestream and err_bytestream for the bitrate
    bits_number = bit_num_mv + bitnum_frame;
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
      recon_err(:,:,4) = Error_cell{4};
      recon_err(:,:,5) = Error_cell{5};
      recon_err(:,:,6) = Error_cell{6};
      recon_err_rgb = NCS_block_dec(recon_err);
%     recon_err_rgb = NewColorSpace_dec(recon_err,T_pca, Offset_pca, means);
      recon_err_ycbcr = ictRGB2YCbCr(recon_err_rgb);
    %%
    dec_frame_ycbcr{i} = recon_pred + recon_err_ycbcr;
    %% Now calculate the PSNR
    %frame_recon_rgb = NewColorSpace_dec(dec_frame_CSpace{i}, T_pca{i}, Offset_pca{i}, means{i});
    frame_recon_rgb = ictYCbCr2RGB(dec_frame_ycbcr{i});
    Ori_RGB = ori_rgb{i};
    %% for debug
%     subplot(1,2,1)
% imshow(uint8(frame_recon_rgb));
% subplot(1,2,2)
% imshow(uint8(ictYCbCr2RGB(recon_pred)));
%%
    MSE = calcMSE(Ori_RGB, frame_recon_rgb);
    PSNR{i} = calcPSNR(MSE);
end
Final_bitrate{k} = mean([bitrate_frame{1:length(frame_ycbcr)}]);
Final_PSNR{k} = mean([PSNR{1:length(frame_ycbcr)}]);
k=k+1
end