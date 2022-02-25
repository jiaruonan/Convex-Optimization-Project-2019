% % load imgs to cell, then save the cell
% % orginal order of the img
% data_path = dir(fullfile('data/'));
% folders = {data_path.name};
% folders = folders(1, 3:9);
% all_samples = {};
% for i = 1:7
%     fold_name = folders(i);
%     sample = {};
%     for j = 1:17
%         file_path = strcat('data/', fold_name(1), '/R', num2str(j), '.png');
%         img = imread(file_path{1,1});
%         sample = [sample, img];
%     end
%     X_path = strcat('data/', fold_name{1,1}, '/X.png');
%     X = imread(X_path);
%     sample = [sample, X];
%     all_samples = [all_samples, {sample}];
% end
% imshow(all_samples{1}{1});

% let the X be the 14th img, not the original 18th
% it's for convenience in the programme
data_path = dir(fullfile('data/'));
folders = {data_path.name};
folders = folders(1, 3:9);
all_samples = {};
for i = 1:7
    fold_name = folders(i);
    sample = {};
    for j = 1:17
        if j == 14
            X_path = strcat('data/', fold_name{1,1}, '/X.png');
            X = imread(X_path);
            sample = [sample, X];
        end
        file_path = strcat('data/', fold_name(1), '/R', num2str(j), '.png');
        img = imread(file_path{1,1});
        sample = [sample, img];
    end
    all_samples = [all_samples, {sample}];
end
imshow(all_samples{1}{14});

