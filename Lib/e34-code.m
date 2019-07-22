function [clusters, Temp_clusters] = VectorQuantizer(image, bits, epsilon, bsize)
    %  Function Name : VectorQuantizer.m
    %  Input         : image    (Original Image)
    %                  bit      (bits for each block)
    %                  epsilon  (Stop Condition)
    %                  bsize    (Block Size)
    %  Output        : clusters (Quantization Representatives), size(clusters) = [2^bit, bsize^2];
    %                  Temp_clusters (Intermediate Quantization Representatives for each iteration)
    
        % initialise 
        distortion_old = 999;
        flag = 2;
            % first try with scaler uniform method
        scaler_bit = bits/(bsize^2);
        scaler_cb = ((0:1:(2^bits-1)) + 0.5) * (256/(2^bits));
        codebook = [scaler_cb;scaler_cb;scaler_cb;scaler_cb];
        codebook = codebook';
        % init vectorized_image_block
        vec_img = [];
        Temp_clusters = [];
        for i = 1:size(image,1)/bsize
            for j = 1:size(image,1)/bsize
                b = image((i-1)*bsize+1:i*bsize,(j-1)*bsize+1:j*bsize,:);
                length(b(:));   %debug
                vec_img = [vec_img,reshape(b,[bsize^2,3])];
            end
        end
            vec_img = vec_img';
            size(vec_img) %debug
            size(image)
        % End of init, may occur error
        % ========================================
        % Training
        while 1
            [I, D]   = knnsearch(codebook, vec_img, 'Distance', 'euclidean');
            distortion_new = sum(D.^2)/size(vec_img,1);
            rate = abs(distortion_old-distortion_new)/distortion_new;
            if rate < epsilon
                break;
            end
            % Update
            distortion_old=distortion_new;
            % === first check if ceil split needed ===
            nmb_uniq = length(unique(I));
            if nmb_uniq < 2^bits
                % Apply ceil split
                for k = 1:2^bits
                    if ~ismember(k,I)
                        codebook(k,:) = codebook(mode(I),:);
                        codebook(k,4) = codebook(k,4) + 1;
                        [I, D]   = knnsearch(codebook, vec_img, 'Distance', 'euclidean');
                    end
                end

            else
                % Then update according to the formula
                for i = 1:2^bits
                    ind = find(I==i);
                    codebook(i,:) = sum(vec_img(ind,:))./length(ind);
                end
            end
            Temp_clusters = [Temp_clusters,codebook];
        end
        % return
        clusters = codebook;
end