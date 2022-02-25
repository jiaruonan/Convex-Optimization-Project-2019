function [outputArg1] = gen_psnr_mat(sample,block_size)
%GEN_PSNR_MAT generate psnr_mat
%   sample: a cell includes 18 imgs, from "all_samples"
%   usage example: psnr_mat,padded_sample = gen_psnr_mat(samples{5}, 8)
%   if width(height) mod block_size ~= 0, then pad the last width(height)
% pre-processing
sample = pad_sample(sample, block_size);
% block scan
s = size(sample{1});
h_num = s(1) / block_size;
w_num = s(2) / block_size;
psnr_mat = zeros(h_num, w_num);
idx = [1,2,3,4,6,7,8,9];

for i = 1:h_num
    for j = 1:w_num
        psnr_v = []; % vector：存储 8 个视角前后对应block的psnr值
        for n = 1:8
            block_last = sample{idx(n)}((i-1)*block_size+1:i*block_size, (j-1)*block_size+1:j*block_size, :);
            block_now = sample{idx(n) + 9}((i-1)*block_size+1:i*block_size, (j-1)*block_size+1:j*block_size, :);
            [psnr0, ~] = psnr(block_last, block_now);
            psnr_v = [psnr_v, psnr0];
        end
        mean_psnr = mean(psnr_v);
        psnr_mat(i,j) = mean_psnr;
    end
end
outputArg1 = psnr_mat;
end

% % original code, not the function format
% % generate the psnr mat
% clear;
% % load imgs
% load('all_samples_order_changed.mat', 'all_samples');
% 
% block_size = 8;
% sample = all_samples{2}; % 此时新建了变量，对sample的更改并不会导致all_samples改变
% 
% % pre-processing
% s = size(sample{1});
% h = s(1);
% w = s(2);
% h_mod = block_size - mod(h, block_size);
% w_mod = block_size - mod(w, block_size);
% 
% for i = 1:18
%     if h_mod ~= 0
%         h_pad = sample{i}(h,:,:);
%         h_pad = repmat(h_pad, h_mod, 1);
%         sample{i} = [sample{i}; h_pad];
%     end
%     if w_mod ~= 0
%         w_pad = sample{i}(:,w,:);
%         w_pad = repmat(w_pad, 1, w_mod);
%         sample{i} = [sample{i}, w_pad];
%     end
% end
% 
% % block scan
% s = size(sample{1});
% h_num = s(1) / block_size;
% w_num = s(2) / block_size;
% psnr_mat = zeros(h_num, w_num);
% idx = [1,2,3,4,6,7,8,9];
% 
% for i = 1:h_num
%     for j = 1:w_num
%         psnr_v = []; % vector：存储 8 个视角前后对应block的psnr值
%         for n = 1:8
%             block_last = sample{idx(n)}((i-1)*block_size+1:i*block_size, (j-1)*block_size+1:j*block_size, :);
%             block_now = sample{idx(n) + 9}((i-1)*block_size+1:i*block_size, (j-1)*block_size+1:j*block_size, :);
%             [psnr0, snr] = psnr(block_last, block_now);
%             psnr_v = [psnr_v, psnr0];
%         end
%         mean_psnr = mean(psnr_v);
%         psnr_mat(i,j) = mean_psnr;
%     end
% end
% % visualization，验证变化幅度大的psnr值低，与真实变动结果相符
% heatmap(psnr_mat);   

