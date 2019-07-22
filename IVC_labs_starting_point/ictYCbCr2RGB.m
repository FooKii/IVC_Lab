function rgb = ictYCbCr2RGB(ycbcr)
    rgb(:,:,1) = ycbcr(:,:,1) + 1.402*ycbcr(:,:,3);
    rgb(:,:,2) = ycbcr(:,:,1) + -0.344*ycbcr(:,:,2)+ -0.714*ycbcr(:,:,3);
    rgb(:,:,3) = ycbcr(:,:,1) + 1.772*ycbcr(:,:,2);
end
