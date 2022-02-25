function [clipped_sample] = clip_sample(sample,clip_x,clip_y)
%CLIP_SAMPLE 根据clip_x与clip_y对sample进行裁剪
%   此处显示详细说明
x_start = clip_x(1);
x_end = clip_x(2);
y_start = clip_y(1);
y_end = clip_y(2);
for i = 1:18
    
    if x_start > 0 && x_end > 0
        sample{i} = sample{i}(x_start:x_end,:,:);
    end
    if y_start > 0 && y_end > 0
        sample{i} = sample{i}(:,y_start:y_end,:);
    end
end
clipped_sample = sample;
end

