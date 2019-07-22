function joint_pmf = stats_joint(img)
    [x,y]=size(img);
    j = zeros(x,y/2);
    i = zeros(x,y/2);
    j = img(:,2:2:end);
    i = img(:,1:2:end);
    h = histogram2(i,j,0:256,0:256,'Normalization','probability');
    joint_pmf = h.Values;
end 