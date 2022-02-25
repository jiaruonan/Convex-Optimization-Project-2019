function [pred_img] = pred_model_distance(sub_img)
%PRED_MODEL_DISTANCE ��ֵԤ��
%   ������ǰ������ͼƬ֮���ֵ
s = size(sub_img{1});

for i = 1:18
    sub_img{i} = double(sub_img{i});
end

integrate = [];
idx = [1,2,3,4,6,7,8,9];
for i = 1:8
    integrate = [integrate, sub_img{idx(i)}(:)];
end

% ��ǰһ֡ѧϰȨ��
cvx_begin quiet
    variable weight(8,1); % ��ǰһ֡ѧϰȨ��
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

% ����ѧ����Ȩ��Ԥ��
cvx_begin quiet
    variable pred_imgX(s)
    target = (integrate * weight) - pred_imgX(:);
    minimize(norm(target))
    subject to
        0 <= pred_imgX <= 255;
cvx_end

pred_img = pred_imgX;
end

