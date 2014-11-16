source("utils.m");

data = dlmread("../data/iris.data.modified3class.txt");

%figure(1);
%subplot(2,2,1);
%hist(data(:,1),30);
%subplot(2,2,2);
%hist(data(:,2),30);
%subplot(2,2,3);
%hist(data(:,3),30);
%subplot(2,2,4);
%hist(data(:,4),30);
tic();
LB = min(data);
UB = max(data);
bitsPerFeature = [ 4 3 2 3 2 ];
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
fsum = zeros(1, Npop);
for i = 1:Npop
    fsum(i) = fitnessFn(population(i,:), featureTotal, examples);
endfor

maxGenerations = 100;
mutationRate = 0.2;
selectionPercent = 0.5;
nTrascendence = floor(selectionPercent * Npop);
nMutations = ceil((Npop - 1)*Nvar*mutationRate);
nMatings = ceil((Npop - nTrascendence)/2);
maxFitness = 5;

selection = @selectionFn;
crossover = @crossoverFn;
mutation = @mutationFn;

gen = 0;
while max(fsum) < maxFitness && gen < maxGenerations
    newGen = [];
    newGen = selection(population, fsum, nTrascendence);
    newGen = [newGen; crossover(population, fsum, bitsPerFeature, nMatings)];
    newGen = mutation(newGen, mutationRate);
    population = newGen;
    fsum = zeros(1, size(population,1));
    for i = 1:size(population,1)
        fsum(i) = fitnessFn(population(i,:), featureTotal, examples); 
    endfor
    Npop = size(population,1);
    nTrascendence = floor(selectionPercent * Npop);
    nMutations = ceil((Npop - 1)*Nvar*mutationRate);
    nMatings = ceil((Npop - nTrascendence)/2);
    gen += 1;
endwhile
toc()
[x, index] = max(fsum);
population(index,:)
gen
