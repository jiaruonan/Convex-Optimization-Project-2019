m1 = 'distance'; % 简单权重模型
m2 = 'pred_model_legend_prototype'; % 平移变换模型v1
m3 = 'pred_model_legend_v1'; % 平移变换模型v2
m4 = 'weight_prototype'; % Weight模型
m5 = 'transformer_v1'; % 帧间时域变换模型
m6 = 'transformer_v2'; % 只使用上一帧的 transformer
m7 = 'transformer_v3'; % 垂直水平视角联合优化的 transformer
m8 = 'transformer_v2comprehensive'; % 文中的transformer（前后帧信息都使用、水平视角变换）

% Boys数据
% 左男脸
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img11,target_img11, psnr11, time11] = pred_padded(1,16,1,50,m8,[190,221],[340,371]); % pad_size=0则不使用微位移，pad_size>0使用微位移
figure, subplot(1,2,1), imshow(uint8(pred_img11)), subplot(1,2,2), imshow(uint8(target_img11));

% 右玩偶
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img12,target_img12, psnr12, time12] = pred_padded(1,16,1,50,m8,[320,351],[800,831]); %  pad_size=0则不使用微位移，pad_size>0使用微位移
figure, subplot(1,2,1), imshow(uint8(pred_img12)), subplot(1,2,2), imshow(uint8(target_img12));

% 全图，clip范围全设为0时跑全图
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img13,target_img13, psnr13, time13] = pred_padded(1,16,1,50,m8,[0,0],[0,0]); %  pad_size=0则不使用微位移，pad_size>0使用微位移
figure, subplot(1,2,1), imshow(uint8(pred_img13)), subplot(1,2,2), imshow(uint8(target_img13));



