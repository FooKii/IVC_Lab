function H_cond = calc_cond_entropy(pmf)
    h=0;

    for i = 1:256
        for j = 1:256
            if pmf(i,j)~=0
                pmf_cond = pmf(i,j)/sum(pmf(i,:));
                h = h + pmf(i,j)*log2(pmf_cond);
            end
        end
    end
    H_cond = -h;
end