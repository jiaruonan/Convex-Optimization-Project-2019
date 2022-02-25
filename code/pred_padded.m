function [pred_img, target_img, psnr0, time] = pred_padded(sample_number,block_size,pad_size,thresh,model,clip_x,clip_y)
%PRED_PADDED 被pad过的block
%   返回处理好的浮点型矩阵，裁去最右侧和最下侧的填充部分
%   clip_x, [x_start, x_end], 不进行clip则输入全0

fprintf('sample_number:%d block_size:%d pad_size:%d thresh:%d\n', sample_number, block_size, pad_size, thresh);
fprintf('model:%s clip_x:%d~%d clip_y:%d~%d\n', model, clip_x(1), clip_x(2), clip_y(1), clip_y(2));

% generate the psnr mat
% load imgs
load('all_samples_order_changed.mat', 'all_samples');

sample = all_samples{sample_number}; % 此时新建了变量，对sample的更改并不会导致all_samples改变

sample = clip_sample(sample, clip_x, clip_y);
target = sample{14};

% psnr_mat_dir = strcat('psnr_mat_s', num2str(sample_number),'_block',num2str(block_size));
% load(psnr_mat_dir, 'psnr_mat');
psnr_mat = gen_psnr_mat(sample, block_size);
fprintf('psnr mat generated! block_size=%d\n', block_size);
% visualization，验证变化幅度大的psnr值低，与真实变动结果相符
% heatmap(psnr_mat);            
original_size = size(sample{1});
sample = pad_sample(sample, block_size);

s = size(sample{1});
h = s(1);
w = s(2);
h_num = s(1) / block_size;
w_num = s(2) / block_size;
pred_img = zeros(s);

if pad_size > 0
% for weight prototype: pad 图片最外圈，用来实现一个权重的多次训练，保证稳定性
% 注意与 pad_sample 函数进行区分
% pad_size 必须小于block_size/2，往4个方向都进行这样的填充
for i = 1:18
    right_pad = repmat(sample{i}(:,w,:),1,pad_size); % 最右列
    sample{i} = [sample{i}, right_pad]; % 右
    down_pad = repmat(sample{i}(h,:,:), pad_size, 1); % 最下行
    sample{i} = [sample{i}; down_pad]; % 下
    left_pad = repmat(sample{i}(:,1,:),1,pad_size); % 最左行
    sample{i} = [left_pad, sample{i}]; % 左
    up_pad = repmat(sample{i}(1,:,:),pad_size,1); % 最上行
    sample{i} = [up_pad;sample{i}]; % 上
    
end
end
tic;
if strcmp(model, 'transformer_v2plus') || strcmp(model, 'transformer_v3plus')
    if strcmp(model, 'transformer_v2plus')
        pred_img = pred_model_weight_transformer_v2plus(sample,block_size,h_num, w_num, pad_size, psnr_mat, thresh);
    end
else
% ======================================================================
% ======================== 每个block各自学视差 ============================
for i = 1:h_num
    for j = 1:w_num
        sub_img = {}; % vector：存储 8 个视角前后对应block的psnr值
        for n = 1:18
            padded_block_n = sample{n}((i-1)*block_size+1:i*block_size+2*pad_size, (j-1)*block_size+1:j*block_size+2*pad_size, :);
            sub_img = [sub_img, double(padded_block_n)];
        end
        % 此时sub_img 存储了 i,j 对应block在18张图片上的子图
        % 将凸优化模型应用到这一部分
        % 将预测的block赋值到预测的整张图的矩阵上
        if psnr_mat(i,j) > thresh
            pred_block = sub_img{5}(pad_size+1:pad_size+block_size,pad_size+1:pad_size+block_size,:);
        else
            if strcmp(model,'weight_prototype')
                pred_block = pred_model_weight_prototype(sub_img, pad_size);
            elseif strcmp(model, 'pred_model_legend_prototype')
                if pad_size ~= 0
                    fprintf('Error, legend model can not be padded! pad_size must=0')
                else
                    pred_block = pred_model_legend_prototype(sub_img);
                end
            elseif strcmp(model, 'pred_model_legend_v1')
                if pad_size ~= 0
                    fprintf('Error, legend model can not be padded! pad_size must=0')
                else
                    pred_block = pred_model_legend_v1(sub_img);
                end
            elseif strcmp(model, 'distance')
                if pad_size ~= 0
                    fprintf('Error, distance model can not be padded! pad_size must=0')
                else
                    pred_block = pred_model_distance(sub_img);
                end
            elseif strcmp(model, 'transformer_v1')
                pred_block = pred_model_weight_transformer_v1(sub_img, pad_size);
            elseif strcmp(model, 'transformer_v2')
                pred_block = pred_model_weight_transformer_v2(sub_img, pad_size);
            elseif strcmp(model, 'transformer_v2comprehensive')
                pred_block = pred_model_weight_transformer_v2comprehensive(sub_img, pad_size);
            elseif strcmp(model, 'transformer_v3')
                pred_block = pred_model_weight_transformer_v3(sub_img, pad_size);
            else
                fprintf('Error: model name error !!!!!')
            end
            
        end
        pred_img((i-1)*block_size+1:i*block_size, (j-1)*block_size+1:j*block_size, :) = pred_block;
        fprintf('i:%d, j:%d\n', i,j);
    end
end
toc;
end


time = toc / (h_num*w_num*block_size*block_size);
pred_img = pred_img(1:original_size(1),1:original_size(2),:);
target_img = target;
psnr0 = psnr(uint8(pred_img), uint8(target));
end

