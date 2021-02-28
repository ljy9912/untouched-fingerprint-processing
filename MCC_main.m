tic
C_set = {im2MCC('1'),im2MCC('2'),im2MCC('3'),im2MCC('4'),im2MCC('5'),im2MCC('6'),im2MCC('7'),im2MCC('8')};
% [mask1, T1] = im2T_mask('1');[mask2, T2] = im2T_mask('2');[mask3, T3] = im2T_mask('3');[mask4, T4] = im2T_mask('4');
% [mask5, T5] = im2T_mask('5');[mask6, T6] = im2T_mask('6');[mask7, T7] = im2T_mask('7');[mask8, T8] = im2T_mask('8');
% save('T_mask_set.mat','T1','T2','T3','T4','T5','T6','T7','T8','mask1','mask2','mask3','mask4','mask5','mask6','mask7','mask8');
% load('T_mask_set.mat')
% C_set = {MCC_encode(T1,mask1),MCC_encode(T2,mask2),MCC_encode(T3,mask3),MCC_encode(T4,mask4)...
%     ,MCC_encode(T5,mask5),MCC_encode(T6,mask6),MCC_encode(T7,mask7),MCC_encode(T8,mask8)};
toc
for i=2:size(C_set,2)
    for j=1:i-1
        score = compare(i,j,C_set);
        if floor((i-1)/3) == floor((j-1)/3)
            fprintf('(Y)')
        else
            fprintf('(N)')
        end
        fprintf('(%d,%d)%.4f\t',j,i,score);
        if j==i-1
            fprintf('\n')
        end
    end
end

function [mask, T] = im2T_mask(img_name)
    img_path = strcat('img/',img_name,'.jpg');
    [~, mask, T] = keypoint_extraction(img_path);
end

function C = im2MCC(img_name)
    img_path = strcat('img/',img_name,'.jpg');
    [~, mask, T] = keypoint_extraction(img_path);
    C = MCC_encode(T,mask);
end

function score = compare(i,j,C_set)
    score = MCC_match(C_set{i},C_set{j});
end

