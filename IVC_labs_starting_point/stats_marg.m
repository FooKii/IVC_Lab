function pmf = stats_marg(img)
    h = histogram(img(:),-255:255,'Normalization','probability');
    pmf = h.Values;
end