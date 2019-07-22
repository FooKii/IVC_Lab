function rec_image = SSD_rec(ref_image, motion_vectors)
%  Input         : ref_image(Reference Image, YCbCr image)
%                  motion_vectors
%
%  Output        : rec_image (Reconstructed current image, YCbCr image)

    rec_image = zeros(size(ref_image));
    ref_image = padarray(ref_image,[4 4],0,'both');
    for i = 1: size(motion_vectors,1)
        for j = 1: size(motion_vectors,2)
            mv = index2mv(motion_vectors(i,j));
            block_rec = ref_image((i-1)*8+5 + mv(1):(i-1)*8+1 + mv(1) + 11, ...
                (j-1)*8+5+mv(2):(j-1)*8 + 1 + mv(2) + 11,:);
            rec_image((i-1)*8+1:(i-1)*8+8, (j-1)*8+1:(j-1)*8+8,:) = block_rec;
        end
    end
end

function mv = index2mv(index)
    % Get the loc of the MV-Matrix
    col = mod(index,9);
    row = fix(index/9)+1;
    if col == 0
        col =9;
        row = row - 1;
    end
    mv(1) = row -5;
    mv(2) = col -5;
end