function cond_pmf = stats_cond(img)
    left = img(:,1:end-1);
    right = img(:,2:end);
    h = histogram2(left,right,0:256,0:256,'Normalization','probability');
    cond_pmf = h.Values;
end