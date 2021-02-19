function score = MCC_match(T1,C1,T2,C2)
    N_S = 10;
    n1 = size(C1,1);
    n2 = size(C2,1);
    np = 4 + round(8*(1+exp(-0.4*(min(n1,n2)-20)))^-1);
    T = zeros(n1,n2);
    for i=1:n1
        for j=1:n2
            if abs(d_phi(T1(i,3),T2(j,3))) < pi/2
                m1 = C1(i,:,1);m_1 = C1(i,:,2);
                m2 = C2(j,:,1);m_2 = C2(j,:,2);
                m_12 = m_1&m_2;
                if sum(m_12) > N_S.^2*6*0.6
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
    T(isnan(T)) = 0;
    s = sort(T(:));
    score = sum(s(end-np+1:end))/np;
end
