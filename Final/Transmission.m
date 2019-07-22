function [bitnum, recon] = Transmission(img, train_flag, qScale, bias, BinaryTree, HuffCode, BinCode, Codelengths )
%% Whole Transmission process, see E4Milestone.
% Input ...
% Output ...
%% Variables predefine:
wd_size = 8;
%% If train_flag is 1, then train Huffman using Lena_small
    if train_flag
        %% Load lena_small and convert with chroma_subsample
        lena_small = double(imread('lena_small.tif'));
        [h,w,~] = size(lena_small);
        [Img_newColorSpace, T_pca, Offset_pca, means] = NewColorSpace_enc(lena_small);
        img_chr_sub = Chroma_sub_420(Img_newColorSpace);
        lena_small_cell{1} = img_chr_sub(:,:,1);
        for i = 2:3
           layer_trsmit = img_chr_sub(:,:,i);
           lena_small_cell{i} = layer_trsmit(1:h/2,1:w/2);
        end
        
        %% Train Start
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
        h = histogram(rc_book(:),-400:1000,'Normalization','probability');
        pmf = h.Values;
        [BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( pmf);
        
    end
% End of Lena_small training
%%   Transmit using Huffman
    num = 0;
    for l = 1:3
        if l == 1
            for i = 1:size(img{1},1)/wd_size
                for j = 1:size(img{1},2)/wd_size

                        blk = img{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j);
                    %enc to run-length-code
                        blk_runlength{l} = IntraEncode(blk,qScale,l);

                    % huffman enc in each layer
                        %bytestream{l} = enc_huffman(blk_runlength{l}+bias,BinCode,Codelengths);
                        bit_num_blk = codeLength(blk_runlength{l}+bias, Codelengths);
                        num = num + bit_num_blk;

                    % huffman dec from each layer

                        %decoded{l} = dec_huffman(bytestream{l}, BinaryTree, length(blk_runlength{l}))-bias;
                        decoded{l} = blk_runlength{l};
                    % dec from run-length
                        blk_recon{l} = IntraDecode(decoded{l}, qScale, l);
                        recon{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j) = blk_recon{l};
                end
            end
        else
            for i = 1:size(img{1},1)/(2*wd_size)
                for j = 1:size(img{1},2)/(2*wd_size)

                        blk = img{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j);
                    %enc to run-length-code
                        blk_runlength{l} = IntraEncode(blk,qScale,l);

                    % huffman enc in each layer
                        bit_num_blk = codeLength(blk_runlength{l}+bias, Codelengths);
                        num = num + bit_num_blk;

                    % huffman dec from each layer

                        decoded{l} = blk_runlength{l};

                    % dec from run-length
                        blk_recon{l} = IntraDecode(decoded{l}, qScale,l);
                        recon{l}((i-1)*wd_size+1:wd_size*i,(j-1)*wd_size+1:wd_size*j) = blk_recon{l};
                end
            end
        end
    end
    bitnum = num; 

%% END
end

function dst = IntraEncode(image_block, qScale, layer)
%  Function Name : IntraEncode.m
%  Input         : image (Image in Color Space)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, Nx3)

    coeff = DCT8x8(image_block);
    if layer > 1 
        quant = Quant_c(coeff, qScale);
    else
        quant = Quant_y(coeff, qScale);
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
        coeff = DeQuant_c(quanted,qScale);
    else 
        coeff = DeQuant_y(quanted,qScale);
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