clear;
%% Answer to P-Questions
% p5-1a: Motion estimator block
% p5-1b: Transform: DCT, Entropy coding: Huffman, Color transform: ICbCr
% p5-2a: m*m operations
% p5-2b: same?
% P5-3: Algorithm on slides
% P5-3b: 2m+1 ^2 MVs, Per frame, x/n * x/n * 3
%% Parameter qScale to have multiple R-D points
k=1;
for qScale = 0.2:0.2:2
%% E5-1a, still Image compression, fore0020.bmp
img = double(imread('foreman0020.bmp'));
[PSNR_1st_frame, bitrate_1st_frame, num_irr, recon_1st_frame] = E4Milestone(img,0,0,0,0,701,qScale); % Use Lena_small
% PSNR = 33.7211
% Bitrate = 1.5387
%% E5-1b Load frames and transform to YCbCr
recon_1st_frame_ycbcr = ictRGB2YCbCr(recon_1st_frame);
%frame{1} = recon_1st_frame_ycbcr;
dec_frame{1} = recon_1st_frame_ycbcr;
dataset_name = 'foreman00';
for i = 20 :40
    file_name = strcat(dataset_name, int2str(i),'.bmp');
    frame{i-19} = ictRGB2YCbCr(double(imread(file_name)));
end
%% E5-1c
%  Function SSD.m£¬ Apply on the first 2 frames for training Huffman
motion_vectors_index_1st_frame = SSD(dec_frame{1}, frame{2});

%% E5-1d
rec_2nd_frame = SSD_rec(dec_frame{1}, motion_vectors_index_1st_frame);
for i = 1:3
    Error_2nd_frame(:,:,i) = rec_2nd_frame(:,:,i) - frame{2}(:,:,i);
end
%% E5-1e
% Train Huffman table using motion_vectors_index_1st_frame
h_mv = histogram(motion_vectors_index_1st_frame(:),1:82,'Normalization','probability');
pmf = h_mv.Values;
[BinaryTree_mv, HuffCode_mv, BinCode_mv, Codelengths_mv] = buildHuffman( pmf);
%% E5-1f
% Train Huffman table using Error_2nd_frame
% Encode the Error using Intra_encode from Chapter4.
Encoded_Error = Intra_encode_error(Error_2nd_frame, qScale);
% Min is -255 Max is 153 ==> take -300 ~ 1000
h_err = histogram(Encoded_Error(:),-600:1100,'Normalization','probability');
pmf = h_err.Values;
[BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err] = buildHuffman( pmf);
%% E5-1g
bitrate_frame{1} = bitrate_1st_frame;
PSNR{1} = PSNR_1st_frame;
% Implementation for the whole video sequence
for i = 2: length(frame)
    ref_im = dec_frame{i-1};
    im = frame{i};
    % START of Pseudo code: [err_im, MV] = motionEstimation(im1, ref_im)
    motion_vec_ind = SSD(ref_im, im);
    rec_im = SSD_rec(ref_im, motion_vec_ind);
    Error = im - rec_im;
    % END of Pseudo code: [err_im, MV] = motionEstimation(im1, ref_im)
    % Encode the reconstruction error
    % Encoded_Error = Intra_encode_error(Error);
    % Encoded_Error = reshape(Encoded_Error,size(frame{i}));
    % Transfer the motion_vecs and the Encoded_Error
%     bytestream_mv = enc_huffman(motion_vec_ind(:),BinCode_mv,Codelengths_mv);
    bit_num_mv = codeLength(motion_vec_ind(:), Codelengths_mv);
    % Decode the motion_vecs
%     Decoded_Motion_Vecs = dec_huffman(bytestream_mv, BinaryTree_mv, length(motion_vec_ind(:)));
    Decoded_Motion_Vecs = motion_vec_ind;
    % The Error_image's transfer will be simulated through a wrapper:
    % E4Mulestone.m
    [psnr_frame, bitrate_img_only, bitnum_frame, recon_frame_err] = E4Milestone(Error,...
        BinaryTree_err, HuffCode_err, BinCode_err, Codelengths_err, 601,qScale);
    % Now consider both mv_bytestream and err_bytestream for the bitrate
    bits_number = bit_num_mv + bitnum_frame;
    bitrate_frame{i} = bits_number/(numel(frame{i})/3);
    % PSNR was calculated in YCbCr, ignore it!
    % Now we have recon_frame_err, Decoded_Motion_Vecs, ref_im,
    % Recon the frame{i} in YCbCr
    recon_pred = SSD_rec(ref_im, Decoded_Motion_Vecs);
    % recon = recon_pred + error
    dec_frame{i} = recon_pred + recon_frame_err;
    % Now calculate the PSNR
    recon_RGB = ictYCbCr2RGB(dec_frame{i});
    Ori_RGB = ictYCbCr2RGB(frame{i});
    MSE = calcMSE(Ori_RGB, recon_RGB);
    PSNR{i} = calcPSNR(MSE);
end
Final_bitrate{k} = mean([bitrate_frame{1:length(frame)}]);
Final_PSNR{k} = mean([PSNR{1:length(frame)}]);
k=k+1
end
%% Result:
% 0.5663 30.8928
% 0.6619 32.38
% 0.8036 33.4920 dB
% 0.99 34.48 dB
% 1.22 35.4383 dB
% 2.6698 40

    












    
