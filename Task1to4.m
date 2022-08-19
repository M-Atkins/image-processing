clear; close all;

% Task 1: Pre-processing -----------------------

% Step-1: Load input image
I = imread('IMG_01.png');
figure, imshow(I)
title('original')
saveas(gcf,"Original.png")
%--------------------------

% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);
figure, imshow(I_gray)
title('Gray Conversion')
saveas(gcf,"Gray Conversion")
%--------------------------

% Step-3: Rescale image
I_resize = imresize(I_gray,[512, NaN]);
figure, imshow(I_resize)
title('Rescaled(imresize)')
% Step-4: Produce histogram of the resized image
% histogram(I_resize,64);
% title('Histogram before enhancemnt')
% saveas(gcf,"Histogram before enhancemnt")
%--------------------------

% Step-5: Enhance image before binarisation
I_imadjust = imadjust(I_resize);
figure, imshow(I_imadjust)
title('Image enhanced for binarization')
saveas(gcf,"Image enhanced for binarization")
%--------------------------

% Step-6: Histogram after enhancement
% histogram(I_imadjust);
% title('Histogram after enhanced')
% saveas(gcf,"Histogram after enhanced")
%--------------------------

% Step-7: Image Binarisation
BW = imbinarize(I_imadjust);
figure, imshow(BW)
title('Binarized Image')
saveas(gcf,"Binarized Image")
%--------------------------

% Task 2: Edge detection ------------------------
canny = edge(I_imadjust,'Canny');
figure,imshow(canny)
title('canny edge detection')
saveas(gcf,"canny edge detection")
%--------------------------

% Task 3: Simple segmentation --------------------
level = graythresh(I_resize);
BW = imbinarize(I,level);
figure, imshowpair(I_gray,BW,'montage')
% figure, imshow(BW)
title('Graythresh segmentation')
saveas(gcf,"Graythresh segmentation")

%active contour
mask = zeros(size(I_resize));
mask(25:end-25,25:end-25) = 1;%boundaries
%Create a mask
bw = activecontour(I_resize,mask,900);
figure, imshow(bw)
title('Active Contour Segmentation')
saveas(gcf,"Active Contour Segmentation")


%de-noise with bwareaopen
dnoise = bwareaopen(bw,170);
figure, imshow(dnoise)
title('Denoised image (bweareaopen)')
saveas(gcf,"Denoised image (bweareaopen)")
%--------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 4: Object Recognition --------------------

%read image
i = imread('IMG_11.png');
%greyscale
g = rgb2gray(i);
%enhance image for binarization
ima = imadjust(g);
%simple segmentation on grayscale
level = graythresh(ima);
BW = imbinarize(ima,level);
% figure, imshowpair(ima,BW,'montage')
% title('simple segmentation')
% 
mask = zeros(size(BW));
mask(25:end-25,25:end-25) = 1;
bw = activecontour(BW,mask,900);
% figure, imshow(bw)
% title('active contour')
%----------------------------------%
level = graythresh(ima);
BW = imbinarize(ima,level);
% figure, imshowpair(ima,BW,'montage')
% title('simple segmentation')
%active contour
mask = zeros(size(ima));
mask(25:end-25,25:end-25) = 1; %boundaries
bw = activecontour(ima,mask,1600);
% figure, imshow(bw)
% title('active contour')
%de-noise
bw = bwareaopen(bw,170);
% imshow(bw)
% title('denoise')

figure, imshow(bw)
title('Object Recognition')
saveas(gcf,"Object Recognition")


%fill holes
imfill(bw, 'holes')

%get boundaries of all solid objects
[B,L] = bwboundaries(bw,'noholes');
hold on
% 
 %Loop over every object in B and get boundary.
 for k = 1:length(B)
  boundary = B{k};
 end

% Get region statistics for later
stats = regionprops(L,'Area','Centroid','PixelList');

%Circularity threshold value
threshold = 0.50;

% loop over boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k']
  % Obtain the coordinates of every boundary in k
  boundary = B{k};
  
  % Calculate an estimate of the object perimeter, store
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % get the area for item 'k'
  area = stats(k).Area;
 
  % compute circularity
  metric = 4*pi*area/perimeter^2;
  
%   Display circularity value (for testing)
metric_string = sprintf('%2.2f',metric);

  % mark objects above the threshold with a black circle
  if metric > threshold
    
    fill(boundary(:,2), boundary(:,1), 'r','LineWidth',2 ,'LineJoin','round', 'LineStyle','none');
  end 
  if metric < threshold
      fill(boundary(:,2), boundary(:,1), 'b','LineWidth',2 ,'LineJoin','round', 'LineStyle','none');
  end
  %text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       %'FontSize',14,'FontWeight','bold')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




