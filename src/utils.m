function f = fitnessFn(x, fs, examples)
    cs = cellstr(x){1};
    f = 0;
    for j = 1:size(examples,1)
        aux = 0;
        for i = 1:(length(cs)/fs)
            hyp = substr(cs,fs*(i - 1) + 1,fs);
            aux = aux || bitand(bin2dec(hyp),bin2dec(examples(j,:))) == bin2dec(examples(j,:));
            if strcmp(substr(hyp, fs - 2, 2), "11")
                aux = 0; 
            endif
        endfor
        f += aux;
    endfor
    f = f / size(examples,1);
    f = f*f;
endfunction

function f = fitnessSizeFn(x, fs, examples)
    cs = cellstr(x){1};
    f = 0;
    for j = 1:size(examples,1)
        aux = 0;
        for i = 1:(length(cs)/fs)
            hyp = substr(cs,fs*(i - 1) + 1,fs);
            aux = aux || bitand(bin2dec(hyp),bin2dec(examples(j,:))) == bin2dec(examples(j,:));
            if strcmp(substr(hyp, fs - 2, 2), "11")
                aux = 0; 
            endif
        endfor
        f += aux;
    endfor
    l = length(cs) / fs;
    f = f / size(examples,1);
    f = f / l;
    f = f*f;
endfunction

function selected = selectionFn(population, fitness, selPercent)
    selected = [];
    [oF, iF] = sort(fitness, 'descend');
    selected = population(iF,:);
    selected = selected(1:selPercent,:);
endfunction

function selected = selectionRouletteFn(population, fitness, selPercent)
    selected = [];
    sumFitness = sum(fitness);
    for i = 1:size(population,1)
        if rand < fitness(i) / sumFitness
            selected = [selected; population(i,:)];
        endif
    endfor
    %selected = selected(1:selPercent,:);
endfunction

function mutated = mutationFn(population, mutationRate)
    mutated = population;
    for i=1:size(mutated,1)
        if rand < mutationRate
            cs = cellstr(mutated(i,:));
            csMut = randperm(length(cs{1}),1);
            if cs{1}(csMut) == "0"
                mutated(i, csMut) = "0";
            else
                mutated(i, csMut) = "1";
            endif
        endif
    endfor
endfunction

function crossed = crossoverFn(population, bpf, nMatings)
    crossed = [];
    if size(population,1) <= nMatings || size(population,1) <= 1
        return
    endif
    if mod(nMatings,2) != 0
        nMatings += 1;
    endif
    matingPool = population(randperm(size(population,1),nMatings),:);
    ruleSize = sum(bpf);
    for i=1:2:size(matingPool,1)
        ma = cellstr(matingPool(i,:)){1};
        pa = cellstr(matingPool(i+1,:)){1};
        if length(ma) < length(pa)
            aux = ma;
            ma = pa;
            pa = aux;
        endif
        maMods = mod(randperm(length(ma),2),ruleSize);
        if maMods(1) == 0
            maMods(1) = ruleSize;
        endif
        if maMods(2) == 0
            maMods(2) = ruleSize;
        endif
        maMods = sort(maMods);
        maPoints = sort([ randperm(length(ma) / ruleSize,1), randperm(length(ma) / ruleSize,1)]);
        paMods = maMods;
        paPoints = sort([ randperm(length(pa) / ruleSize,1), randperm(length(pa) / ruleSize,1)]);
        maPoints = ((maPoints - 1) * ruleSize) + maMods;
        paPoints = ((paPoints - 1) * ruleSize) + paMods;
        ch1 = "";
        ch2 = "";
        for i = 1:maPoints(1)
            ch2 = strcat(ch2,ma(i));
        endfor
        for i = 1:paPoints(1)
            ch1 = strcat(ch1,pa(i));
        endfor
        for i=maPoints(1) + 1: maPoints(2)
            ch1 = strcat(ch1,ma(i));
        end
        for i=paPoints(1) + 1: paPoints(2)
            ch2 = strcat(ch2,pa(i));
        end
        for i = maPoints(2)+1 : length(ma)
            ch2 = strcat(ch2,ma(i));
        endfor
        for i = paPoints(2)+1 : length(pa)
            ch1 = strcat(ch1,pa(i));
        endfor
        crossed = [crossed; ch1];
        crossed = [crossed; ch2];
    endfor
endfunction

function coded = encode(e, bpf, lbs, ubs)
    coded = "";
    for i = 1:size(e,2) - 1
        itv = floor((e(1,i) - lbs(1,i)) * (bpf(1,i) - 1) / (ubs(1,i) - lbs(1,i))) + 1;
        coded = strcat(coded,dec2bin(bitset(0,itv,1),bpf(1,i)));
    endfor
    coded = strcat(coded,dec2bin(e(size(e,2)),bpf(1,size(bpf,2))));
endfunction

function rcoded = randCoded(t)
    rcoded = 0;
    for i = 1:t
        rcoded = bitset(rcoded,i,round(rand));
    endfor
    rcoded = dec2bin(rcoded,t);
endfunction

function [class, isIt] = test(sub, classifier, bpf, lbs, ubs)
    subCod = encode(sub, bpf, lbs, ubs);
    cs = cellstr(classifier){1};
    csL = length(cs);
    fTotal = sum(bpf);
    nRules = csL/fTotal;
    subFeatures = substr(subCod, 1, fTotal - bpf(length(bpf)));
    subClass = substr(subCod, fTotal - bpf(length(bpf)) + 1, bpf(length(bpf)));
    found = false;
    isIt = false;
    for i=1:nRules
        ruleNumber = ((i - 1) * fTotal) + 1;
        rule = substr(cs, ruleNumber, fTotal - bpf(length(bpf)));
        ruleClass = substr(cs, ruleNumber + fTotal - bpf(length(bpf)), bpf(length(bpf)));
        match = bitand(bin2dec(rule),bin2dec(subFeatures)) == bin2dec(subFeatures);
        if match
            fprintf('Subject: %s\n', subCod);
            fprintf('Rule:    %s\n', substr(cs, ruleNumber, fTotal));
            fprintf('Classification: %s\n', ruleClass);
            fprintf('Real Class: %s\n', subClass);
            class = ruleClass;
            found = true;
            isIt = subClass == ruleClass;
            break
        endif
    endfor
    if !found
        fprintf('No class found\n');
    endif
endfunction
