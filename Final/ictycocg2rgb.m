function rgb = ictycocg2rgb(ycocg)
    rgb(:,:,1) = ycocg(:,:,1) + ycocg(:,:,2) + -1*ycocg(:,:,3);
    rgb(:,:,2) = ycocg(:,:,1) + ycocg(:,:,3);
    rgb(:,:,3) = ycocg(:,:,1) + -1*ycocg(:,:,2) + -1*ycocg(:,:,3);
end
