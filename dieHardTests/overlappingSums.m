clc
clear;
fileID = fopen('generated3.bin');
A = fread(fileID, 'ubit32');
ratio = 1/2^32;   
U = A*ratio; 

size = 100;        
k = 0; 
result = [];
B = [size];
p = [];
p2 = [];
pd = makedist('uniform');
mi = 50;
sigma = sqrt(12);
index = 0;
K=[];
randomNumbers = rand(1,24000000);

for l = 1:10
    for k = 1:100
        S = zeros(1,size);
        for i = 1:size
            for j = 1:100
                index = index+1;
                S(i) = S(i) + randomNumbers(index);            
            end
            K(end+1) = S(i);
        end
        for i = 1:size
            B(i) = (S(i)-mi)/sigma;          
        end
        [h,p(k)] = kstest(B);
    end
    [h,p2(l)] = kstest(p,'cdf',pd);
end
[h,p3] = kstest(p2,'cdf',pd)

figure(1);
histogram(K,10,'Normalization','probability')
title('Znormalizowany rozk³ad sum');
xlabel('Wartoœæ');
ylabel('Prawdopodobieñstwo');

figure(2);
histogram(p,10,'Normalization','probability')
title('Empiryczny rozklad wartoœci p.');
xlabel('Wartoœæ p');
ylabel('Czestotliwosc wystepowania (pi)');



