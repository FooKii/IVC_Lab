function img_rgb = NewColorSpace_dec(img_new_color_space, T, off, means)
    [h,w,d] = size(img_new_color_space);
    for i = 1:d
        layer = img_new_color_space(:,:,i);
        color_Stack(i,:) = layer(:); % Stack for latter use
    end
    img_rgb_stacked = T\(color_Stack);%-off);
    for i = 1:d
        img_rgb_stacked(i,:) = img_rgb_stacked(i,:) + means(i);
        img_rgb(:,:,i) = reshape(img_rgb_stacked(i,:), [h,w]);  
    end
   
end