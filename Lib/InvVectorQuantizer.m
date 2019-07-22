function image = InvVectorQuantizer(qImage, clusters, block_size)
%  Function Name : VectorQuantizer.m
%  Input         : qImage     (Quantized Image)
%                  clusters   (Quantization clusters)
%                  block_size (Block Size)
%  Output        : image      (Dequantized Images)
for i = 1:size(qImage,1)
    for j= 1:size(qImage,2)
        for k = 1:3
            class = qImage(i,j,k);
            image((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size,k) = reshape(clusters(class,:),[block_size,block_size]);
        end
    end
end

end