source("utils.m");

data = dlmread("../data/iris.data.modified3class.txt");

figure(1);
subplot(2,2,1);
hist(data(:,1),30);
subplot(2,2,2);
hist(data(:,2),30);
subplot(2,2,3);
hist(data(:,3),30);
subplot(2,2,4);
hist(data(:,4),30);

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

Npop = 10;
population = [];
for i = 1:Npop
    newpep = [];
    for j = 1:ceil(rand * 4)
        newpep = [newpep randCoded(featureTotal)];
    endfor
    population = [population; newpep];
endfor
fsum = 0;
for i = 1:Npop
    fsum += fitnessFn(population(i,:), featureTotal, examples);
endfor
fsum

maxGenerations = 100;
mutationRate = 0.2;
selectionPercent = 0.5;
nTrascendence = floor(selectionPercent * Npop);
nMutations = ceil((Npop - 1)*Nvar*mutationRate);
nMatings = ceil((Npop - nTrascendence)/2);


