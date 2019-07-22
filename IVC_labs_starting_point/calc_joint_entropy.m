function H = calc_joint_entropy(pmf)
    h=0;
    for i = 1:256
        for j = 1:256
            if pmf(i,j)~=0
                h = h + pmf(i,j)*log2(pmf(i,j));
            end
        end
    end
    H = -h;
end