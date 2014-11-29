source('utils.m');

arg_list = argv();

data = dlmread('../data/iris.data.modified3class.txt');
errorMsg = 'Uso: main [seleccion] [fitness] [tasa mutacion] [tasa cruce]\nseleccion: [1 (Por rango),2 (Rueda de ruleta)]\nfitness: [1 (normal), 2 (penalizacion por tamano)]\ntasa mutacion: (0.0:1.0)\ntasa cruce: (0.0:1.0)\n';
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
bitsPerFeature = [ 8 6 5 3 2 ];
Nvar = length(bitsPerFeature);
featureTotal = sum(bitsPerFeature);


validationPool = data(randperm(size(data,1),75),:);
examples = [];
for i = 1:size(validationPool,1)
    examples = [examples; encode(validationPool(i,:), bitsPerFeature, LB, UB)];
endfor

Npop = 20;
population = [];
for i = 1:Npop
    newpep = [];
    for j = 1:ceil(rand * 3)
        newpep = [newpep randCoded(featureTotal)];
    endfor
    population = [population; newpep];
endfor

maxGenerations = 100;
if length(arg_list) < 3 
    mutationRate = 0.1;
else
    if str2num(arg_list{3}) > 0 && str2num(arg_list{3}) < 1
        mutationRate = str2num(arg_list{3});
    else
        fprintf(errorMsg);
        exit
    endif
endif

if length(arg_list) < 4
    selectionPercent = 0.5;
else
    if str2num(arg_list{4}) > 0 && str2num(arg_list{4}) < 1
        selectionPercent = str2num(arg_list{4});
    else
        fprintf(errorMsg);
        exit
    endif
endif

nTrascendence = floor(selectionPercent * Npop);
nMutations = ceil((Npop - 1)*Nvar*mutationRate);
nMatings = ceil((Npop - nTrascendence)/2);
maxFitness = 0.98;

if length(arg_list) >= 2
    if !(str2num(arg_list{2}) == 1 || str2num(arg_list{2}) == 2)
        fprintf(errorMsg);
        exit
    endif
    if str2num(arg_list{2}) == 2
        fitness = @fitnessSizeFn;
    else
        fitness = @fitnessFn;
    endif
else
    fitness = @fitnessFn;
endif

if length(arg_list) >= 1
    if !(str2num(arg_list{1}) == 1 || str2num(arg_list{1}) == 2)
        fprintf(errorMsg);
        exit
    endif
    if str2num(arg_list{1}) == 2
        selection = @selectionRouletteFn;
    else
        selection = @selectionFn;
    endif
else
    selection = @selectionFn;
endif

crossover = @crossoverFn;
mutation = @mutationFn;

fsum = zeros(1, Npop);
for i = 1:Npop
    fsum(i) = fitness(population(i,:), featureTotal, examples);
endfor

gen = 0;
while  max(fsum) < maxFitness && gen < maxGenerations
    newGen = [];
    newGen = selection(population, fsum, nTrascendence);
    newGen = crossover(newGen, bitsPerFeature, nMatings);
    newGen = mutation(newGen, mutationRate);
    newSum = zeros(1, size(newGen,1));
    for i = 1:size(newGen,1)
        newSum(i) = fitness(newGen(i,:), featureTotal, examples); 
    endfor 
    [ fsum, ind ] = sort(fsum, 'descend');
    population = population(ind,:);
    population = population(1:size(population,1) - size(newGen,1),:);
    population = [population; newGen];
    fsum = fsum(1:length(fsum) - length(newSum));
    fsum = [fsum, newSum];
    Npop = size(population,1);
    nTrascendence = floor(selectionPercent * Npop);
    nMutations = ceil((Npop - 1)*Nvar*mutationRate);
    nMatings = ceil((Npop - nTrascendence)/2);
    gen += 1;
endwhile
toc()
[x, index] = max(fsum);
fprintf('Mejor individuo: %s\nAcertadas: %f\nGeneracion: #%d\n',cellstr(population(index,:)){1}, max(fsum) * 100, gen);
