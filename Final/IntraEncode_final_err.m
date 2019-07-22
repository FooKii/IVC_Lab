function rc_book = IntraEncode_final_err(lena_small_cell, qScale)
wd_size = 8;
rc_book = [];
    for l = 1:3
        if l == 1
            for i = 1:8
               for j = 1:8
                    blk = lena_small_cell{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j);
                    r_trsmit{l} = IntraEncode(blk, qScale,l);
                    rc_book =[rc_book;r_trsmit{l}];         
               end
            end
        else
            for i = 1:4
               for j = 1:4
                    blk = lena_small_cell{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j);
                    r_trsmit{l} = IntraEncode(blk, qScale,l);
                    rc_book =[rc_book;r_trsmit{l}];         
               end
            end
        end
    end 
end



%% end

function dst = IntraEncode(image_block, qScale, layer)
%  Function Name : IntraEncode.m
%  Input         : image (Image in Color Space)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, Nx3)

    coeff = DCT8x8(image_block);
    if layer > 1 
        quant = Quant_err(coeff, qScale);
    else
        quant = Quant_err(coeff, qScale);
    end
    zz = ZigZag8x8(quant);

    zrc = ZeroRunEnc_EoB(zz(:),999)';

    dst = zrc;  
end

function dst = IntraDecode(image, qScale, l)
%  Function Name : IntraDecode.m
%  Input         : image (zero-run encoded image, Nx3)
%                  img_size (original image size)
%                  qScale(quantization scale)
%  Output        : dst   (decoded image)
    
    dec_zz(:) = ZeroRunDec_EoB(image, 999);
    
    quanted = DeZigZag8x8(dec_zz);
    if l > 1
        coeff = DeQuant_err(quanted,qScale);
    else 
        coeff = DeQuant_err(quanted,qScale);
    end
    dst = IDCT8x8(coeff);
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

q = zz(:);
d = q(z(:));
coeffs(:,:) = reshape(d,8,8);
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

q = quant(:,:);
layer(z(:)) = q(:); 
zz(:)=layer;

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

function block = IDCT8x8(coeff)
%  Function Name : IDCT8x8.m
%  Input         : coeff (DCT Coefficients) 8*8*3
%  Output        : block (original image block) 8*8*3
block = zeros(size(coeff));
a = dctmtx(8);
for i_idct = 1:size(coeff,3)
    block(:,:,i_idct) = a'*coeff(:,:,i_idct)*a;
end
end