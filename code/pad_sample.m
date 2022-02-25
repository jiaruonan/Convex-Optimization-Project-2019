function [padded_sample] = pad_sample(sample,block_size)
%PAD_SAMPLE pad the sample, according to block_size
%   此处显示详细说明
s = size(sample{1});
h = s(1);
w = s(2);
h_mod = block_size - mod(h, block_size);
w_mod = block_size - mod(w, block_size);

for i = 1:18
    if h_mod ~= block_size
        h_pad = sample{i}(h,:,:);
        h_pad = repmat(h_pad, h_mod, 1);
        sample{i} = [sample{i}; h_pad];
    end
    if w_mod ~= block_size
        w_pad = sample{i}(:,w,:);
        w_pad = repmat(w_pad, 1, w_mod);
        sample{i} = [sample{i}, w_pad];
    end
end
padded_sample = sample;
end

