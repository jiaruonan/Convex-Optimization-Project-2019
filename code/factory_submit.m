m1 = 'distance'; % ��Ȩ��ģ��
m2 = 'pred_model_legend_prototype'; % ƽ�Ʊ任ģ��v1
m3 = 'pred_model_legend_v1'; % ƽ�Ʊ任ģ��v2
m4 = 'weight_prototype'; % Weightģ��
m5 = 'transformer_v1'; % ֡��ʱ��任ģ��
m6 = 'transformer_v2'; % ֻʹ����һ֡�� transformer
m7 = 'transformer_v3'; % ��ֱˮƽ�ӽ������Ż��� transformer
m8 = 'transformer_v2comprehensive'; % ���е�transformer��ǰ��֡��Ϣ��ʹ�á�ˮƽ�ӽǱ任��

% Boys����
% ������
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img11,target_img11, psnr11, time11] = pred_padded(1,16,1,50,m8,[190,221],[340,371]); % pad_size=0��ʹ��΢λ�ƣ�pad_size>0ʹ��΢λ��
figure, subplot(1,2,1), imshow(uint8(pred_img11)), subplot(1,2,2), imshow(uint8(target_img11));

% ����ż
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img12,target_img12, psnr12, time12] = pred_padded(1,16,1,50,m8,[320,351],[800,831]); %  pad_size=0��ʹ��΢λ�ƣ�pad_size>0ʹ��΢λ��
figure, subplot(1,2,1), imshow(uint8(pred_img12)), subplot(1,2,2), imshow(uint8(target_img12));

% ȫͼ��clip��Χȫ��Ϊ0ʱ��ȫͼ
% sample_number,block_size,pad_size,thresh,model,clip_x,clip_y
[pred_img13,target_img13, psnr13, time13] = pred_padded(1,16,1,50,m8,[0,0],[0,0]); %  pad_size=0��ʹ��΢λ�ƣ�pad_size>0ʹ��΢λ��
figure, subplot(1,2,1), imshow(uint8(pred_img13)), subplot(1,2,2), imshow(uint8(target_img13));



