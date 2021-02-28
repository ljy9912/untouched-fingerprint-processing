tic
C_set = {im2MCC('1'),im2MCC('2'),im2MCC('3'),im2MCC('4'),im2MCC('5'),im2MCC('6'),im2MCC('7'),im2MCC('8')};
toc
for i=2:size(C_set,2)
    for j=1:i-1
        score = compare(i,j,C_set);
        fprintf('(%d,%d)%.4f\t',j,i,score);
        if j==i-1
            fprintf('\n')
        end
    end
end

function C = im2MCC(img_name)
    img_path = strcat('img/',img_name,'.jpg');
    [~, mask, T] = keypoint_extraction(img_path);
    C = MCC_encode(T,mask);
end

function score = compare(i,j,C_set)
    score = MCC_match(C_set{i},C_set{j});
end

