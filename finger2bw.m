function [bw,mask] = finger2bw(im)
[m,n,~] = size(im);
mask=seed_grow(im,10);
im = rgb2gray(im);
im(mask==0)=0;
G_Filter=fspecial('gaussian',round(m/50),round(m/90));
im_Filter = imfilter(im, G_Filter);
im_Diff=im-im_Filter;
im=(im_Diff-min(im_Diff(:)))/(max(im_Diff(:))-min(im_Diff(:)));
bw=part_histeq(im,round(m/30));
bw = imerode(bw,strel('disk',1));
bw = bw-bwareaopen(bw,round(m*n/30));
bw = imdilate(bw,strel('disk',1));
bw = bwareaopen(bw,round(m*n/30000));
end

function mask=seed_grow(im,block_size)
    im = im2double(im);
    [row_num,col_num,~] = size(im);
    row_blk_num = floor(row_num/block_size);
    col_blk_num = floor(col_num/block_size);
    seed = [round(row_blk_num/2),round(col_blk_num/2)];
    mask = zeros(row_blk_num,col_blk_num,'logical');
    mask(seed(1),seed(2))=1;
    queue = [seed];%种子队列
    threshold = .05;%与种子的像素平均值之差的绝对值的阈值
    while size(queue, 1)
        x = queue(1,1);
        y = queue(1,2);
        queue(1,:) = [];
        block = im((x-1)*block_size+1:x*block_size,(y-1)*block_size+1:y*block_size,:);
        block_r = block(:,:,1); block_g = block(:,:,2); block_b = block(:,:,3);
        average_r = mean(block_r(:)); average_g = mean(block_g(:)); average_b = mean(block_b(:));
        for i = -1:1
        	for j = -1:1
                if x+i > 0  &&  x+i <= row_blk_num && y+j > 0  &&  y+j <= col_blk_num && ~mask(x+i,y+j)
                    block_next = im((x+i-1)*block_size+1:(x+i)*block_size,(y+j-1)*block_size+1:(y+j)*block_size,:);
                    block_next_r = block_next(:,:,1); block_next_g = block_next(:,:,2); block_next_b = block_next(:,:,3);
                    if abs(average_r - mean(block_next_r(:)))+abs(average_g - mean(block_next_g(:)))...
                            +abs(average_b - mean(block_next_b(:))) <= threshold
                        mask(x+i, y+j) =1;
                        queue(end+1,:) = [x+i, y+j];
                    end
                end
            end
        end
    end
    mask=imresize(imclose(mask,strel('disk',10)), [row_num,col_num],'nearest');
end

function im_out = part_histeq(im,block_size)
    h = @(block_struct) imbinarize(histeq(block_struct.data));
    im_out = blockproc(im,[block_size block_size],h);
end

