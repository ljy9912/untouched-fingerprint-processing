function C = MCC_encode(T,mask)
    m_num = size(T,1);
    [M,N] = size(mask);
    N_S = 10;
    N_D = 7;
    R = round(M/7);
    o_s = round(R/N_S);
    o_d = 2*pi/9;
    u = 1/(15*N_S);
    C_value = zeros(m_num,N_S*N_S*N_D);
    C_angle = zeros(m_num,1);
    invaild_m_num = 0;
    for n=1:m_num
        m = T(n,:);
        neighbor = [];
        valid_cell_num = 0;
        C_m = zeros(N_S,N_S,N_D);
        for i=1:N_S
            for j=1:N_S
                p_ij = [m(1);m(2)] + 2*R/N_S .*[cos(m(3)),sin(m(3));-sin(m(3)),cos(m(3))]*[i-(N_S+1)/2;j-(N_S+1)/2];
                if sqrt((p_ij(1)-m(1))^2+(p_ij(2)-m(2))^2) <= R && abs(M/2-round(p_ij(1))) < M/2 ...
                    && abs(N/2-round(p_ij(2))) < N/2 && mask(round(p_ij(1)),round(p_ij(2)))==1
                    G_S = zeros(1,m_num);
                    G_D = zeros(m_num,N_D);
                    valid_cell_num = valid_cell_num+1;
                    SD_idx = 1;
                    for l=1:m_num
                        if l ~= n
                            m_t = T(l,:);
                            d_s = sqrt((p_ij(1)-m_t(1))^2+(p_ij(2)-m_t(2))^2);
                            if d_s < 3*o_s
                                if ~ismember(l,neighbor)
                                    neighbor(end+1) = l;
                                end
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
                        C_m(i,j,:) = zeros(1,N_D);
                    else
                        G_S(SD_idx:end)=[];
                        G_D(SD_idx:end,:)=[];
                        G = G_S*G_D;
                        G(G>u) = 1;
                        G(G<=u) = 0;
                        C_m(i,j,:) = G;
                    end
                else
                    C_m(i,j,:) = -ones(1,N_D);
                end
            end
        end
        if size(neighbor,2) < 2 || valid_cell_num < 0.75*pi*N_S.^2/4 || size(neighbor,2) > 20
            invaild_m_num = invaild_m_num + 1;
        else
            C_value(n-invaild_m_num,:) = C_m(:);
            C_angle(n-invaild_m_num) = T(n,3);
        end
    end
    C_value(m_num-invaild_m_num+1:m_num,:) = [];
    C_angle(m_num-invaild_m_num+1:m_num) = [];
    C_vaild = C_value;
    C_value(C_value==-1) = 0;
    C_vaild(C_vaild>=0) = 1;
    C_vaild(C_vaild==-1) = 0;
    C = [C_value,C_vaild,C_angle];
end