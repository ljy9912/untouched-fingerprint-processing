% 用Gabor滤波器进行脊线增强的函数
function [enhancement_pic] = finger_enhance(img,mask,angle_array,wavelength,part_piece,extend)
    img_m = size(img, 1);        
    img_n = size(img, 2);
    enhancement_pic = zeros(img_m, img_n);
    ex_piece = (extend - part_piece)/2;
    
    for i=1:floor(img_m/part_piece)
        for j=1:floor(img_n/part_piece)
            if mask(i,j)==1          
                if ((i-1)*part_piece-ex_piece+1<0 || i*part_piece+ex_piece>img_m ...
                        ||(j-1)*part_piece-ex_piece+1<0 || j*part_piece+ex_piece>img_n )          
                Area = padarray(img(part_piece*(i-1)+1:part_piece*i, part_piece*(j-1)+1:part_piece*j),...
                    [ex_piece,ex_piece], 'both', 'replicate');
                else
                Area = img(part_piece*(i-1)+1-ex_piece:part_piece*i+ex_piece, part_piece*(j-1)+1-ex_piece:part_piece*j+ex_piece);
                end     
                temp_angle=angle_array(i, j) + 90;
                temp_wavelength = wavelength(i, j) +2;
                [Amplitude,theta] = imgaborfilt(Area,temp_wavelength,temp_angle);
                Area=Amplitude.*cos(theta);
                Area_max = max(Area(:));
                Area_min = min(Area(:));
                Area = (Area - Area_min) / (Area_max - Area_min);
                enhancement_pic((i-1)*part_piece+1:i*part_piece, (j-1)*part_piece+1:j*part_piece)...
                    = Area(ex_piece+1:extend-ex_piece,ex_piece+1:extend-ex_piece);
            else
                 enhancement_pic((i-1)*part_piece+1:i*part_piece, (j-1)*part_piece+1:j*part_piece)=1;
            end
        end
    end
    enhancement_max = max(max(enhancement_pic));
    enhancement_min = min(min(enhancement_pic));
    enhancement_pic = (enhancement_pic-enhancement_min)/(enhancement_max-enhancement_min);  %归一化
    
    filter_g = fspecial('Gaussian',[4,4],8);
    enhancement_pic = imfilter(enhancement_pic, filter_g, 'replicate', 'same');
    enhancement_pic = imbinarize(enhancement_pic,'global');
end



