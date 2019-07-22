function qImage = UniQuant(image, bits)
    %  Input         : image (Original Image)
    %                : bits (bits available for representatives)
    %
    %  Output        : qImage (Quantized Image)
    interval_nr = 2^bits;
    interval_length = 256/interval_nr;
    index_mat = ceil(image./interval_length);
    qImage = (index_mat-1).*interval_length + interval_length/2;
    

end