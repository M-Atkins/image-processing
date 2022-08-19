% Task 5: Robust method --------------------------
clear; close all;

loopFiles()

%Looping through test input files function
function f = loopFiles()
    % Path
    pat='/home/matt/Desktop/Image processing/For Assignment/Assignment_Input/07';
    % Filter file type
    fil=fullfile(pat,'*.png');
    % Directory
    d=dir(fil);
    % For every number of array elements in d
    for k=1:numel(d)
      % Get full file using the path,folder contents,and filename.
      filename=fullfile(pat,d(k).name);
      % Assign to output variable
      f = filename;
      %call prepare function for each file
       prepareImage(f);

    end
end

function out = prepareImage(x)
    i = imread(x);
    % Resize, maintain aspect ration
    r = imresize(i,[512, NaN]);
    % Convert to grascale
    g = rgb2gray(r);
    figure,imshow(g)
    
    % Tophat filtering
    se = strel('disk',12);
         [~,g] = imreducehaze(g);
    tophatFiltered = imtophat(g,se);
    
    figure,imshow(tophatFiltered)

%     bw = imbinarize(ima);
%     bw = bwconvhull(bw,'objects');
    % Enhance
    ima = imadjust(g);
    figure,imshow(ima)
%         figure, imshow(ima)
    bw = imbinarize(ima);
    %active contour
    %create mask
    mask = zeros(size(ima));
    mask(25:end-25,25:end-25) = 1;
    %perform active contouring on the binarized image
    bw = activecontour(ima,mask,900);
    mask = zeros(size(ima));
    mask(25:end-25,25:end-25) = 1;
    %perform active contouring on the binarized image
    bw = activecontour(ima,mask,900);
        figure,imshow(bw)

% %     graythresh
%     level = graythresh(ima);
% 
%     %Binarize image using threshold
%     bw = imbinarize(ima,level);
%     figure,imshow(bw)
%     title('graythresh')


    %fill holes in image
    bw = imfill(bw,'holes');

    %denoise
    bw = bwareaopen(bw,170);
%      figure, imshow(bw)

%watershed
     L = watershed(bw);
     lrgb = label2rgb(L);

     D = -bwdist(~bw);
%      figure,imshow(D,[])
%      title('lrgb')

     Ld = watershed(D);
%      figure, imshow(label2rgb(Ld))

     bw2 = bw;
     bw2(Ld == 0) = 0;
%      figure, imshow(bw2)

     mask = imextendedmin(D,6);
%      imshowpair(bw,mask,'blend')
     
    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw3 = bw;
    bw3(Ld2 == 0) = 0;
    figure, imshow(bw3)


    getBoundaries(bw3,ima)
end

function bOutput = getBoundaries(bw,r) 
% figure,imshowpair(bw,r,'montage')
figure, imshow(bw)

    %imfill(bw, 'holes') % fill all holes == is this needed?

    [B,L] = bwboundaries(bw,'noholes');%returns a label matrix L, where objects and holes are labeled
    hold on % retains current figure
    stats = regionprops(L,'Area','Centroid','PixelList'); %get region properties
    threshold = 0.50; %set circularity threshold,

    for k = 1:length(B) % loop over the boundaries
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};
      
      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      
      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;

      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;
      % display the results
      metric_string = sprintf('%2.2f',metric);

      % fill objects above the threshold
      if metric > threshold
        fill(boundary(:,2), boundary(:,1), 'r','LineWidth',2 ,'LineJoin','round', 'LineStyle','none');
      end 
      
%       show text of boundary roundness value
%       text(boundary(1,2)0-35,boundary(1,1)+13,metric_string,'Color','y',...
%            'FontSize',14,'FontWeight','bold')
    end
    
end

% Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data
% % GT = imread("IMG_01_GT.png");
% % 
% % % To visualise the ground truth image, you can
% % % use the following code.
% % L_GT = label2rgb(rgb2gray(GT), 'prism','k','shuffle');
% % figure, imshow(L_GT)