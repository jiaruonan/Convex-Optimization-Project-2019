function [pred_img, target_img, psnr0, time] = pred_padded(sample_number,block_size,pad_size,thresh,model,clip_x,clip_y)
%PRED_PADDED ��pad����block
%   ���ش���õĸ����;��󣬲�ȥ���Ҳ�����²����䲿��
%   clip_x, [x_start, x_end], ������clip������ȫ0

fprintf('sample_number:%d block_size:%d pad_size:%d thresh:%d\n', sample_number, block_size, pad_size, thresh);
fprintf('model:%s clip_x:%d~%d clip_y:%d~%d\n', model, clip_x(1), clip_x(2), clip_y(1), clip_y(2));

% generate the psnr mat
% load imgs
load('all_samples_order_changed.mat', 'all_samples');

sample = all_samples{sample_number}; % ��ʱ�½��˱�������sample�ĸ��Ĳ����ᵼ��all_samples�ı�

sample = clip_sample(sample, clip_x, clip_y);
target = sample{14};

% psnr_mat_dir = strcat('psnr_mat_s', num2str(sample_number),'_block',num2str(block_size));
% load(psnr_mat_dir, 'psnr_mat');
psnr_mat = gen_psnr_mat(sample, block_size);
fprintf('psnr mat generated! block_size=%d\n', block_size);
% visualization����֤�仯���ȴ��psnrֵ�ͣ�����ʵ�䶯������
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
% for weight prototype: pad ͼƬ����Ȧ������ʵ��һ��Ȩ�صĶ��ѵ������֤�ȶ���
% ע���� pad_sample ������������
% pad_size ����С��block_size/2����4�����򶼽������������
for i = 1:18
    right_pad = repmat(sample{i}(:,w,:),1,pad_size); % ������
    sample{i} = [sample{i}, right_pad]; % ��
    down_pad = repmat(sample{i}(h,:,:), pad_size, 1); % ������
    sample{i} = [sample{i}; down_pad]; % ��
    left_pad = repmat(sample{i}(:,1,:),1,pad_size); % ������
    sample{i} = [left_pad, sample{i}]; % ��
    up_pad = repmat(sample{i}(1,:,:),pad_size,1); % ������
    sample{i} = [up_pad;sample{i}]; % ��
    
end
end
tic;
if strcmp(model, 'transformer_v2plus') || strcmp(model, 'transformer_v3plus')
    if strcmp(model, 'transformer_v2plus')
        pred_img = pred_model_weight_transformer_v2plus(sample,block_size,h_num, w_num, pad_size, psnr_mat, thresh);
    end
else
% ======================================================================
% ======================== ÿ��block����ѧ�Ӳ� ============================
for i = 1:h_num
    for j = 1:w_num
        sub_img = {}; % vector���洢 8 ���ӽ�ǰ���Ӧblock��psnrֵ
        for n = 1:18
            padded_block_n = sample{n}((i-1)*block_size+1:i*block_size+2*pad_size, (j-1)*block_size+1:j*block_size+2*pad_size, :);
            sub_img = [sub_img, double(padded_block_n)];
        end
        % ��ʱsub_img �洢�� i,j ��Ӧblock��18��ͼƬ�ϵ���ͼ
        % ��͹�Ż�ģ��Ӧ�õ���һ����
        % ��Ԥ���block��ֵ��Ԥ�������ͼ�ľ�����
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

