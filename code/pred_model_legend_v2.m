function [pred_img] = pred_model_legend_v2(sample)
%PRED_MODEL_LEGEND_PROTOTYPE the legend model
%   改写成矩阵变换形式
%   假设输入的是方形的block
s = size(sample{1});
h = s(1);
w = s(2);
n = w;

% pre-process, 把所有图片都统一成右朝向
% for before 9 imgs, drop 1,3,7,9
before_5_right = sample{5}(:,w/2+1:w,:);
before_5_left = fliplr(sample{5}(:,1:w/2,:)); % 水平翻转
before_5_up = rot90(flipud(sample{5}(1:h/2,:,:)),1); % 上下翻转，逆时针90，与down对齐
before_5_down = rot90(sample{5}(h/2+1:h,:,:),1); % 逆时针90
% ---
X_2 = rot90(flipud(sample{2}),1);
X_4 = fliplr(sample{4});
X_6 = sample{6};
X_8 = rot90(sample{8},1);

% ########
% for after imgs, 11, 13, 15, 17
X_11 = rot90(flipud(sample{11}),1);
X_13 = fliplr(sample{13});
X_15 = sample{15};
X_17 = rot90(sample{17},1);



% cvx_optimization
cvx_begin quiet
    variable A_up(n, n/2, 3)
    variable A_down(n, n/2, 3)
    variable A_left(n, n/2, 3)
    variable A_right(n, n/2, 3)
    
    diff = [];
    % R,G,B, 3 layers
    for i = 1:3
        % right, 6:
        pred_right0 = squeeze(X_6(:,:,i))*squeeze(A_right(:,:,i));
        diff_pred_right0 = norm(pred_right0 - squeeze(before_5_right(:,:,i)));
        diff_right_total = diff_pred_right0;

        % left, 4:
        pred_left0 = squeeze(X_4(:,:,i))*squeeze(A_left(:,:,i));
        diff_pred_left0 = norm(pred_left0 - squeeze(before_5_left(:,:,i))); % 在行上找近似
        diff_left_total = diff_pred_left0;

        % up, 2:
        pred_up0 = squeeze(X_2(:,:,i))*squeeze(A_up(:,:,i));
        diff_pred_up0 = norm(pred_up0 - squeeze(before_5_up(:,:,i))); % 在行上找近似
        diff_up_total = diff_pred_up0;

        % down, 8:
        pred_down0 = squeeze(X_8(:,:,i))*squeeze(A_down(:,:,i));
        diff_pred_down0 = norm(pred_down0 - squeeze(before_5_down(:,:,i))); % 在行上找近似
        diff_down_total = diff_pred_down0;

        % combination
        pred_right = reshape(pred_right0,n,n/2);
        pred_left = fliplr(reshape(pred_left0,n,n/2));
        pred_h = [pred_left, pred_right];

        pred_up = flipud(rot90(reshape(pred_up0,n,n/2),3));
        pred_down = rot90(reshape(pred_down0,n,n/2),3);
        pred_v = [pred_up; pred_down];

        diff_h_v = (pred_h - pred_v);
        diff_h_v = norm(diff_h_v(:));

        % diff: A_up, A_down
        diff_A_up_down = (squeeze(A_up(:,:,i)) - squeeze(A_down(:,:,i)));
        diff_A_up_down = norm(diff_A_up_down(:));

        % diff: A_left, A_right
        diff_A_left_right = (squeeze(A_left(:,:,i)) - squeeze(A_right(:,:,i)));
        diff_A_left_right = norm(diff_A_left_right(:));


        % target
        diff_total = (diff_right_total + diff_left_total + diff_up_total + diff_down_total)...
            + diff_h_v + diff_A_up_down + 10*diff_A_left_right;
        diff = [diff, diff_total];
    end
    
    
    minimize(sum(diff))
    
    subject to
        sum(A_up, 1) == 1;
        sum(A_down, 1) == 1;
        sum(A_left, 1) == 1;
        sum(A_right, 1) == 1;
        0 <= A_up <= 1;
        0 <= A_down <= 1;
        0 <= A_left <= 1;
        0 <= A_right <= 1;
        
cvx_end



% post-process
pred_img_h = zeros(n,n,3);
pred_img_v = zeros(n,n,3);
for i = 1:3
    X_right = squeeze(X_15(:,:,i))*squeeze(A_right(:,:,i));
    X_left = fliplr(squeeze(X_13(:,:,i))*squeeze(A_left(:,:,i)));
    X_h = [X_left, X_right]; % 水平：左右预测合并成一张图

    X_up = flipud(rot90(squeeze(X_11(:,:,i))*squeeze(A_up(:,:,i)),3));
    X_down = rot90(squeeze(X_17(:,:,i))*squeeze(A_down(:,:,i)),3);
    X_v = [X_up; X_down];
    
    pred_img_h(:,:,i) = X_h;
    pred_img_v(:,:,i) = X_v;
end

subplot(3,1,1);
imshow(uint8(pred_img_h));
subplot(3,1,2);
imshow(uint8(pred_img_v));
subplot(3,1,3);
imshow(uint8(sample{14}));

pred_img = pred_img_h;
end

