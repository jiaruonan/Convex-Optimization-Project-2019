function [pred_img] = pred_model_weight_transformer_v3(padded_sub_sample, pad_size)
%PRED_MODEL_WEIGHT_TRANSFORMER weight +
%transformer���������Ҷ��У���Ϸ�ʽΪ���º����ҵ���Ӻ��ټ�ȥĿ��
%   ��ԭ�ȵ���ͨ�� weight ��СΪ������ weight
%   ��� transformer ʵ�ִ洢�˶���Ϣ
%   ����������Ƿ��ε�block
%   v3: l2r, r2l, u2d, d2u transformer

s = size(padded_sub_sample{1});
h = s(1) - 2*pad_size;
w = s(2) - 2*pad_size;


% transformer, cvx_optimization
cvx_begin quiet
    variable l2r(h,h,h)
    variable r2l(h,h,h)
    variable u2d(h,h,h)
    variable d2u(h,h,h)
    
    diff = [];
    % R,G,B, 3 layers
    for i = 0:2*pad_size
        for j = 0:2*pad_size
            idx_lr = [1, 4, 7, 10, 16];
            idx_ud = [1, 2, 3, 10, 12];
            diff_pred = [];
            for n = 1:5
                
                % left & right
                target_lr = padded_sub_sample{idx_lr(n)+1}( i+1:i+w, j+1:j+h, : );
                src_left = padded_sub_sample{idx_lr(n)}( i+1:i+w, j+1:j+h, : );
                src_right = padded_sub_sample{idx_lr(n)+2}( i+1:i+w, j+1:j+h, : );
                pred_left = [];
                pred_right = [];
                
                % up & down
                target_ud = padded_sub_sample{idx_ud(n)+3}( i+1:i+w, j+1:j+h, : );
                src_up = padded_sub_sample{idx_ud(n)}( i+1:i+w, j+1:j+h, : );
                src_down = padded_sub_sample{idx_ud(n)+6}( i+1:i+w, j+1:j+h, : );
                pred_up = [];
                pred_down = [];
                
                for k = 1:h
                    % left & right
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
                   
                   % up & down
                   pred_up1 = squeeze(u2d(k,:,:)) * src_up(:,k,1);
                   pred_up2 = squeeze(u2d(k,:,:)) * src_up(:,k,2);
                   pred_up3 = squeeze(u2d(k,:,:)) * src_up(:,k,3);
                   pred_up0 = [pred_up1, pred_up2, pred_up3];
                   pred_up0 = reshape(pred_up0, h, 1, 3);
                   pred_up = [pred_up,pred_up0];
                   
                   pred_down1 = squeeze(d2u(k,:,:)) * src_down(:,k,1);
                   pred_down2 = squeeze(d2u(k,:,:)) * src_down(:,k,2);
                   pred_down3 = squeeze(d2u(k,:,:)) * src_down(:,k,3);
                   pred_down0 = [pred_down1, pred_down2, pred_down3];
                   pred_down0 = reshape(pred_down0, h, 1, 3);
                   pred_down = [pred_down,pred_down0];
                   
                end
                
                pred_lr = pred_left + pred_right;
                diff_lr = pred_lr - target_lr;
                diff_lr = norm(diff_lr(:));
                
                pred_ud = pred_up + pred_down;
                diff_ud = pred_ud - target_ud;
                diff_ud = norm(diff_ud(:));
                
                if n == 2
                    diff_lr_ud_on5 = pred_lr - pred_ud;
                    diff_lr_ud_on5 = norm(diff_lr_ud_on5(:));
                    diff_pred = [diff_pred, diff_lr_ud_on5];
                end
                
                diff_pred = [diff_pred, diff_lr, diff_ud];
                
            end

            diff = [diff, diff_pred];
        end
    end
    minimize(sum(diff))
    
    subject to
        0 <= l2r <= 1;
        0 <= r2l <= 1;
        0 <= u2d <= 1;
        0 <= d2u <= 1;
        
        
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

