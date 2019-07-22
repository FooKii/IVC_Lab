function [qImage, clusters,xx] = LloydMax(image, bits, epsilon)
    %  Input         : image (Original RGB Image)
    %                  bits (bits for quantization)
    %                  epsilon (Stop Condition)
    %  Output        : qImage (Quantized Image)
    %                  clusters (Quantization Table)
    % ==============Begin=====================
    % Init Representatives and distortion
    %rep = linspace(0,255,2^bits)';
    rep = ((0:1:(2^bits-1)) + 0.5) * (256/(2^bits));
    rep = rep'
    distortion_old = 99999;
    % ===LGB-Algorithm loop===
    while 1
        [D, I] = pdist2(rep, image(:) , 'euclidean', 'Smallest', 1);
        distortion_new = sum(D.^2)/length(image)
        if (distortion_old - distortion_new)/distortion_new < epsilon
            break;
        else
            distortion_old = distortion_new;
            % Update representatives
            for i = 1:2^bits
                ind = find(I==i);
                rep(i) = sum(image(ind))/length(ind);
            end
        end
    end
    % return the indces
    qImage = reshape(I,size(image));
    clusters = rep;
    end