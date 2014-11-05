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

function selection = selectionFn()
    
endfunction

function coded = encode(e, bpf, lbs, ubs)
    coded = "";
    for i = 1:size(e,2)-1
        itv = floor((e(1,i) - lbs(1,i)) * bpf(1,i) / (ubs(1,i) - lbs(1,i))) + 1;
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
