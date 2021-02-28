function theta = d_phi(theta1,theta2)
    theta = theta1 - theta2;
    if theta < -pi
        theta = theta + 2*pi;
    elseif theta > pi
        theta = theta - 2*pi;
    end
end
