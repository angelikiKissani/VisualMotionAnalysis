function vert_rectification(frame,K) 
   
% K =1.0e+03 *    [1.0175         0    1.2124;
%                  0    0.9225   -0.0891;
%                  0         0    0.0010];
    I=im2double(frame);
    figure(4),imshow(I),title("Verical facade 4 points selected");
    hold on;
    a =[2 93.5 1];
    b =[13 145.5 1];
    c =[430 71.5 1];
    d =[427 36.5 1];

    lab= cross(a,b);
    lbc= cross(b,c);
    lcd= cross(c,d);
    lda= cross(d,a);
    
    %vanishing points
    vo1= cross(lab,lcd);
    vo2= cross(lbc,lda);
    
    %normalized
    vo1=vo1/vo1(3);
    vo2=vo2/vo2(3);
    %horizon line
    h = cross(vo1,vo2);
    horz=h/h(3);

    %plots for the vertical plane
    text(a(1), a(2), 'a', 'FontSize', 12 , 'Color', 'g');
    text(b(1), b(2), 'b', 'FontSize', 12, 'Color', 'g');
    text(c(1), c(2), 'c', 'FontSize', 12, 'Color', 'g');
    text(d(1), d(2), 'd', 'FontSize', 12, 'Color', 'g');
    plot([a(1), b(1)], [a(2), b(2)], 'g');
    plot([b(1), c(1)], [b(2), c(2)], 'g');
    plot([c(1), d(1)], [c(2), d(2)], 'g');
    plot([d(1), a(1)], [d(2), a(2)], 'g');
    hold off;



    %image of the absolut conic 
    w = inv(K * K');
    syms 'x';
    syms 'y';
    eq1 = w(1,1)*x^2 + 2*w(1,2)*x*y + w(2,2)*y^2 + 2*w(1,3)*x + 2*w(2,3)*y + w(3,3);
    eq2 = horz(1)*x + horz(2) * y + horz(3);

    eqns = [eq1 == 0, eq2 == 0];
    sol = solve(eqns, [x,y]);
    II = [double(sol.x(1));double(sol.y(1));1];
    JJ = [double(sol.x(2));double(sol.y(2));1];
    
    % image of dual conic
    imDCCP = II*JJ.' + JJ*II.';
    imDCCP = imDCCP./norm(imDCCP);
    
    %compute the rectifying homography
    [U,D,~] = svd(imDCCP);
    D(3,3) = 1;
    H = inv(U * sqrt(D));
    disp("Vertical Rectification matrix:")
    disp(H)


    
    % applying the homography to the image
    I=rgb2gray(I);
    tform = projective2d(H.');
    I = imwarp(I,tform);
    I = flip(I, 1); % vertical flip
    I = flip(I, 2); % horizontal + vertical flip

    %[x,y] = transformPointsForward(tform,u,v)

    [A(1),A(2)]= transformPointsForward(tform,a(1),a(2));
    [B(1),B(2)]= transformPointsForward(tform,b(1),b(2));
    [C(1),C(2)]= transformPointsForward(tform,c(1),c(2));
    [D(1),D(2)]= transformPointsForward(tform,d(1),d(2));
    A = - A(1:2);
    B = - B(1:2);
    C = - C(1:2);
    D = - D(1:2);
    A(2) = A(2) -10;
    B(2) = B(2) -10;
    C(2) = C(2) -10;
    D(2) = D(2) -10;
    A(1) = A(1) +200;
    B(1) = B(1) +200;
    C(1) = C(1) +200;
    D(1) = D(1) +200;
 
    figure(5), imshow(I),title("Verical Facade Reconstructed Image"),hold on;
    text(A(1), A(2), 'A', 'FontSize', 12, 'Color', 'g');
    text(B(1), B(2), 'B', 'FontSize', 12, 'Color', 'g');
    text(C(1), C(2), 'C', 'FontSize', 12, 'Color', 'g');
    text(D(1), D(2), 'D', 'FontSize', 12, 'Color', 'g');
    plot([A(1), B(1)], [A(2), B(2)], 'g');
    plot([B(1), C(1)], [B(2), C(2)], 'g');
    plot([C(1), D(1)], [C(2), D(2)], 'g');
    plot([D(1), A(1)], [D(2), A(2)], 'g');
    hold off;
    s = sqrt((A(1) - B(1))^2 + (A(2) - B(2))^2);
    l = sqrt((A(1) - D(1))^2 + (A(2) - D(2))^2);
    r = s / l;
    disp("Vertical Facade ratio:")
    disp(r)
end