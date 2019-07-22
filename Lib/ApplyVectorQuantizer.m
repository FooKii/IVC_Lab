function qImage = ApplyVectorQuantizer(image, clusters, bsize)
%  Function Name : ApplyVectorQuantizer.m
%  Input         : image    (Original Image)
%                  clusters (Quantization Representatives)
%                  bsize    (Block Size)
%  Output        : qImage   (Quantized Image)
        for k = 1:3
        vec_img = [];
        Temp_clusters = [];
        for i = 1:size(image,1)/bsize
            for j = 1:size(image,2)/bsize
                b = image((i-1)*bsize+1:i*bsize,(j-1)*bsize+1:j*bsize,k);
                length(b(:));   %debug
                vec_img = [vec_img;reshape(b,[1,bsize^2])];
            end
        end
        size(vec_img) ;%debug
        size(image);
        [I, D]   = knnsearch(clusters, vec_img, 'Distance', 'euclidean');
        qImage(:,:,k) = reshape(I,[size(image,1)/bsize,size(image,2)/bsize]);
        qImage(:,:,k) = qImage(:,:,k)';
        end
end