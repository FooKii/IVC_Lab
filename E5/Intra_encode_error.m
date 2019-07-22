function Encoded = Intra_encode_error(err_image, qscale)
% Input:  err_image in YCbCr 
% Output: Encoded err_image into (Sequence after run-length coding)
    Encoded = [];
    for i = 1: size(err_image,1)/8
        for j = 1: size(err_image,2)/8
            blk = err_image((i-1)*8+1:8*i,(j-1)*8+1:8*j,:);
            encoded_layer = IntraEncode(blk, qscale);
            Encoded = [Encoded; encoded_layer{1}; encoded_layer{2}; encoded_layer{3}];
        end
    end
end

function dst = IntraEncode(image_block, qScale)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, Nx3)
    % Convert to YCbCr
    %img_ycbcr_block = ictRGB2YCbCr(image_block);
    % DCT
    %I_dct = blockproc(img_ycbcr, [8, 8], @(block_struct) process(block_struct.data, qScale));
    coeff = DCT8x8(image_block);
    quant = Quant(coeff, qScale);
    zz = ZigZag8x8(quant);
    for i = 1:3
        zrc{i} = ZeroRunEnc_EoB(zz(:,i),999)';
    end
    dst = zrc;
    
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