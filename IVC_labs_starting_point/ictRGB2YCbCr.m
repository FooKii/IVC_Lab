function ycbcr = ictRGB2YCbCr(rgb)
    ycbcr(:,:,1) = rgb(:,:,1)*0.299 + rgb(:,:,2)*0.587 + rgb(:,:,3)*0.114;
    ycbcr(:,:,2) = rgb(:,:,1)*-0.169 + rgb(:,:,2)*-0.331 + rgb(:,:,3)*0.5;
    ycbcr(:,:,3) = rgb(:,:,1)*0.5 + rgb(:,:,2)*-0.419 + rgb(:,:,3)*-0.081;
end