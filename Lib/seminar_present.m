imageLena_small = double(imread('lena_small.tif'));
imageLena = double(imread('lena.tif'));
bits_small      = [1 2 3 5 7];
bits = [2 4 6];
PSNR_small = [];
for bit = bits_small
    qImageLena_small = UniQuant(imageLena_small, bit);
    recImage_small   = InvUniQuant(qImageLena_small, bit);
    
    PSNR_small = [PSNR_small calcPSNR(imageLena_small, recImage_small)];
end

PSNR = [];
i=1
for bit = bits
    qImageLena = UniQuant(imageLena, bit);
    recImage   = InvUniQuant(qImageLena, bit);
    pic{i} = recImage;
    PSNR = [PSNR calcPSNR(imageLena, recImage)];
    i = i+1;
end
img_roi = pic{1};
imshow(uint8(pic{2}));
img_roi(200:400,180:400,:) = pic{3}(200:400,180:400,:);

imshow(uint8(img_roi));
ps = calcPSNR(imageLena, img_roi)
 ...

% define your functions, e.g. calcPSNR, UniQuant, InvUniQuant
function qImage = UniQuant(image, bits)
    %  Input         : image (Original Image)
    %                : bits (bits available for representatives)
    %
    %  Output        : qImage (Quantized Image)
    interval_nr = 2^bits;
    interval_length = 256/interval_nr;
    index_mat = floor(image./interval_length);
    qImage = index_mat;
end

function image = InvUniQuant(qImage, bits)
    interval_nr = 2^bits;
    interval_length = 256/interval_nr;
    image = qImage.*interval_length + interval_length/2;
end

function PSNR = calcPSNR( image1, image2 )
    MSE = calcMSE(image1, image2);
    PSNR = 10*log10((2^8 - 1)^2/MSE);
end

function MSE = calcMSE( image1, image2 )
    [x,y,z] = size(image1);
    sum = 0;
    %original = original*256;
    %reconstructed = reconstructed*256;
    for i = 1:(x*y*z)
        sum = (image1(i)-image2(i))^2 + sum;
    end
    MSE = sum/(x*y*z);
end