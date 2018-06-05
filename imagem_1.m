% % TRABALHO PRÁTICO DE VISÃO COMPUTACIONAL
% % ESSE CÓDIGO É RESPONSÁVEL PELA CONTAGEM DE PLANTAS NA IMAGEM

% % GUILHERME CARVALHO PEREIRA
% % BRENO AUGUSTO MIRANDA VALENTE

%% INICIO

clear all;
close all;
clc;

warning('off', 'Images:initSize:adjustingMag');         %Utilizado para nao aparecer a mensagem de aviso, quando é mostrado as imagens

%% CARREGA A IMAGEM E CORTA A REGIÃO DESEJADA

Img = imread ('imagem_1.jpg');

Nimg = imcrop(Img,[ 1090 620 2800 2440 ]);

[lin_Nimg ,col_Nimg, ban_Nimg] = size(Nimg);

figure(1)
subplot(1,2,1)
imshow(uint8(Nimg))
title('Imagem RGB')

%% HISTOGRAMA NORMALIZADO DE CADA BANDA DA IMAGEM CORTADA ANTES DE APLICAR O RGB2GRAY

figure(2)

hold on
histogram(Nimg(:,:,1),'Normalization','probability')
histogram(Nimg(:,:,2),'Normalization','probability')
histogram(Nimg(:,:,3),'Normalization','probability')
title('Histograma Normalizado RGB')
legend('Red','Green','Blue')
hold off

%% APLICANDO O RGB2GRAY E MOSTRAR A RGB2GRAY

Nimg = uint8(Nimg);

figure(1)

Nimg_gray = rgb2gray(Nimg);
subplot(1,2,2)
imshow(Nimg_gray);
title('Imagem RGB2GRAY')

%% HISTOGRAMA NORMALIZADO DA NOVA IMAGEM EM TONS DE CINZA

figure(3)

histogram(Nimg_gray,'Normalization','probability')
title('Histograma Normalizado Tons de Cinza')

%% APLICANDO FILTROS SUAVIZADORES COM MASCARAS DE TAMANHOS DIFERENTES

maks_media_9 = fspecial('average', [9 9]);
img_media_9 = imfilter(Nimg,maks_media_9);

maks_media_11 = fspecial('average', [11 11]);
img_media_11 = imfilter(Nimg,maks_media_11);

maks_media_13 = fspecial('average', [13 13]);
img_media_13 = imfilter(Nimg,maks_media_13);

maks_media_15 = fspecial('average', [15 15]);
img_media_15 = imfilter(Nimg,maks_media_15);

figure(4)

subplot(2,2,1)
imshow(img_media_9)
title('Filto Média 9x9')
subplot(2,2,2)
imshow(img_media_11)
title('Filto Média 11x11')
subplot(2,2,3)
imshow(img_media_13)
title('Filto Média 13x13')
subplot(2,2,4)
imshow(img_media_15)
title('Filto Média 15x15')

%% APLICANDO O FILTRO BINARIO 

limiar = 215;

img_bin_9 = mylimiar_Binario(rgb2gray((img_media_9)),limiar);
img_bin_11 = mylimiar_Binario(rgb2gray((img_media_11)),limiar);
img_bin_13 = mylimiar_Binario(rgb2gray((img_media_13)),limiar);
img_bin_15 = mylimiar_Binario(rgb2gray((img_media_15)),limiar);

figure(5)

subplot(2,2,1)
imshow(img_bin_9);
title(['9x9 Limiar: ', num2str(limiar)])
subplot(2,2,2)
imshow(img_bin_11);
title(['11x11 Limiar: ', num2str(limiar)])
subplot(2,2,3)
imshow(img_bin_13);
title(['13x13 Limiar: ', num2str(limiar)])
subplot(2,2,4)
imshow(img_bin_15);
title(['15x15 Limiar: ', num2str(limiar)])
 
%% DILATANDO AS REGIÕES BRANCAS

estrutura_dilate = strel('disk',14);                        % strel -> Morphological structuring element; 
img_dilatada = imdilate(img_bin_11, estrutura_dilate);      % Dilata as regiões brancas para poder retirar qualquer ponto preto dentro da região
    
figure(6)

imshow(img_dilatada);
title('Imagem Dilatada');

%% DEFININDO OS CENTROS DE CADA REGIÃO BRANCA DA IMAGEM DILATADA

