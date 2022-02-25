function [pred_img] = pred_model_weight_transformer_v2comprehensive(padded_sub_sample, pad_size)
%PRED_MODEL_WEIGHT_TRANSFORMER weight + transformer
%   将原先的逐通道 weight 减小为逐像素 weight
%   添加 transformer 实现存储运动信息
%   假设输入的是方形的block
%   v2: l2r, r2l transformer

s = size(padded_sub_sample{1});
h = s(1) - 2*pad_size;
w = s(2) - 2*pad_size;


% transformer, cvx_optimization
cvx_begin quiet
    variable l2r(h,h,h)
    variable r2l(h,h,h)
%     variable u2d(h,h,h)
%     variable d2u(h,h,h)
    
    diff = [];
    % R,G,B, 3 layers
    for i = 0:2*pad_size
        for j = 0:2*pad_size
            idx = [1, 4, 7, 10, 16];
            diff_pred = [];
            for n = 1:5
                src_left = padded_sub_sample{idx(n)}( i+1:i+w, j+1:j+h, : );
                src_right = padded_sub_sample{idx(n)+2}( i+1:i+w, j+1:j+h, : );
                target = padded_sub_sample{idx(n)+1}( i+1:i+w, j+1:j+h, : );
                pred_left = [];
                pred_right = [];
                for k = 1:h
                   pred_left1 = src_left(k,:,1) * squeeze(l2r(k,:,:));
                   pred_left2 =  src_left(k,:,2) * squeeze(l2r(k,:,:));
                   pred_left3 =  src_left(k,:,3) * squeeze(l2r(k,:,:));
                   pred_left0 = [pred_left1; pred_left2; pred_left3];
                   pred_left0 = reshape(pred_left0', 1, h, 3);
                   pred_left = [pred_left;pred_left0];
                   
                   pred_right1 = src_right(k,:,1) * squeeze(r2l(k,:,:));
                   pred_right2 =  src_right(k,:,2) * squeeze(r2l(k,:,:));
                   pred_right3 =  src_right(k,:,3) * squeeze(r2l(k,:,:));
                   pred_right0 = [pred_right1; pred_right2; pred_right3];
                   pred_right0 = reshape(pred_right0', 1, h, 3);
                   pred_right = [pred_right;pred_right0];
                   
                end
                
                pred_comb = pred_left + pred_right;
                diff0 = pred_comb - target;
                diff0 = norm(diff0(:));
                diff_pred = [diff_pred, diff0];
                
            end

            diff = [diff, diff_pred];
        end
    end
    minimize(sum(diff))
    
    subject to
        0 <= l2r <= 1;
        0 <= r2l <= 1;
%         0 <= u2d <= 1;
%         0 <= d2u <= 1;
        
        
cvx_end


src_left = padded_sub_sample{13}(pad_size+1:pad_size+w, pad_size+1:pad_size+h, :);
src_right = padded_sub_sample{15}(pad_size+1:pad_size+w, pad_size+1:pad_size+h, :);
target = padded_sub_sample{14}(pad_size+1:pad_size+w, pad_size+1:pad_size+h, :);
pred_left = [];
pred_right = [];
for k = 1:h
   pred_left1 = src_left(k,:,1) * squeeze(l2r(k,:,:));
   pred_left2 =  src_left(k,:,2) * squeeze(l2r(k,:,:));
   pred_left3 =  src_left(k,:,3) * squeeze(l2r(k,:,:));
   pred_left0 = [pred_left1; pred_left2; pred_left3];
   pred_left0 = reshape(pred_left0', 1, h, 3);
   pred_left = [pred_left;pred_left0];

   pred_right1 = src_right(k,:,1) * squeeze(r2l(k,:,:));
   pred_right2 =  src_right(k,:,2) * squeeze(r2l(k,:,:));
   pred_right3 =  src_right(k,:,3) * squeeze(r2l(k,:,:));
   pred_right0 = [pred_right1; pred_right2; pred_right3];
   pred_right0 = reshape(pred_right0', 1, h, 3);
   pred_right = [pred_right;pred_right0];
end
pred_comb = pred_left + pred_right;

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

pred_img = pred_comb;
end

