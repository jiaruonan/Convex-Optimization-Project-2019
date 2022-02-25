function [] = show_sub_img(sub_img)
%SHOW_SUB_IMG 此处显示有关此函数的摘要
%   此处显示详细说明
figure;
for i = 1:9
    subplot(3,3,i);
    imshow(uint8(sub_img{i}));
end
figure;
for i = 1:9
    subplot(3,3,i);
    imshow(uint8(sub_img{i+9}));
end
end

