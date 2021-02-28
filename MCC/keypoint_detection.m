function [I4, result, mask] = keypoint_detection(I, mask)
m=size(I,1);
n=size(I,2);

%去除黑色的孤岛
I1=bwareaopen(I,40);
%去除白色的孤岛
I1=~I1;
I1=bwareaopen(I1,60);
I1=~I1;
%细化
I2=~I1;
I2=bwmorph(I2,'thin',inf);
I2=~I2;
%去除毛刺
I3=~I2;
len=10;
endpoint=ones(3,3,8)*(-1);
%第一个端点的结构
endpoint(1,1,1)=0;
endpoint(2,1,1)=1;
endpoint(2,2,1)=1;
endpoint(3,1,1)=0;
endpoint(:,:,2)=rot90(endpoint(:,:,1));
endpoint(:,:,3)=rot90(endpoint(:,:,2));
endpoint(:,:,4)=rot90(endpoint(:,:,3));
%第五个端点的结构
endpoint(1,1,5)=1;
endpoint(2,2,5)=1;
endpoint(:,:,6)=rot90(endpoint(:,:,5));
endpoint(:,:,7)=rot90(endpoint(:,:,6));
endpoint(:,:,8)=rot90(endpoint(:,:,7));
for k=1:len
    endpic=zeros(m,n,8);
    for i=1:8
        endpic(:,:,i)=bwhitmiss(I3,endpoint(:,:,i));
        I3=I3-endpic(:,:,i);
    end
end
I_ends=bwmorph(I3,'endpoints',Inf);
se=ones(3,3);

for i=1:len
    I_ends = imdilate(I_ends,se)&~I2;
end
I3=I3|I_ends;
I3=~I3;
%求端点、分叉点
I4=~I3;
neighbour=[[-1,-1];[0,-1];[1,-1];[1,0];[1,1];[0,1];[-1,1];[-1,0];[-1,-1]]; 
CN=zeros(m,n);
for i=2:m-1
    for j=2:n-1
        cn=0;
        if I4(i,j)~=0
            %计算
            for k=1:8
                x1=i+neighbour(k,1);
                y1=j+neighbour(k,2);
                x2=i+neighbour(k+1,1);
                y2=j+neighbour(k+1,2);
                cn=cn+abs(I4(x1,y1)-I4(x2,y2));
            end
            cn=cn/2;
        end
        CN(i,j)=cn;
    end
end

se=strel('disk',70);
mask=imerode(mask,se);
endP=(CN==1);
endP=endP&mask;
branchP=(CN==3);
branchP=branchP&mask;
end_pos=find(endP==1);
[endx,endy]=ind2sub(size(I4),end_pos);
branch_pos=find(branchP==1);
[branchx,branchy]=ind2sub(size(I4),branch_pos);

%计算这些点中任意两点的距离,set a threshold
mindis0=round(m/110);
if 1
    dis0=pdist2([endx,endy],[endx,endy]);
    notfit0=find(dis0>0 & dis0<mindis0);
    [fx0,fy0]=ind2sub(size(dis0),notfit0);
    %找到不符合的点，置零
    endx(fx0)=[];
    endy(fy0)=[];
    
end

%分叉点
%计算这些点中任意两点的距离,set a threshold
mindis1=round(m/60);
if 1
    dis1=pdist2([branchx,branchy],[branchx,branchy]);
    notfit1=find(dis1>0 & dis1<mindis1);
    [fx1,fy1]=ind2sub(size(dis1),notfit1);
    %找到不符合的点，置零
    branchx(fx1)=[];
    branchy(fy1)=[];
end

I4=~I4;
I4 = I4.*mask + 1-mask;
result = [branchx branchy; endx endy];
pic = full(sparse(result(:, 1), result(:, 2), 1, m, n)).*mask;
[result1, result2] = find(pic == 1);
result = [result1 result2];
end
