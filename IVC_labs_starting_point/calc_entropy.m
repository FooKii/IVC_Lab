function H = calc_entropy(pmf,pc)
    h=0;
    for i = 1:511
        if pmf(i)~=0
            h = h + pmf(i)*log2(pc(i));
        end
    end
    H = -h;
end