clear
tic

fileID = fopen('generated3.bin');       %wczytywanie liczb losowych z pliku
A = fread(fileID, 'ubit32');
fileSize = 64000;
mean = 2500;
std = sqrt(5000);
chi = [];
result = [];
prob = [37/256 56/256 70/256 56/256 37/256]; % prawdopodobieñstwa ka¿dej z liter ABCDE
E4=[];
E5=[];
no_wds = 256000; % number of words liczba s³ów
ltrspwd = 4; % letters per word  liter na s³owo 4 lub 5
wdspos = 5^ltrspwd; % words possibilieties mozliwe s³owa
randomNumbers = randi(2^32,1600000,1);

for k=0:wdspos-1
      Ef = no_wds;%liczba wszystkich s³ów bedzie mno¿ona przez prawdopodobieñstwo danej kombinacji liter
      wd  = k;
      for l=1:ltrspwd 
        ltr = mod(wd,5)+1;%przeliczanie kolejnych indeksów na sekwencje liter A=1 B=2 ..E=5 itd prouszamy siê w systemie liczb o podstawie 5
        Ef = Ef*prob(ltr); %prawdopodobieñstwo s³owa jest kombinacj¹ 
        wd = floor( wd/5);%prouszamy siê w systemie liczb o podstawie 5, wiêc to jest przeskok na kolejn¹ pozycjê 
      end
     E4(k+1)=Ef; %expected frequency oczekiwana liczba s³ów dla danej kombinacji
end

ltrspwd = 5; % letters per word  liter na s³owo 4 lub 5
wdspos = 5^ltrspwd; % words possibilieties mozliwe s³owa
for k=0:wdspos-1
      Ef = no_wds;%liczba wszystkich s³ów bedzie mno¿ona przez prawdopodobieñstwo danej kombinacji liter
      wd  = k;
      for l=1:ltrspwd 
        ltr = mod(wd,5)+1;%przeliczanie kolejnych indeksów na sekwencje liter A=1 B=2 ..E=5 itd prouszamy siê w systemie liczb o podstawie 5
        Ef = Ef*prob(ltr); %prawdopodobieñstwo s³owa jest kombinacj¹ 
        wd = floor( wd/5);%prouszamy siê w systemie liczb o podstawie 5, wiêc to jest przeskok na kolejn¹ pozycjê 
      end
     E5(k+1)=Ef; %expected frequency oczekiwana liczba s³ów dla danej kombinacji
end

    
for v = 0:23
    
    bits = [];                  %bity (do dzielenia liczb na 8bitowe)
    letter = [];                %pojedyncze litery
    words4 = [];                %slowa 5/4 literowe
    words5 = [];
    bitCounter = 0;
    temp=0;
    Q5=0;
    Q4=0;
 
    for i = (fileSize+1)*v+1:(fileSize+2)*v+fileSize+2
        for k = 1:4          %dzielenie liczb na 8 bitowe
            for j = 1:8
                temp=temp+1;
                bitCounter = bitCounter + bitget(A(i),temp);
            end
            bits(end+1)=bitCounter;
            bitCounter = 0;
        end
        temp=0;
    end

    for i = 1:256005
        switch bits(i)              %uzyskiwanie pojedynczych liter
            case {0,1,2}
                letter(end+1) = 1;
            case 3
                letter(end+1) = 2;
            case 4
                letter(end+1) = 3;
            case 5
                letter(end+1) = 4;
            otherwise
                letter(end+1) = 5;     
        end
        if(i<5)
            continue;
        end
        words5(end+1) = letter(i-4)+letter(i-3)*10+letter(i-2)*100+letter(i-1)*1000+letter(i)*10000;
        words4(end+1) = letter(i-3)+letter(i-2)*10+letter(i-1)*100+letter(i)*1000;
    end

    [aa,~,c]=unique(words5', 'rows');
    f5 = [histcounts(c,1:max(c)+1)']; %zliczanie czestotliwosci dla kazdego unikalnego slowa

    [aa,~,c]=unique(words4', 'rows');
    f4 = [histcounts(c,1:max(c)+1)'];

    for i = 1:length(f5)
       Q5 = Q5 + ((f5(i)-E5(i)).^2)/E5(i);
    end

    for i = 1:length(f4)
       Q4 = Q4 + ((f4(i)-E4(i)).^2)/E4(i);
    end

    chi(end+1) = Q5-Q4;
    z = (chi(end)-mean)/std;
    tmp = z/sqrt(2);
    tmp = 1+erf(tmp);
    Phi=tmp/2;
    result(end+1) = 1-Phi;
end

pd = makedist('uniform');
[h,p] = kstest(result,'cdf',pd)
histogram(result,10,'Normalization','probability')
title('Empiryczny rozklad wartoœci p.');
xlabel('Wartoœæ p');
ylabel('Czestotliwosc wystepowania (pi)');

toc
