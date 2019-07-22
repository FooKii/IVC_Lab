function [psnr, bitrate, bitnum, recon] = E4Milestone(Lena,BinaryTree, HuffCode, BinCode, Codelengths, bias, qScale)
lena_small = double(imread('lena_small.tif'));
% Lena       = double(imread('lena.tif'));
flag = bias - 701;
scaleIdx = 1;
%% Training Huffman using Lena_small
    if flag == 0     
        % use pmf of k_small to build and train huffman table
        rc_book = [];
        for i = 1:8
           for j = 1:8
                blk = lena_small((i-1)*8+1:8*i,(j-1)*8+1:8*j,:);
                r = IntraEncode(blk, qScale,0);
                rc_book =[rc_book;r{1};r{2};r{3}];

                %max(rc_book);
            end
        end
        h = histogram(rc_book(:),-700:2000,'Normalization','probability');
        pmf = h.Values;
        [BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( pmf);
    end
    %% use trained table to encode k to get the bytestream
    % your code here
    num = 0;
    for i = 1:size(Lena,1)/8
        for j = 1:size(Lena,2)/8
            blk = Lena((i-1)*8+1:8*i,(j-1)*8+1:8*j,:);
            %enc to run-length-code
            rl = IntraEncode(blk,qScale, flag);
            for n = 1:3
                % huffman enc in each layer
                % bytestream{n} = enc_huffman(rl{n}+bias,BinCode,Codelengths);
                %% Bug found, using new method to get code length
                bit_length = codeLength(rl{n}+bias, Codelengths);
                num = num + bit_length;
            end
            % huffman dec from each layer
%             for n = 1:3
%                 decoded{n} = dec_huffman(bytestream{n}, BinaryTree, length(rl{n}))-bias;
%             end
            % dec from run-length
            blk_recon = IntraDecode(rl, qScale);
            recon((i-1)*8+1:8*i,(j-1)*8+1:8*j,:) = blk_recon;
            
        end
    end
    bitnum = num;
    if flag == 0
        I_rec = ictYCbCr2RGB(recon);
    else
        I_rec = recon;
    end
    %imshow(uint8(I_rec))
    bitPerPixel(scaleIdx) = num/ (numel(Lena)/3);
    %% image reconstruction
    %I_rec = IntraDecode(k_rec, size(Lena),qScale);
    mse = calcMSE(Lena,I_rec);
    PSNR(scaleIdx) = calcPSNR(mse);
    %fprintf('QP: %.1f bit-rate: %.2f bits/pixel PSNR: %.2fdB\n', qScale, bitPerPixel(scaleIdx), PSNR(scaleIdx))
psnr = PSNR(1);
bitrate = bitPerPixel;
recon = I_rec;
end


% put all used sub-functions here.
function dst = IntraDecode(image , qScale)
%  Function Name : IntraDecode.m
%  Input         : image (zero-run encoded image, Nx3)
%                  img_size (original image size)
%                  qScale(quantization scale)
%  Output        : dst   (decoded image)
    for i = 1:3
        dec_zz(:,i) = ZeroRunDec_EoB(image{i}, 999);
    end
    quanted = DeZigZag8x8(dec_zz);
    coeff = DeQuant8x8(quanted,qScale);
    dst = IDCT8x8(coeff);
end

function dst = IntraEncode(image_block, qScale, flag)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, Nx3)
    % Convert to YCbCr
    if flag == 0
        img_ycbcr_block = ictRGB2YCbCr(image_block);
    else
        img_ycbcr_block = image_block;
    end
    % DCT
    %I_dct = blockproc(img_ycbcr, [8, 8], @(block_struct) process(block_struct.data, qScale));
    coeff = DCT8x8(img_ycbcr_block);
    quant = Quant(coeff, qScale);
    zz = ZigZag8x8(quant);
    for i = 1:3
        zrc{i} = ZeroRunEnc_EoB(zz(:,i),999)';
    end
    dst = zrc;
    
end

function zrc = process(block, qscale)
    coeff = DCT8x8(block);
    quant = Quant(coeff, qscale);
    zz = ZigZag8x8(quant);
    zrc = ZeroRunEnc_EoB(zz,99);
    zrc=[1 1 1];
    
    
    
end

