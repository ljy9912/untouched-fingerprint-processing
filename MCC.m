T = [100 200 0;130 200 5*pi/6;70 200 pi/9;100 250 -pi/2;200 250 pi/2;150 250 -pi/6;250 250 -pi/3;250 200 -2*pi/3];
T1 = [200 200 0;230 200 5*pi/6;180 200 pi/9;200 250 -4*pi/9;300 250 5*pi/11;250 240 -pi/7;350 260 -4*pi/11;350 210 -2*pi/3];
mask = ones(1000,1000);
tic
[C,C_] = encode(T,mask);
[C1,C1_] = encode(T1,mask);
score = match(T,C,C_,T1,C1,C1_);
fprintf('%.4f\n',score)
toc

function [C,C_] = encode(T,mask)
    num = size(T,1);
    N_S = 16;
    N_D = 6;
    R = 70;
    o_s = 28/3;
    o_d = 2*pi/9;
    u = 1/100;
    syms t
    C = zeros(num,N_S,N_S,N_D);
    for n=1:num
        m = T(n,:);
        C_m = zeros(N_S,N_S,N_D);
        for i=1:N_S
            for j=1:N_S
                p_ij = [m(1);m(2)] + 2*R/N_S .*[cos(m(3)),sin(m(3));-sin(m(3)),cos(m(3))]*[i-(N_S+1)/2;j-(N_S+1)/2];
                if sqrt((p_ij(1)-m(1))^2+(p_ij(2)-m(2))^2) <= R && mask(round(p_ij(1)),round(p_ij(2)))==1
                    G_S = zeros(1,num);
                    G_D = zeros(num,N_D);
                    SD_idx = 1;
                    for l=1:num
                        if l ~= n
                            m_t = T(l,:);
                            d_s = sqrt((p_ij(1)-m_t(1))^2+(p_ij(2)-m_t(2))^2);
                            if d_s < 3*o_s
                                G_S(SD_idx) = exp(-(d_s)^2/(2*o_s^2))/(sqrt(2*pi)*o_s);
                                for k = 1:N_D
                                    d_phi_k = -pi+(k-1/2)*2*pi/N_D;
                                    alpha = d_phi(d_phi_k,d_phi(m(3),m_t(3)));
                                    G_D(SD_idx,k) = quadl(@(t)exp(-t.^2/(2*o_d^2)),alpha-pi/N_D,alpha+pi/N_D)/(sqrt(2*pi)*o_d);
                                end
                                SD_idx = SD_idx + 1;
                            end
                        end
                    end
                    if max(G_S(:)) == 0
                        C_m(i,j,:) =[0,0,0,0,0,0];
                    else
                        G_S(SD_idx:end)=[];
                        G_D(SD_idx:end,:)=[];
                        G = G_S*G_D;
                        G(G>u) = 1;
                        G(G<=u) = 0;
                        C_m(i,j,:) = G;
                    end
                else
                    C_m(i,j,:) = [-1,-1,-1,-1,-1,-1];
                end
            end
        end
        C(n,:,:,:) = C_m;
    end
    C_ = C;
    C(C==-1) = 0;
    C_(C_>=0) = 1;
    C_(C_==-1) = 0;
end

function score = match(T1,C1,C_1,T2,C2,C_2)
    n1 = size(C1,1);
    n2 = size(C2,1);
    np = 4 + round(8*(1+exp(-0.4*(min(n1,n2)*20)))^-1);
    T = zeros(n1,n2);
    for i=1:n1
        for j=1:n2
            if abs(d_phi(T1(i,3),T2(j,3))) < pi/2
                m1 = C1(i,:);m_1 = C_1(i,:);
                m2 = C2(i,:);m_2 = C_2(i,:);
                m_12 = m_1&m_2;
                if sum(m_12) > 16*16*6*0.6
                    m1_2 = m1&m_12;
                    m2_1 = m2&m_12;
                    T(i,j) = 1-sum(xor(m1_2,m2_1))/(sum(m1_2)+sum(m2_1));
                else
                    T(i,j) = 0;
                end
            else
                T(i,j) = 0;
            end
        end
    end
    s = sort(T(:));
    score = sum(s(end-np+1:end))/np;
end

function theta = d_phi(theta1,theta2)
    theta = theta1-theta2;
    if theta < -pi
        theta = theta+2*pi;
    elseif theta > pi
        theta = theta-2*pi;
    end
end