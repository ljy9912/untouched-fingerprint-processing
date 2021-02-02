     
% 寻找角度和波长（频率）的函数

function  [ angle_array , wavelength ,frequency ] = Get_angle_array(img,part_piece,extend)          
    img_2 = img;
   
    height =size(img_2,1);
    width  = size (img_2,2);
    div_height =floor( height/part_piece);
    div_width = floor(width/part_piece);
    
    angle_array = zeros(div_height , div_width);
    wavelength = zeros(div_height, div_width);
    frequency = zeros(div_height,div_width);
    
    k=64;
    

    for i = 1 : div_height
        for j = 1 : div_width
            Area = double(img_2(part_piece*(i-1) + 1 : part_piece*i , part_piece*(j-1) + 1 : part_piece*j));
            if (((i-1)*part_piece - (extend-part_piece) / 2 +1 < 0) || (i*part_piece +(extend-part_piece) / 2>height) || ((j-1)*part_piece - (extend-part_piece) / 2 +1 < 0) || (j*part_piece +(extend-part_piece) / 2>width))              %之前写成div_height不对
                Area_abs = abs(fftshift(fft2(padarray(Area,[(extend-part_piece) / 2,(extend-part_piece) / 2],'both','replicate'))));
            else
                Area_abs = abs(fftshift(fft2(   img_2( (i-1)*part_piece - (extend-part_piece) / 2 +1 : i*part_piece + (extend-part_piece) / 2  , (j-1)*part_piece - (extend-part_piece) / 2 +1 : j*part_piece + (extend-part_piece) / 2   ) )));
            end

            [ posx,posy ] = find (Area_abs == max(max(Area_abs)));

            Area_abs(posx,posy) = 0 ;
            [ temp,pos_max ] = sort(Area_abs(:),'descend');
            [ x1,y1 ] = ind2sub(size(Area_abs),pos_max(1));
            [ x2,y2 ] = ind2sub(size(Area_abs),pos_max(2));
            angle = atand((y1-y2)/(x1-x2));                   %以度为单位的反正切
            temp_wave = k / sqrt( (x1 - x2)^2 + (y1 - y2)^2 );
            temp_frequency =  sqrt( (x1 - x2)^2 + (y1 - y2)^2 );
            angle_array( i , j ) = angle;
            wavelength( i , j ) =  temp_wave;                            
            frequency( i , j ) = temp_frequency;
        end
    end

end


