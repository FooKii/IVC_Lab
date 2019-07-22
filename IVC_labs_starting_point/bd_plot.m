starting_br = [8, 8, 8, 6, 6, 6, 6, 6, 6, 12];
starting_psnr = [16.6, 15.46, 19.07, 27.3, 27.5, 28.6, 26.44, 30.7, 33.67, 27.6];
% smandril, lena , monarch(original, delete g,b)
% sample with prefilter1, w/o, with prefilter2, w/o saptic1
% resample sail.tif 30.7, lena 33.67
% color-transform
plot(starting_br, starting_psnr, 'o');
xlim([0, 20]);
ylim([10, 50]);