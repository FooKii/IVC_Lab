function dct_block = DeQuant_err(quant_block, qScale)
%  Function Name : DeQuant8x8.m
%  Input         : quant_block  (Quantized Block, 8x8x3)
%                  qScale       (Quantization Parameter, scalar)
%
%  Output        : dct_block    (Dequantized DCT coefficients, 8x8x3)
L = ones([8 8]);
L = 32 * L;
C= [17 18 24 47 99 99 99 99
18 21 26 66 99 99 99 99

24 13 56 99 99 99 99 99
47 66 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99

99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99];
l = qScale*L;
c = qScale*C;
dct_block(:,:) = round(quant_block(:,:,1).*l);

end