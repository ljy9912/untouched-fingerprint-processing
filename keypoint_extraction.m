% function img = keypoint_extraction(imgpath)
function [img, result, mask, angle] = keypoint_extraction(imgpath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    path = '2';                                                 %表示第几张图片
    im = imread(imgpath);
    img = rgb2gray(im);
    backup_img = rgb2gray(imread(imgpath));             %备用的img
    
    figure(1);
    subplot(1,3,1) , imshow(img);
    
    img_m = size(img,1)
    img_n = size(img,2)
    
    var_ori = zeros(floor(img_m/4),floor(img_n/4));             
    
      if (path=='2')                                
          
        for i = 1:img_m
            for j  = 1 :img_n                                                       
                if (img(i,j)<120)
                    img(i,j) = 0;
                end
            end
        end
        
        for  i  = 1 : floor(img_m/4)
            for j = 1:floor(img_n/4)
                temp_img = img( (i-1)*4+1 : i*4 , (j-1)*4+1 : j*4 );
                var_ori(i,j) = std2(temp_img);                            %方差
            end
        end
        
        var_ori =imbinarize(var_ori,5);
        
        se = strel('disk',1);                                                       %腐蚀和膨胀
        var_process_1 = imerode(var_ori,se);
        se = strel('disk',13) ;                                         
        var_process_1 = imdilate(var_process_1,se);
        se = strel('disk',2);
        var_process_2 = imerode(var_ori,se);
        se = strel('disk',25) ;
        var_process_2 = imdilate(var_process_2,se);
        mask  = var_process_1.*var_process_2;

        mask = imresize(mask,[img_m, img_n],'bicubic');
        mask = segmentation(im2double(im), 10);
        img_new = im2double(backup_img);
        fore_pic = mask .* img_new;

        part_piece = 16;          
        extend = 32 ;
        
    elseif (path=='1')
    
        for  i  = 1 : floor(img_m/4)
            for j = 1:floor(img_n/4)
                temp_img = img( (i-1)*4+1 : i*4 , (j-1)*4+1 : j*4 );
                var_ori(i,j) = std2(temp_img);                         
            end
        end
        var_ori =imbinarize(var_ori,2);
        se = strel('disk',1);
        var_process_1 = imerode(var_ori,se);
        se = strel('disk',8) ;                                        
        var_process_1 = imdilate(var_process_1,se);
        mask = var_process_1;

        mask = imresize(mask,[img_m, img_n],'bicubic');
        
        img_new = im2double(backup_img);
        fore_pic = mask .* img_new;
        for i = 1:img_m
            for j  = 1 :img_n
                if (fore_pic(i,j)<0.2)
                    fore_pic(i,j) = 0;
                end
            end
        end
        
        part_piece = 8;           
        extend = 16 ;
    else                                            %图像三
        
        for  i  = 1 : floor(img_m/4)
            for j = 1:floor(img_n/4)
                if (i<=2 || i>=floor(img_m/4) - 1)
                    continue;
                elseif (j<=2 || j>=floor(img_n/4) - 1)
                    continue;
                else
                    temp_img = img( (i-1)*4 -5 : i*4 +6, (j-1)*4 - 5 : j*4 +6);
                    std_img = std2(abs(fftshift(fft2(temp_img)))) ;
                    if (std_img <= 2500)
                        var_ori(i, j) = 1;
                    end
                end
            end
        end
        
        
        se = strel('disk',18);
        var_ori = imerode(var_ori, se);
        se = strel('disk',22);
        var_ori = imdilate(var_ori, se);
        mask = imbinarize(var_ori, 0.5);

        mask = imresize(mask,[img_m, img_n],'bicubic');
        
        img_new = im2double(backup_img);
         mask = segmentation(im2double(im), 10);
        fore_pic = mask .* img_new;
        
        part_piece = 8;            
        extend = 32 ;
      end
      
     subplot(1,3,2);imshow(mask);
     subplot(1,3,3); imshow(fore_pic);                              
     
%      imwrite(fore_pic,['output\',path,'_fore_pic.jpg']);

 %%  方向场估计、频率场估计
    
    img_2 = fore_pic;                                          
    img_2 = im2uint8(img_2);                                %要转化不然报错

    if (path~='3')
        [ angle_array , wavelength ,frequency ] = Get_angle_array (img_2,part_piece,extend);
    else
        [ angle_array , wavelength ,frequency ] = Get_angle_array (backup_img,part_piece,extend,path);                  %frequency矩阵 是为了传出频率图显示出来，完成题目要求的图片
    end
    angle_not_smooothed = angle_array;
%% 方向场平滑处理    /   频率(波长)场平滑处理

    filter_g_wavelength= fspecial('Gaussian',[3,3],3);
    wavelength = imfilter(wavelength,filter_g_wavelength,'replicate','same');
    
    frequency = imfilter(frequency,filter_g_wavelength,'replicate','same');
    
    frequency_stretch  = uint8( (frequency-min(min(frequency))) / (  max(max(frequency)) -min(min(frequency)) ) *255 ) ; 
    figure(10); imshow(frequency_stretch,'border','tight','initialmagnification','fit');
    
    filter_g = fspecial('Gaussian',[5,5],1);
    angle_array = pi .* angle_array ./ 90;
    angle_sin = sin (angle_array);
    angle_sin = imfilter(angle_sin,filter_g,'replicate','same');
    angle_cos = cos(angle_array);
    angle_cos = imfilter(angle_cos,filter_g,'replicate','same');
    angle_array = atan2(angle_sin,angle_cos)/2;
    angle_array = 180 .* angle_array ./ pi;
    
    figure(2);
    imshow(backup_img);
%     DrawDir(2,angle_array,part_piece,'r');              %画出脊线的方向来

%% 求脊线增强

    mask_new = imresize(mask, [floor(img_m/part_piece), floor(img_n/part_piece)], 'bicubic');
    mask_new = im2double(mask_new);
    if (path~='3')
        se = strel('disk',2);
        mask_new = imerode(mask_new, se);
    end
    mask_new = imbinarize(mask_new,0.6);                                                                        %初始化脊线增强的蒙版
    
    img_enhancement = img_2;
    enhancement_pic = my_enhance(img_enhancement,mask_new,angle_array,wavelength,part_piece,extend);

    enhancement_max = max(max(enhancement_pic));
    enhancement_min = min(min(enhancement_pic));
    enhancement_pic = (enhancement_pic-enhancement_min)/(enhancement_max-enhancement_min);                      %归一化增强后的图像和滤波处理
    
    filter_g = fspecial('Gaussian',[4,4],8);
    enhancement_pic = imfilter(enhancement_pic, filter_g, 'replicate', 'same');
    enhancement_pic = imbinarize(enhancement_pic,'global');
    
    figure(4);
    imshow(enhancement_pic);
%     img = keypoint_detection(enhancement_pic, mask);
    [img, result] = keypoint_detection(enhancement_pic, mask);
    figure(5);
    imshow(img, []);
    index = round(result/16);
    [num a] = size(result);
    angle = [];
    for i = 1:num
        if index(i, 1)==0
            index(i, 1)=1;
        end
        if index(i, 2)==0
            index(i, 2)=1;
        end
        angle = cat(1, angle, angle_array(index(i, 1), index(i, 2)));
    end
    angle = angle/180*pi;
end

