function PSNR = calcPSNR(MSE)
    PSNR = 10*log10((2^8 - 1)^2/MSE);