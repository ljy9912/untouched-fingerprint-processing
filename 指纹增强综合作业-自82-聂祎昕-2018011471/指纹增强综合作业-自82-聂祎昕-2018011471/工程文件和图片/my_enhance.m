
% 用Gabor滤波器进行脊线增强的函数

function [enhancement_pic] = my_enhance(img_enhancement,mask,angle_array,wavelength,part_piece,extend)
    img_m = size(img_enhancement, 1);        
    img_n = size(img_enhancement, 2);
    enhancement_pic = zeros(img_m, img_n);
    ex_piece = (extend - part_piece)/2;
    for i=1:floor(img_m/part_piece)
        for j=1:floor(img_n/part_piece)
            if mask(i,j)==1          
                if ((i-1)*part_piece-ex_piece+1<0 || i*part_piece+ex_piece>img_m ||(j-1)*part_piece-ex_piece+1<0 || j*part_piece+ex_piece>img_n )          
                Area = padarray(img_enhancement(part_piece*(i-1)+1:part_piece*i, part_piece*(j-1)+1:part_piece*j), [ex_piece,ex_piece], 'both', 'replicate');
                else
                Area = img_enhancement(part_piece*(i-1)+1-ex_piece:part_piece*i+ex_piece, part_piece*(j-1)+1-ex_piece:part_piece*j+ex_piece);
                end     
                temp_angle=angle_array(i, j) + 90;
                temp_wavelength = wavelength(i, j) +2;
                [Amplitude,theta] = imgaborfilt(Area,temp_wavelength,temp_angle);
                Area=Amplitude.*cos(theta);                      
                Area_max = max(max(Area));
                Area_min = min(min(Area));
                Area = (Area - Area_min) / (Area_max - Area_min);
                enhancement_pic((i-1)*part_piece+1:i*part_piece, (j-1)*part_piece+1:j*part_piece) = Area(ex_piece+1:extend-ex_piece,ex_piece+1:extend-ex_piece);
            else
                    continue;
            end
        end
    end
    
    for i=1:floor(img_m/part_piece)
        for j=1:floor(img_n/part_piece)
            if (mask(i,j)==0)
                enhancement_pic((i-1)*part_piece+1:i*part_piece, (j-1)*part_piece+1:j*part_piece)=1;
            end
        end
    end
end



