function MSE = calcMSE(original, reconstructed)
    [x,y,z] = size(original);
    sum = 0;
    %original = original*256;
    %reconstructed = reconstructed*256;
    for i = 1:(x*y*z)
        sum = (original(i)-reconstructed(i))^2 + sum;
    end
    MSE = sum/(x*y*z);
end