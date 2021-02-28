function [bw,mask] = finger2bw(im)
    [m,n,~] = size(im);
    mask=segmentation(im,10);
    im = rgb2gray(im);
    im(mask==0)=0;
    G_Filter=fspecial('gaussian',round(m/50),round(m/90));
    im_Filter = imfilter(im, G_Filter);
    im_Diff=im-im_Filter;
    im=(im_Diff-min(im_Diff(:)))/(max(im_Diff(:))-min(im_Diff(:)));
    bw=block_histeq(im,round(m/30));
    bw = imerode(bw,strel('disk',1));
    bw = bw-bwareaopen(bw,round(m*n/30));
    bw = imdilate(bw,strel('disk',1));
    bw = bwareaopen(bw,round(m*n/30000));
end

function im_out = block_histeq(im,block_size)
    h = @(block_struct) imbinarize(histeq(block_struct.data));
    im_out = blockproc(im,[block_size block_size],h);
end

