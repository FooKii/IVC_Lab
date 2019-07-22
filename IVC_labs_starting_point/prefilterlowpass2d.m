function postimg = prefilterlowpass2d(img)
    % W1 = 1/16*[1 2 1; 2 4 2; 1 2 1];
    w = fir1(40, 0.5);
    w2 = w'*w;
    for i = 1:3
    	postimg(:,:,i) = conv2(img(:,:,i), w2, 'same');
    end
end

