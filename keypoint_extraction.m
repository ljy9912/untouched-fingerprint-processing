function [img, mask, T] = keypoint_extraction(imgpath)
    im = im2double(imread(imgpath));
    [img_m,img_n,~] = size(im);
    [bw,mask] = finger2bw(im);
    fore_pic = ~bw;
%     figure,imshow(fore_pic)

    part_piece = 2*round(img_m/120);
    extend = 2*part_piece ;               

%% 方向场估计、波长场估计                                        
    img_2 = im2double(fore_pic);
    [ angle_array , wavelength ,~ ] = Get_angle_array (img_2,part_piece,extend);
%% 方向场及波长场平滑处理
    filter_g_wavelength= fspecial('Gaussian',[3,3],3);
    wavelength = imfilter(wavelength,filter_g_wavelength,'replicate','same');
    filter_g = fspecial('Gaussian',[5,5],1);
    angle_array = pi .* angle_array ./ 90;
    angle_sin = sin(angle_array);
    angle_sin = imfilter(angle_sin,filter_g,'replicate','same');
    angle_cos = cos(angle_array);
    angle_cos = imfilter(angle_cos,filter_g,'replicate','same');
    angle_array = atan2(angle_sin,angle_cos)/2;
    angle_array = 180 .* angle_array ./ pi;

%% 求脊线增强
    %初始化脊线增强的蒙版
    mask_new = imresize(mask, [floor(img_m/part_piece), floor(img_n/part_piece)], 'bicubic');
    mask_new = imerode(mask_new, strel('disk',2));                                                                 
    %脊线增强
    enhancement_pic = finger_enhance(img_2,mask_new,angle_array,wavelength,part_piece,extend);
%     figure,imshow(enhancement_pic);

%%获取细节点
    [img, result, mask] = keypoint_detection(enhancement_pic, mask);
%     figure,imshow(img, []);
    index = round(result/part_piece);
    index(index==0) = 1;
    index = sub2ind(size(mask_new),index(:,1),index(:,2));
    angle = angle_array(index)/180*pi;
    T = [result,angle];
end