function zz = ZigZag8x8(quant)
%  Input         : quant (Quantized Coefficients, 8x8x3)
%
%  Output        : zz (zig-zag scaned Coefficients, 64x3)
z = [1 2 6 7 15 16 28 29
3 5 8 14 17 27 30 43
4 9 13 18 26 31 42 44
10 12 19 25 32 41 45 54
11 20 24 33 40 46 53 55
21 23 34 39 47 52 56 61
22 35 38 48 51 57 60 62
36 37 49 50 58 59 63 64];
for i = 1:3
    q = quant(:,:,i);
    layer(z(:)) = q(:); 
    zz(:,i)=layer;
end
end

function zze = ZeroRunEnc_EoB(zz, EOB)
%  Input         : zz (Zig-zag scanned block, 1x64)
%                  EOB (End Of Block symbol, scalar)
%
%  Output        : zze (zero-run-level encoded block, 1xM)
k=1;
ind=1;
while k<=64
    zze(ind) = zz(k);
    if zz(k) == 0
        a = 0;
        while zz(k+a) == 0 
            a = a+1;
            if k+a>64
                zze(ind)=EOB;
                k = 100;
                break;
            end
        end
        if a>1 & k<64
            r = a - 1;
            ind = ind + 1;
            zze(ind) = r;
            k = k + r + 1;
        elseif a==1
            k = k+1;
            ind = ind + 1;
        end
    else 
        k = k+1;        
    end
    ind = ind+1;
end
end

function dst = ZeroRunDec_EoB(src, EoB)
%  Function Name : ZeroRunDec1.m zero run level decoder
%  Input         : src (zero run encoded sequence 1xM with EoB sign in the end)
%                  EoB (end of block sign)
%
%  Output        : dst (reconstructed single zig-zag scanned block 1x64)
ind = 1;
k=1;
while k<=length(src) & ind<65
    dst(ind) = src(k);
    if src(k) == 0
        rep = src(k+1);
        if rep == 0
            k = k+1;
        else
            if ind+rep >= 64
                k = 100;
                dst(64)=0;
            else
                dst(ind + rep)=0;
                ind=ind+rep;
                k=k+1;
            end
        end
    elseif src(k) == EoB
        dst(ind) = 0;
        dst(64)=0;
    end
    ind = ind + 1;
    k = k+1;
end           
end

function coeffs = DeZigZag8x8(zz)
%  Function Name : DeZigZag8x8.m
%  Input         : zz    (Coefficients in zig-zag order)
%
%  Output        : coeffs(DCT coefficients in original order)
z = [1 2 6 7 15 16 28 29
3 5 8 14 17 27 30 43
4 9 13 18 26 31 42 44
10 12 19 25 32 41 45 54
11 20 24 33 40 46 53 55
21 23 34 39 47 52 56 61
22 35 38 48 51 57 60 62
36 37 49 50 58 59 63 64];

for i = 1:3
    q = zz(:,i);
    d = q(z(:));
    coeffs(:,:,i) = reshape(d,8,8);
end
end

function dct_block = DeQuant8x8(quant_block, qScale)
%  Function Name : DeQuant8x8.m
%  Input         : quant_block  (Quantized Block, 8x8x3)
%                  qScale       (Quantization Parameter, scalar)
%
%  Output        : dct_block    (Dequantized DCT coefficients, 8x8x3)
L = ones([8 8]);
L = 32 * L;
C= [17 18 24 47 99 99 99 99
18 21 26 66 99 99 99 99

24 13 56 99 99 99 99 99
47 66 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99

99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99];
l = qScale*L;
c = qScale*C;
dct_block = round(quant_block.*l);
% dct_block(:,:,2) = round(quant_block(:,:,2).*c);
% dct_block(:,:,3) = round(quant_block(:,:,3).*c);

end

function block = IDCT8x8(coeff)
%  Function Name : IDCT8x8.m
%  Input         : coeff (DCT Coefficients) 8*8*3
%  Output        : block (original image block) 8*8*3
block = zeros(size(coeff));
a = dctmtx(8);
for i = 1:3
    block(:,:,i) = a'*coeff(:,:,i)*a;
end
end

function quant = Quant(dct_block, qScale)
%  Input         : dct_block (Original Coefficients, 8x8x3)
%                  qScale (Quantization Parameter, scalar)
%
%  Output        : quant (Quantized Coefficients, 8x8x3)
L = ones([8 8]);
L = 32 * L;
C= [17 18 24 47 99 99 99 99
18 21 26 66 99 99 99 99

24 13 56 99 99 99 99 99
47 66 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99

99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99];
l = qScale*L;
c = qScale*C;
quant = round(dct_block./l);
% quant(:,:,2) = round(dct_block(:,:,2)./c);
% quant(:,:,3) = round(dct_block(:,:,3)./c);

end