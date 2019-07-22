clc;close all;clear all;


image=double(imread('lena.tif'));
img_size=size(image);
EoB=999;
qScale = 1;

imageYCbCr=ictRGB2YCbCr(image);
I_dct = blockproc(imageYCbCr, [8, 8], @(block_struct) DCT8x8(block_struct.data));
quant = blockproc(I_dct, [8, 8], @(block_struct) Quant8x8(block_struct.data,qScale));
Dequant=blockproc(quant, [8, 8], @(block_struct) DeQuant8x8(block_struct.data,qScale));
Deict=blockproc(Dequant, [8, 8], @(block_struct) IDCT8x8(block_struct.data));

ReImage=ictYCbCr2RGB(Deict);
imshow(ReImage/256);

function coeff = DCT8x8(block)
%  Input         : block    (Original Image block, 8x8x3)
%
%  Output        : coeff    (DCT coefficients after transformation, 8x8x3)
coeff = zeros(size(block));
a = dctmtx(8);
for i = 1:3
    coeff(:,:,i) = a*block(:,:,i)*a';
end
end