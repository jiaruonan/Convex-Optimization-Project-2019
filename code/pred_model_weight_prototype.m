function [pred_img] = pred_model_weight_prototype(padded_sub_sample, pad_size)
%PRED_MODEL_WEIGHT_PROTOTYPE the weight model
%   改写成矩阵变换形式
%   假设输入的是方形的block
s = size(padded_sub_sample{1});
h = s(1) - 2*pad_size;
w = s(2) - 2*pad_size;

% cvx_optimization
cvx_begin quiet
    variable weight(8, h, w, 3)
    
    diff = [];
    % R,G,B, 3 layers
    for i = 0:2*pad_size
        for j = 0:2*pad_size
            idx = [1,2,3,4,6,7,8,9];
            pred_n = zeros(h, w, 3);
            for n = 1:8
                pred_n = pred_n + padded_sub_sample{idx(n)}( i+1:i+w, j+1:j+h, : ).*squeeze(weight(n,:,:,:));
            end
            
            diff_pred0 = pred_n - padded_sub_sample{5}( i+1:i+w, j+1:j+h, : ); % 变动的GT目标
%             diff_pred1 = pred_n - padded_sub_sample{5}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : ); % 中间的GT目标
            diff_pred = norm(diff_pred0(:));
            diff = [diff, diff_pred];
        end
    end
    minimize(sum(diff))
    
    subject to
        0 <= weight <= 1;
        
        
cvx_end



% pred the X, the sub_img{5}
idx = [1,2,3,4,6,7,8,9];
pred_n = zeros(h, w, 3);
for n = 1:8
    pred_n = pred_n + padded_sub_sample{idx(n)+9}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : ).*squeeze(weight(n,:,:,:));
end

% subplot(3,1,1);
% imshow(uint8(pred_n));
% subplot(3,1,2);
% imshow(uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )));
% subplot(3,1,3);
% imshow(uint8(padded_sub_sample{5}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )));
% 
% psnr(uint8(pred_n),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))
% psnr(uint8(padded_sub_sample{5}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))
% psnr(uint8(padded_sub_sample{11}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))
% psnr(uint8(padded_sub_sample{13}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))
% psnr(uint8(padded_sub_sample{15}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))
% psnr(uint8(padded_sub_sample{17}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )),uint8(padded_sub_sample{14}( pad_size+1:pad_size+w, pad_size+1:pad_size+h, : )))

pred_img = pred_n;
end

