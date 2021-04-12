clc;
x = videoinput('winvideo', 1, 'YUY2_640x480');
src = getselectedsource(x);
x.FramesPerTrigger = 1;
x.ReturnedColorspace = 'rgb';       %inicjalizacja kamerki

H=480;                              %rozdzielczoœæ kamerki
W=640;
bity=8;                             %rozmiar liczb w bitach
ileliczb=100000;                    %ile liczb chcemy wygenerowac
sublist=[];                         %lista bitów z danej klatki
list=[];                            %lista losowych bitów
listOrg=[];                         %lista losowych bitów bez postprocessingu
flip=false;                         %czy negowaæ bity danej klatki
                                    %(negujemy bity obrazów parzystych)
tic
while length(list) < ileliczb;
    A=getsnapshot(x);               %pobieramy pojedyncze zdjecie
    for i = 1:H
        for j = 1:W
            for k = 1:3             %3 sk³adowe RGB
                a=A(i,j,k);
                listOrg(end+1)=bitget(a,1);     %przypisujemy najmlodszy bit
                if(a <= 253) && (a >= 2)        %odrzucamy liczby spoza zakresu
                    sublist(end+1)= bitget(a,1);%przypisujemy najmlodszy bit
                end
            end
        end   
    end
    if(flip)                        %odwracamy bity z parzystych obrazow
        sublist=~sublist;
        flip=false;
    else
        flip=true;
    end
    
    bok=floor(sqrt(length(sublist)));%bok dla macierzy kwadratowej
    sublist=sublist(1:bok*bok);      %skracamy wektor zeby pasowaÅ‚ do macierzy kwadratowej
    
    res = reshape(sublist,[bok,bok]);%macierz kwadratowa z wektora bitow
    res=transpose(res);             %transpozycja macierzy
    sublist=reshape(res,1,[]);      %wektor z macierzy ale bierzemy kolumny nie wiersze
    
    r=floor(bok*bok/bity)*bity;     %chcemy wektor o rozmiarze
    sublist=sublist(1:r);           %podzielnym przez 8
    
    res = reshape(sublist,[floor(length(sublist)/bity),bity]);%grupujemy w kolumnach 8-bitowe sÅ‚owa
    
    sublist=[];                     %zerujemy wektor
    for i = 1:length(res)           %tworzymy 8-bitowe sÅ‚owa
        word=res(i,:);              %pobieramy kolumny
        str=num2str(word);          %zamieniamy na typ string
        str(isspace(word))='';      %ucinamy spacje
        m=bin2dec(str);             %zmieniamy na liczby
        sublist(end+1)= m;          %dodajemy slowo do sublisty
        word=[];                    %zerujemy slowo 8bitowe
    end
    
    list = [list, sublist];         %dodajemy do listy uzyskany rezultat z jednej klatki
    if length(list)>ileliczb;
        list=list(1:ileliczb);
        break
    end
    sublist=[];                     %zerujemy rezultat pojedynczej klatki
end


%organizacja liczb dla listy bez postprocessingu
bok=floor(sqrt(length(listOrg)));   %bok dla macierzy kwadratowej
r2=floor(bok*bok/bity)*bity;        %chcemy wektor o rozmiarze
listOrg=listOrg(1:r2);              %podzielnym przez 8
res2 = reshape(listOrg,[floor(length(listOrg)/bity),bity]);%grupujemy w kolumnach 8-bitowe sÅ‚owa
listOrg=[];
for i = 1:length(res2)              %tworzymy 8-bitowe slowa
        word=res2(i,:);             %pobieramy kolumnt
        str=num2str(word);          %zamieniamy na typ string
        str(isspace(word))='';      %ucinamy spacje
        m=bin2dec(str);             %zmieniamy na liczbt
        listOrg(end+1)= m;          %dodajemy slowo do listy
        word=[];                    %zerujemy slowo 8bitowe
end
toc

fileID=fopen('generated.bin', 'w'); %zapis do pliku .bin
fwrite(fileID, list, 'uint8');
fclose(fileID);
  
figure(1);                          %wykres wartoœci próbek losowych bez postprocessingu
h=hist(listOrg,2^bity);
h=h/sum(h);
bar(h);
title('Empiryczny rozklad zmiennych losowych generowanych przez kamerke.');
xlabel('Wartosc');
ylabel('Czestotliwosc wystepowania (pi)');

figure(2);                          %wykres wartoœci próbek losowych
h=hist(list,2^bity);
h=h/sum(h);
bar(h);
title('Empiryczny rozklad zmiennych losowych po postprocessingu.');
xlabel('Wartosc');
ylabel('Czestotliwosc wystepowania (pi)');

%entropia bez postprocessingu
x_normalized = listOrg/max(abs(listOrg));
entropiaOrg = entropy(x_normalized)

%entropia
x_normalized = list/max(abs(list));
entropia = entropy(x_normalized)