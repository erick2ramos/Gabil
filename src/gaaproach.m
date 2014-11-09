source("utils2.m");

data = dlmread("../data/iris.data.modified3class.txt");

LB = min(data);
UB = max(data);
bitsPerFeature = [ 8 6 3 5 2 ];
Nvar = length(bitsPerFeature);
featureTotal = sum(bitsPerFeature);

validationPool = data(randperm(size(data,1))(1:30),:);
examples = [];
for i = 1:size(validationPool,1)
    examples = [examples; encode(validationPool(i,:), bitsPerFeature, LB, UB)];
endfor
ff = @(x) fitnessFn(x, featureTotal, bitsPerFeature, LB, UB, examples);
[ x, fval , ef, out, pop] = ga(ff, Nvar, [], [], [], [], LB, UB)
