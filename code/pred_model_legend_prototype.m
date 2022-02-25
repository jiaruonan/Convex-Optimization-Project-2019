function [pred_img] = pred_model_legend_prototype(sample)
%PRED_MODEL_LEGEND_PROTOTYPE the legend model
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
before_2 = rot90(flipud(sample{2}),1);
before_4 = fliplr(sample{4});
before_6 = sample{6};
before_8 = rot90(sample{8},1);

% ########
% for after imgs, 11, 13, 15, 17
after_11 = rot90(flipud(sample{11}),1);
after_13 = fliplr(sample{13});
after_15 = sample{15};
after_17 = rot90(sample{17},1);

% ########
% prepare the X
% ---
X_2 = [];
X_4 = [];
X_6 = [];
X_8 = [];
X_11 = [];
X_13 = [];
X_15 = [];
X_17 = [];
for i = 1:n/2
    tmp2 = before_2(:,i:n/2+i-1,:);
    X_2 = [X_2; tmp2(:)'];
    
    tmp4 = before_4(:,i:n/2+i-1,:);
    X_4 = [X_4; tmp4(:)'];
    
    tmp6 = before_6(:,i:n/2+i-1,:);
    X_6 = [X_6; tmp6(:)'];
    
    tmp8 = before_8(:,i:n/2+i-1,:);
    X_8 = [X_8; tmp8(:)'];
    
    tmp11 = after_11(:,i:n/2+i-1,:);
    X_11 = [X_11; tmp11(:)'];
    
    tmp13 = after_13(:,i:n/2+i-1,:);
    X_13 = [X_13; tmp13(:)'];
    
    tmp15 = after_15(:,i:n/2+i-1,:);
    X_15 = [X_15; tmp15(:)'];
    
    tmp17 = after_17(:,i:n/2+i-1,:);
    X_17 = [X_17; tmp17(:)'];
end 
feat_num = numel(before_5_right);
% cvx_optimization
cvx_begin quiet
    variable A_up(feat_num, n/2)
    variable A_down(feat_num, n/2)
    variable A_left(feat_num, n/2)
    variable A_right(feat_num, n/2)

%     variable S_up(feat_num,feat_num)
%     variable S_down(feat_num,feat_num)
%     variable S_left(feat_num,feat_num)
%     variable S_right(feat_num,feat_num)
    % right, 6:
    M_6 = A_right*X_6;
%     R_6 = S_right*M_6';
    pred_right0 = diag(M_6);
%     pred_right1 = diag(R_6);
    diff_A_right = sum(var(A_right)); % 使各行之间相互接近
    diff_pred_right0 = norm(pred_right0 - before_5_right(:));
%     diff_pred_right1 = norm(pred_right1 - before_5_right(:));
%     diff_right_total = diff_A_right + diff_pred_right0 + diff_pred_right1;
    diff_right_total = diff_A_right + diff_pred_right0;
    
    % left, 4:
    M_4 = A_left*X_4;
%     R_4 = S_left*M_4';
    pred_left0 = diag(M_4);
%     pred_left1 = diag(R_4);
    diff_A_left = sum(var(A_left)); % 使各行之间相互接近
    diff_pred_left0 = norm(pred_left0 - before_5_left(:)); % 在行上找近似
%     diff_pred_left1 = norm(pred_left1 - before_5_left(:)); % 在周围找近似
%     diff_left_total = diff_A_left + diff_pred_left0 + diff_pred_left1;
    diff_left_total = diff_A_left + diff_pred_left0;
    
    % up, 2:
    M_2 = A_up*X_2;
%     R_2 = S_up*M_2';
    pred_up0 = diag(M_2);
%     pred_up1 = diag(R_2);
    diff_A_up = sum(var(A_up)); % 使各行之间相互接近
    diff_pred_up0 = norm(pred_up0 - before_5_up(:)); % 在行上找近似
%     diff_pred_up1 = norm(pred_up1 - before_5_up(:)); % 在周围找近似
%     diff_up_total = diff_A_up + diff_pred_up0 + diff_pred_up1;
    diff_up_total = diff_A_up + diff_pred_up0;
    
    % down, 8:
    M_8 = A_down*X_8;
%     R_8 = S_down*M_8';
    pred_down0 = diag(M_8);
%     pred_down1 = diag(R_8);
    diff_A_down = sum(var(A_down)); % 使各行之间相互接近
    diff_pred_down0 = norm(pred_down0 - before_5_down(:)); % 在行上找近似
%     diff_pred_down1 = norm(pred_down1 - before_5_down(:)); % 在周围找近似
%     diff_down_total = diff_A_down + diff_pred_down0 + diff_pred_down1;
    diff_down_total = diff_A_down + diff_pred_down0;
    
    % combination
    X_right = reshape(pred_right0,n,n/2,3);
    X_left = fliplr(reshape(pred_left0,n,n/2,3));
    X_h = [X_left, X_right];
    
    X_up = flipud(rot90(reshape(pred_up0,n,n/2,3),3));
    X_down = rot90(reshape(pred_down0,n,n/2,3),3);
    X_v = [X_up; X_down];
    
    diff_h_v = (X_h - X_v);
    diff_h_v = norm(diff_h_v(:));
    
    % target
    diff_total = diff_right_total + diff_left_total + diff_up_total + diff_down_total + diff_h_v;
    
    minimize(diff_total)
    
    subject to
        0 <= A_up <= 1;
        0 <= A_down <= 1;
        0 <= A_left <= 1;
        0 <= A_right <= 1;
%         0 <= weight <= 1;
%         0 <= S_up <= 1;
%         0 <= S_down <= 1;
%         0 <= S_left <= 1;
%         0 <= S_right <= 1;
cvx_end



% post-process
X_right = reshape(diag(A_right*X_15),n,n/2,3);
X_left = fliplr(reshape(diag(A_left*X_13),n,n/2,3));
X_h = [X_left, X_right]; % 水平：左右预测合并成一张图

X_up = flipud(rot90(reshape(diag(A_up*X_11),n,n/2,3),3));
X_down = rot90(reshape(diag(A_down*X_17),n,n/2,3),3);
X_v = [X_up; X_down];

pred_img = X_h;
% subplot(3,1,1);
% imshow(uint8(X_h));
% subplot(3,1,2);
% imshow(uint8(X_v));
% subplot(3,1,3);
% imshow(uint8(sample{14}));

end

