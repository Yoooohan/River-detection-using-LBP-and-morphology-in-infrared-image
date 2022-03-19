%----------------------------------------------------------------------------------------%
% River detection using LBP and morphology in infrared image（chapter3-1 in the thesis）--%
% This method utilizes improved LBP feature and combined with some
% morphology approaches to detect the river in Landsat8-band5 images
% Coder: Yuhan Liu
% Latest modified date:2020.10.21
% If you have problems, please contact Yuhan by sending email to yuhanliu0211@outlook.com
%----------------------------------------------------------------------------------------%
%% input
% clear all;close all;clc;
makeLBPMap;% acquire the index map of LBP

I=imread('data381.tif');
GT=im2bw(imread('GT381.jpg'));
%% acquire ground truth,when run the algorithm,comment this part
% figure,imshow(I,[])
% h = drawfreehand;
% Mask1 = createMask(h);
% figure,imshow(I,[])
% h = drawfreehand;
% Mask2 = createMask(h);
% figure,imshow(I,[])
% h = drawfreehand;
% Mask3 = createMask(h);
% Mask=Mask1-Mask2+Mask3;
% GT = activecontour(I,Mask,80);
% figure,imshow(GT)
% imwrite(GT,'GT360.jpg');
%% pre-processing
% r=[1,2,3,4,5];
% for j=1:length(r)
tic
I1=double(I).^0.67;% image enhancement,default=0.67
% figure,imshow(I,[])
% I1=uint8(I1);
se = strel('disk',70); %default r=70
mask=I1;
marker = imerode(mask,se);
input=(imreconstruct(marker,mask));
% figure,imshow(input,[])
%% acquire LBP feature
zp=zeros(size(input,1)+4,size(input,2)+4);
zp(3:end-2,3:end-2)=input;
% [histLBP, MatLBP]=getLBPFea_4(zp);% improved LBP{8,1.5}
 [histLBP, MatLBP]=getLBPFea(zp);% original LBP{8,2}
% figure,imshow(uint8(MatLBP))
 MatLBP=imfilter(MatLBP,fspecial('gaussian'),'same');
% figure,imshow(uint8(MatLBP))

%% thresholding
%   for i=1:size(MatLBP,1)
%       r=MatLBP(i,:);
%       rn=zeros(1,length(r));
%       for j=2:size(MatLBP,2)
%   if (abs(r(j)-r(j-1)))>10
%       rn(j)=255;
%       rn(j-1)=0;
%       end
%       end
%  result(i,:)=rn;
%   end
T=1;
for i=1:length(T)
result=im2bw(uint8(MatLBP),T(i));%default=0.7
result=result;
% figure,imshow(result,[]);


%% morphology method

f1=imopen(result,strel('disk',2));
% figure,imshow(f1)
% f2=imclose(result,strel('disk',1));
f2=~f1;
% figure,imshow(f2,'border','tight')
% ju
% imLabel = bwlabel(~f2);                %对各连通域进行标记  
% stats = regionprops(imLabel,'Area');    %求各连通域的大小  
% area = cat(1,stats.Area);  
% index = find(area == max(area));        %求最大连通域的索引  
% img = ismember(imLabel,index);          %获取最大连通域图像
% figure,imshow(img)
toc


%% evaluation

[m n]=size(GT);
tp=sum(sum(GT.*f2));
fn=sum(sum(GT))-tp;
fp=sum(sum(f2))-tp;
tn=m*n-tp-fn-fp;
acc=(tp+tn)/(m*n);
recall=tp/(tp+fn);
pre=tp/(tp+fp);
fpr=fp/(tn+fp);
po=acc;
pe=((tp+fn)*(tp+fp)+(fp+tn)*(fn+tn))/((m*n).^2);
k=(po-pe)/(1-pe);
FPR(i)=fpr;
TPR(i)=recall;
PRE(i)=pre;
REC(i)=recall;
K(i)=k;
end
% AUC(j)=trapz(FPR(j,:),TPR(j,:));
AUC=trapz(FPR,TPR);
AUCPR=trapz(REC,PRE);
% figure(1),plot(FPR,TPR,'linewidth',1,'marker'),hold on;
% end
