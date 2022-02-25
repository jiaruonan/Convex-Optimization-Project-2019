function [pred_img] = pred_model_distance(sub_img)
%PRED_MODEL_DISTANCE 插值预测
%   看作在前后、相邻图片之间差值
s = size(sub_img{1});

for i = 1:18
    sub_img{i} = double(sub_img{i});
end

integrate = [];
idx = [1,2,3,4,6,7,8,9];
for i = 1:8
    integrate = [integrate, sub_img{idx(i)}(:)];
end

% 从前一帧学习权重
cvx_begin quiet
    variable weight(8,1); % 从前一帧学习权重
%     target = mean(integrate * weight) - sub_img{5}(:);
    target = (integrate * weight) - sub_img{5}(:);
    minimize(norm(target))
    subject to
        0 <= weight <= 1;
        sum(weight) == 1;
cvx_end

integrate = [];
idx = [1,2,3,4,6,7,8,9];
for i = 1:8
    integrate = [integrate, sub_img{idx(i)+9}(:)];
end

% 根据学来的权重预测
cvx_begin quiet
    variable pred_imgX(s)
    target = (integrate * weight) - pred_imgX(:);
    minimize(norm(target))
    subject to
        0 <= pred_imgX <= 255;
cvx_end

pred_img = pred_imgX;
end

