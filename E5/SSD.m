function motion_vectors_indices = SSD(ref_image, image)
%  Input         : ref_image(Reference Image, size: height x width)
%                  image (Current Image, size: height x width)
%
%  Output        : motion_vectors_indices (Motion Vector Indices, 
%  size: (height/8) x (width/8) x 1 )
    
    % Pad the ref_image with 4x4 Boarder
    ref = padarray(ref_image,[4,4],0,'both');
    ref = ref(:,:,1);
    image = image(:,:,1);
    % Processing with blocks
    motion_vectors_indices = blockproc(image, [8, 8], @(block_struct) ...
        find_index(block_struct.data, block_struct.location, ref));   

end

% Function to transform MV to MV index
function index = mv2index(mv)
    % +-4 Search range
    row = mv(1) + 5;
    col = mv(2) + 5;
    index = (row - 1)*9 + col;
end

% Function to find MV_index under 8x8 block
function index = find_index(block, location, ref)
    % Search from -4 to +4
    % location of ref changed because of the boarders
    best_ssd = Inf;
    loc_ref = location + [4, 4];
    for i = -4 : 4
        for j = -4 : 4
            % Motion vector as follow
            mv = [i, j];
            % Calc SSD
            ref_block = ref(loc_ref(1) + i : loc_ref(1) + i + 7,loc_ref(2)+j: loc_ref(2)+j+7);
            ssd = sum(sum((block - ref_block).^2));
            % Compare with the best_ssd
            if ssd < best_ssd
                best_ssd = ssd;
                best_mv = mv;
            end
        end
    end
    index = mv2index(best_mv);
    %index = best_ssd;
end