%% Main
bits         = 8;
epsilon      = 0.1;
block_size   = 2;
%% lena small for VQ training
image_small  = double(imread('lena_small.tif'));
[clusters, Temp_clusters] = VectorQuantizer(image_small, bits, epsilon, block_size);
qImage_small              = ApplyVectorQuantizer(image_small, clusters, block_size);
%% Huffman table training
h = histogram(qImage_small(:),1:257,'Normalization','probability');
pmf = h.Values;
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( pmf);
%% 
image  = double(imread('lena.tif'));
qImage = ApplyVectorQuantizer(image, clusters, block_size);
%% Huffman encoding
bytestream = enc_huffman(qImage(:),BinCode,Codelengths);
%%
bpp  = (numel(bytestream) * 8) / (numel(image)/3);
%% Huffman decoding
decoded = dec_huffman(bytestream, BinaryTree, length(qImage(:)));
qReconst_image = reshape(decoded,size(qImage));
%%
reconst_image  = InvVectorQuantizer(qReconst_image, clusters, block_size);
mse = calcMSE(image,reconst_image); 
psnr = calcPSNR(mse); %34.6235, bitrate 5.8061
