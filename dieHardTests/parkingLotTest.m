clear;

fileID = fopen('generated3.bin');        %wczytywanie liczb losowych z pliku
A = fread(fileID, 'ubit32');

fileSize = 240000;
halfFileSize = round(fileSize/2,0);
ratio = 100/2^32;                       %stosunek rzutowania liczb do zakresu 1:100
N = 12000;                              %liczba prób
mi = 3523;                              %oczekiwana œrednia
sigma = 21.9;                           %oczekiwane odchlenie st.
k = 0;                                  %liczba prób z sukcesem
result = [];

B = A*ratio;                            %rzutowanie liczb 8 bitowych do zakresu 1:100
x= B(1 : halfFileSize);                 %wspolrzedne x punktow z genera
y= B(halfFileSize+1 : fileSize);        %wspolrzedne y punktow

x2=[];                                  %wspolrzedne x punktow
y2=[];                                  %wspolrzedne y punktow

for j = 1:10
    for i = (j-1)*12000+1 : j*12000
        check = true;
        for t = 1:length(x2)
            if((abs(x(i)-x2(t)) <= 1) && (abs(y(i)-y2(t)) <= 1))
                check = false;
                break;
            end
        end
        if(check)
            x2(end+1)=x(i);
            y2(end+1)=y(i);
            k = k+1;     
        end
    end
    result(j) = (k-mi)/sigma;
    kr(j) = k;
    k=0;
    x2=[];
    y2=[];
end
mean(kr)
[h,p] = kstest(result)
