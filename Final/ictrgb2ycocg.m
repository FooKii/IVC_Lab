function ycocg = ictRGB2ycocg(rgb)
    ycocg(:,:,1) = rgb(:,:,1)*0.25 + rgb(:,:,2)*0.5 + rgb(:,:,3)*0.25;
    ycocg(:,:,2) = rgb(:,:,1)*0.5  + rgb(:,:,3)*-0.5;
    ycocg(:,:,3) = rgb(:,:,1)*-0.25 + rgb(:,:,2)*0.5 + rgb(:,:,3)*-0.25;
end