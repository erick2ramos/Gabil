function f = fitnessFn(x, fs, examples)
    cs = cellstr(x);
    f = 0;
    for i = 0:(length(cs{1})/fs) -1
        hyp = substr(x,fs*i + 1,fs);
        aux = 0;
        for j = 1:size(examples,1)
            aux = aux || bitand(bin2dec(hyp),bin2dec(examples(j,:))) == bin2dec(examples(j,:));
        endfor
        f += aux;
    endfor
    f = f / size(examples,1);
    f = f*f;
endfunction

function selected = selectionFn(population, fitness, selPercent)
    selected = [];
    [oF iF] = sort(fitness ./ sum(fitness), 'descend');
    selected = population(iF,:);
    selected = selected(1:selPercent,:);
endfunction

function mutated = mutationFn(population, mutationRate)
    mutated = population;
    Npop = size(population, 1);
    popPerm = randperm(Npop)(1:floor(Npop*mutationRate));
    for i=1:length(popPerm)
        cs = cellstr(mutated(popPerm(i),:));
        csMut = randperm(length(cs{1}),1);
        if cs{1}(csMut) == "0"
            mutated(popPerm(i), csMut) = "0";
        else
            mutated(popPerm(i), csMut) = "1";
        endif
    endfor
endfunction

function crossed = crossoverFn(population, fitness, bpf, nMatings)
    crossed = [];
    if mod(nMatings,2) != 0
        nMatings += 1;
    endif
    [oF iF] = sort(fitness ./ sum(fitness), 'descend');
    matingPool = population(iF,:);
    matingPool = matingPool(1:nMatings,:);
    matingPool = matingPool(randperm(nMatings),:);
    for i=1:2:size(matingPool,1)
        ma = cellstr(matingPool(i,:)){1};
        pa = cellstr(matingPool(i+1,:)){1};
        M = randperm(length(ma) - 1 - 1, 1) + 1;
        maPoints = [M (randperm(length(ma) - M,1) + M)];
        paPoints = [mod(maPoints(1), length(pa))+1 mod(maPoints(2), length(pa))+1];
        ch1 = "";
        ch2 = "";
        for i = 1:maPoints(1)
            ch2 = strcat(ch2,ma(i));
        endfor
        for i = 1:paPoints(1)
            ch1 = strcat(ch1,pa(i));
        endfor
        for i=maPoints(1) + 1 : maPoints(2) - 1;
            ch1 = strcat(ch1,ma(i));
        end
        for i=paPoints(1) + 1:paPoints(2) - 1;
            ch2 = strcat(ch2,pa(i));
        end
        for i = maPoints(2) : length(ma)
            ch2 = strcat(ch2,ma(i));
        endfor
        for i = paPoints(2) : length(pa)
            ch1 = strcat(ch1,pa(i));
        endfor
        crossed = [crossed; ch1];
        crossed = [crossed; ch2];
    endfor
endfunction

function coded = encode(e, bpf, lbs, ubs)
    coded = "";
    for i = 1:size(e,2)-1
        itv = floor((e(1,i) - lbs(1,i)) * (bpf(1,i) - 1) / (ubs(1,i) - lbs(1,i))) + 1;
        coded = strcat(coded,dec2bin(bitset(0,itv,1),bpf(1,i)));
    endfor
    coded = strcat(coded,dec2bin(e(1,size(e,2)),bpf(1,size(e,2))));
endfunction

function rcoded = randCoded(t)
    rcoded = 0;
    for i = 1:t
        rcoded = bitset(rcoded,i,round(rand));
    endfor
    rcoded = dec2bin(rcoded,t);
endfunction