img_dilatada_logic = logical(img_dilatada);         % transforma a imagem dilatada em logico para poder achar o centro de cada região
s = regionprops(img_dilatada_logic,'centroid');     % s é uma estrutura contendo os pontos x e y do ponto central de cada região branca
centro = round(cat(1, s.Centroid));                 % aredonda e concatena os valores de s 

figure(7)

subplot(1,2,1)
imshow(Nimg)

hold on
for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), sprintf('%d', k), 'HorizontalAlignment', 'center','VerticalAlignment', 'middle','Color', 'blue');
end
hold off

subplot(1,2,2)
imshow(img_dilatada_logic)

hold on
for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), sprintf('%d', k), 'HorizontalAlignment', 'center','VerticalAlignment', 'middle','Color', 'blue');
end
hold off

%% CRIA UMA NOVA IMAGEM PARA RECEBER 1 NAS POSIÇÔES DO CENTRO

img_centros = zeros(lin_Nimg,col_Nimg);

for i=1:numel(s)
    img_centros( centro(i,2),centro(i,1) ) = 1;
end

%% DILATANDO O CENTRO DAS REGIÕES BRANCAS

estrutura_1 = strel('disk',13);                                  % strel -> Morphological structuring element; 
img_centro_dilatada = imdilate(img_centros, estrutura_1);        % Dilata as regiões brancas para poder retirar qualquer ponto preto dentro da região
    
figure(8)

imshow(img_centro_dilatada);
title('Imagem com os Centros Dilatada');

%% CALCULANDO O PERCENTUAL DE PLANTAS NA IMAGEM

total_pixels = numel(img_dilatada_logic);

pixels_branco = sum(img_dilatada_logic(:) == 1);
pixels_preto = sum(img_dilatada_logic(:) == 0);

porcen_branco = pixels_branco/total_pixels*100;
porcen_preto = pixels_preto/total_pixels*100;

fprintf('A porcentagem de área coberta por plantas é de %2.2f e de área descoberta é %2.2f .\n', porcen_branco, porcen_preto);

%% APLICANDO A TRANSFORMADA DE HOUGH NA IMAGEM COM OS CENTROS

% transformada de hough, retorna a matrix de hough,theta e rho
% o theta esta definido entre 0 e 30 para escolher apenas as linhas verticais
% ainda tem q escolher os melhore valores de theta

[matriz_hough,theta,rho] = hough(img_centro_dilatada,'Theta',-60:0.1:40);     
% [matriz_hough,theta,rho] = hough(img_centro_dilatada); 

%% APLICANDO HOUGHPEAKS PARA DETERMINAR OS PICOS DA MATRIZ GERADA PELA FUNÇÂO hough

picos_hough = houghpeaks(matriz_hough,50,'Threshold',162);                              % determina a quantidade de picos para encontrar na matriz de hough

figure(9) 

imshow(matriz_hough,[],'XData',theta,'YData',rho,'InitialMagnification','fit');         % plot o grafico gerado pela transformada de hough, mostrando os N picos determinados
xlabel('\theta');
ylabel('\rho');
axis on, 
axis normal, 
hold on;
plot(theta(picos_hough(:,2)),rho(picos_hough(:,1)),'s','color','white');
colormap(gca,hot)
colorbar

%% APLICANDO HOUGHLINE PARA DETERMINAR AS LINHAS PARA SEREM GERADAS

lines = houghlines(img_centro_dilatada,theta,rho,picos_hough,'FillGap',100000,'MinLength',1);  % FillGap: se a distancia entre as linhas for menor que o valor determinado, o houghline junta a linha em uma so
                                                                                               % MinLength:se o tamanho da linha for menor q o valor determinado, o hougline discarta a linha


for I = 1:length(lines)
    for J = (1+I):length(lines)
      if abs(lines(I).theta-lines(J).theta) <= 10
         lines(I).theta=round((lines(I).theta + lines(J).theta)/2);
      end  
    end
end 

figure(10)
imshow(Nimg)

hold on 

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2]; 
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');   % plota uma linha entre os dois pontos gerados pela a função houghline
end

% % APARECE A QUANTIDADE DE ALFACES NA IMAGEM

for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), sprintf('%d', k),'HorizontalAlignment', 'center','VerticalAlignment', 'middle','Color','blue','FontSize', 15);
end