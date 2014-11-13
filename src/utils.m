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

function selected = selectionFn(population, popFitness, selPercent)
    selected = [];
    pr = popFitness' ./ sum(popFitness);
    for i=1:length(pr)
        if pr(i) > selPercent
            selected = [ selected; population(i) ];
        endif
    endfor
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

function crossed = crossoverFn(population, fitness)
    crossed = population;
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
