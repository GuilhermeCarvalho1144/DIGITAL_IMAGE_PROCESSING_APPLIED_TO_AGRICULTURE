% % TRABALHO PRÁTICO DE VISÃO COMPUTACIONAL
% % ESSE CÓDIGO É RESPONSÁVEL PELA CONTAGEM DE PLANTAS NA IMAGEM

% % GUILHERME CARVALHO PEREIRA
% % BRENO AUGUSTO MIRANDA VALENTE

%% INICIO

clear all;
close all;
clc;

warning('off', 'Images:initSize:adjustingMag');         %Utilizado para não aparecer a mensagem de aviso, quando é mostrado as imagens

%% CARREGA A IMAGEM E CORTA A REGIÃO DESEJADA

Img = imread ('imagem_2.jpg');

Nimg = imcrop(Img,[ 320 1160 1700 2800 ]);

[lin_Nimg ,col_Nimg, ban_Nimg] = size(Nimg);

figure(1)
subplot(1,2,1)
imshow(Nimg)
title('Imagem RGB')

%% HISTOGRAMA NORMALIZADO DE CADA BANDA DA IMAGEM CORTADA

figure(2)
hold on
histogram(Nimg(:,:,1),'Normalization','probability')
histogram(Nimg(:,:,2),'Normalization','probability')
histogram(Nimg(:,:,3),'Normalization','probability')
title('Histograma Normalizado RGB')
legend('Red','Green','Blue')
hold off

%% APLICAÇÂO DA FUNÇÃO RGB2HSV E A PLOTAGEM DA IMAGEM CONVERTIDA PARA HSV

figure(1)
Nimg_hsv = rgb2hsv(Nimg);
subplot(1,2,2)
imshow(Nimg_hsv);
title('Imagem RGB2HSV')

%% HISTOGRAMA NORMALIZADO DA IMAGEM HSV

figure(3)
hold on
histogram(Nimg_hsv(:,:,1),'Normalization','probability')
histogram(Nimg_hsv(:,:,2),'Normalization','probability')
histogram(Nimg_hsv(:,:,3),'Normalization','probability')
title('Histograma Normalizado HSV')
legend('Hue','Saturation','Value')
legend('Hue','Saturation','Value')
hold off

%% APLICANDO A FUNÇÃO colorThresholder_HSV_image_2 

[BlackWhite,maskedRGBImage] = colorThresholder_HSV_image_2(Nimg);   

figure(4)
subplot(1,2,1)
imshow(BlackWhite);
title('BlackWhite');
subplot(1,2,2)
imshow(maskedRGBImage);
title('maskedRGBImage');

%% DILATANDO AS REGIÕES BRANCAS DA IMAGEM BLACKWHITE

estrutura_dilate = strel('disk',8);                         % strel -> Morphological structuring element; 
img_dilatada = imdilate(BlackWhite, estrutura_dilate);      % Dilata as regiões brancas para poder retirar qualquer ponto preto dentro da região

figure(5)
imshow(img_dilatada);
title('Imagem Dilatada');

%% ERODINDO AS REGIÔES BRANCAS DA IMAGEM BLACKWHITE

estrutura_erode = strel('disk',10);                     % strel -> Morphological structuring element; 
img_erodida = imerode(img_dilatada, estrutura_erode);     % Dilata as regiões brancas para poder retirar qualquer ponto preto dentro da região

figure(6)
imshow(img_erodida);
title('Imagem Erodida');

%% APLICA O FILTRO MEDIANA PARA REMOVER OS RUIDOS

for i= 1:12
    BlackWhite = medfilt2(img_erodida, [ 9 9 ]);
end

figure(7)
imshow(BlackWhite);
title('Imagem com o filtro de mediana')

%% DEFININDO OS CENTROS DE CADA REGIÃO BRANCA DA IMAGEM DEPOIS DE APLICAR A MEDIANA

s = regionprops(BlackWhite,'centroid');     % s é uma estrutura contendo os pontos x e y do ponto central de cada região branca
centro = round(cat(1, s.Centroid));                 % aredonda e concatena os valores de s 
L = bwlabel(BlackWhite);

figure(8)
imshow(Nimg)
hold on
for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), sprintf('%d', k), 'HorizontalAlignment', 'center','VerticalAlignment', 'middle','Color', 'red','FontSize', 15);
end

figure(9)
imshow(BlackWhite)
hold on
for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), sprintf('%d', k), 'HorizontalAlignment', 'center','VerticalAlignment', 'middle','Color', 'red','FontSize', 15');
end
hold off