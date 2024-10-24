function [horz,v_v,vo1,vo2,H]=hor_rectification(frame)

    %3 steps for the horizontal rectification

    %First find the vanishing points and line at the infinity
    [vo1,vo2,horz,v_v]=vanishing_points(frame);
    disp('Horizontal Vanishing points:');
    display(vo1);
    display(vo2);

    disp('Vertical Vanishing point:');
    disp(v_v);

    disp('Line at the infinity:')
    disp(horz);

    %Then apply the Affine rectification
    [img_affine,H_aff]=affine(horz,frame);
    disp('Affine matrix:');
    disp(H_aff);
    
    %Finally, apply the metric rectification
    [H_met,a,b,d]=metric(img_affine);
    disp('Euclidean matrix:');
    disp(H_met);        

    %Final rectification matrix
    H= H_met * H_aff;
    H = inv(H);
    disp('Rectification Matrix:');
    disp(H);

    %Horizontal Facade ratio
    r=ratio(a,b,d);
    disp('Horizontal Facade ratio:');
    disp(r);

    
    function [vo1,vo2,horz,v]=vanishing_points(frame)
        I=im2double(frame);
        I=rgb2gray(I);
        figure(1),imshow(I),title("Horizontal vanishing points:b   Line at the infinity:r   Vertical vanishing point:g");
        hold on;
        %% Horizontal
        %points for the horizontal plane
        a =[239 ;294; 1];
        b =[297 ;270; 1];
        c =[375 ;296; 1];
        d =[319 ;322; 1];
    
        lab= cross(a,b);
        lbc= cross(b,c);
        lcd= cross(c,d);
        lda= cross(d,a);
        
        %Horizontal vanishing points
        vo1= cross(lab,lcd);
        vo2= cross(lbc,lda);
        vo1=vo1/vo1(3);%normalized vanishing points
        vo2=vo2/vo2(3);

        %line at the infinity
        h = cross(vo1,vo2);
        horz=h/h(3);
        horz=horz';%normalized
    
        %Plots
        text(a(1), a(2), 'a', 'FontSize', 12, 'Color', 'b')
        text(b(1), b(2), 'b', 'FontSize', 12, 'Color', 'b')
        text(c(1), c(2), 'c', 'FontSize', 12, 'Color', 'b')
        text(d(1), d(2), 'd', 'FontSize', 12, 'Color', 'b')
        plot([a(1),vo1(1)],[a(2),vo1(2)],'b');
        plot([b(1),vo1(1)],[b(2),vo1(2)],'b');
        plot([c(1),vo1(1)],[c(2),vo1(2)],'b');
        plot([d(1),vo1(1)],[d(2),vo1(2)],'b');
        plot([a(1),vo2(1)],[a(2),vo2(2)],'b');
        plot([b(1),vo2(1)],[b(2),vo2(2)],'b');
        plot([c(1),vo2(1)],[c(2),vo2(2)],'b');
        plot([d(1),vo2(1)],[d(2),vo2(2)],'b');
        plot([vo1(1), vo2(1)], [vo1(2), vo2(2)], 'r');
    

        %% Vertical
        a =[3; 85; 1];
        b =[11; 140; 1];
        c =[426; 35; 1];
        d =[428; 74; 1];
        
        lab = cross(a, b);
        lcd = cross(c, d);

        %vertical vanishing point
        v_ver = cross(lab, lcd);
        v=v_ver/v_ver(3);

        %Plots
        plot([a(1),v(1)],[a(2),v(2)],'g');
        plot([b(1),v(1)],[b(2),v(2)],'g');
        plot([c(1),v(1)],[c(2),v(2)],'g');
        plot([d(1),v(1)],[d(2),v(2)],'g');
   
        hold off;    
    
    end
    function [img_affine,h_aff]=affine(horz,frame)
        I=im2double(frame);
        I=rgb2gray(I);

        %build the rectification matrix
        h_aff=[1 0 0; 0 1 0; horz(1) horz(2) horz(3)];
       
        %rectify image
        tform = projective2d(h_aff');
        h_aff=tform.T;
        img_affine=imwarp(I,tform);
        a =[239 294 1];
        b =[297 270 1];
        c =[375 296 1];
        d =[319 322 1];
        [A(1),A(2)]= transformPointsForward(tform,a(1),a(2));
        [B(1),B(2)]= transformPointsForward(tform,b(1),b(2));
        [C(1),C(2)]= transformPointsForward(tform,c(1),c(2));
        [D(1),D(2)]= transformPointsForward(tform,d(1),d(2));

       

        %show results
        figure(2), imshow(img_affine),title("Affine Reconstruction"),hold on;
        text(A(1), A(2), 'A', 'FontSize', 12, 'Color', 'g');
        text(B(1), B(2), 'B', 'FontSize', 12, 'Color', 'g');
        text(C(1), C(2), 'C', 'FontSize', 12, 'Color', 'g');
        text(D(1), D(2), 'D', 'FontSize', 12, 'Color', 'g');
        plot([A(1), B(1)], [A(2), B(2)], 'g');
        plot([B(1), C(1)], [B(2), C(2)], 'g');
        plot([C(1), D(1)], [C(2), D(2)], 'g');
        plot([D(1), A(1)], [D(2), A(2)], 'g');
        hold off;
    
        
    end
    function [Hrect,AA,BB,DD]=metric(img_affine)
        %For the metric rectification I'm goint to select 5 pairs of orthogonal
        %segments
        numConstraints = 5; 
        count = 1;


        %orthogonal lines
        l =[-0.0008   -0.0052    1.0000;
            -0.0023    0.0058   -1.0000;
             0.0008    0.0039   -1.0000;
            -0.0023    0.0085   -1.0000;
             0.0008    0.0045   -1.0000];


        m =[-0.0016    0.0071   -1.0000;
            0.0007    0.0041   -1.0000;
            0.0035   -0.0148    0.9999;
           -0.0008   -0.0046    1.0000;
            0.0074   -0.0277    0.9996];
               
        A = zeros(numConstraints,6);
        while (count <=numConstraints)
            li=l(count,:);
            mi=m(count,:);

            % For each pair of orthogonal lines, a constraint on s is created.
            % [l(1)*m(1),l(1)*m(2)+l(2)*m(1), l(2)*m(2)]*s = 0
            % I store the constraints in A matrix
            A(count,:) = [li(1)*mi(1),0.5*(li(1)*mi(2)+li(2)*mi(1)),li(2)*mi(2),...
                      0.5*(li(1)*mi(3)+li(3)*mi(1)),  0.5*(li(2)*mi(3)+li(3)*mi(2)), li(3)*mi(3)];
            
            count = count+1;
        end
        
        hold off;
        %solve the system
        %S = [x(1) x(2); x(2) 1];
        [~,~,v] = svd(A);
        s = v(:,end); %[s11,s12,s22];
        S = [s(1),s(2); s(2),s(3)];
        
        % compute the rectifying homography
        %imDCCP = [S,zeros(2,1); zeros(1,3)]; % image of the circular points
        [U,D,V] = svd(S);
        A = U*sqrt(D)*V';
        H = eye(3);
        H(1,1) = A(1,1);
        H(1,2) = A(1,2);
        H(2,1) = A(2,1);
        H(2,2) = A(2,2);
      
        Hrect = inv(H);
        
        tform = projective2d(Hrect');
        Hrect=tform.T;
        img_metric= imwarp(img_affine,tform);
        img_metric = flip(img_metric,1);
        img_metric=imrotate(img_metric,-90);
%         img_metric=img_metric(400:800,100:500,:);
       

        %show results
        a=[140.6963 173.0742];
        b=[183.0704  166.4276];
        c=[224.5596  177.2524];
        d=[182.1856  183.8990];

        [AA(2),AA(1)]= transformPointsForward(tform,a(1),a(2));
        [BB(2),BB(1)]= transformPointsForward(tform,b(1),b(2));
        [CC(2),CC(1)]= transformPointsForward(tform,c(1),c(2));
        [DD(2),DD(1)]= transformPointsForward(tform,d(1),d(2));

        BB(2)=BB(2)+60;
        CC(2)=CC(2)+60;
        DD(2)=DD(2)+60;
        AA(2)=AA(2)+60;
    
        BB(1)=BB(1)+90;
        CC(1)=CC(1)+90;
        DD(1)=DD(1)+90;
        AA(1)=AA(1)+90;

        %show results
        figure(3),imshow(img_metric),title("Metric Reconstruction"),hold on;
        text(AA(1), AA(2), 'A', 'FontSize', 12, 'Color', 'g');
        text(BB(1), BB(2), 'B', 'FontSize', 12, 'Color', 'g');
        text(CC(1), CC(2), 'C', 'FontSize', 12, 'Color', 'g');
        text(DD(1), DD(2), 'D', 'FontSize', 12, 'Color', 'g');
        plot([AA(1), BB(1)], [AA(2), BB(2)], 'g');
        plot([BB(1), CC(1)], [BB(2), CC(2)], 'g');
        plot([CC(1), DD(1)], [CC(2), DD(2)], 'g');
        plot([DD(1), AA(1)], [DD(2), AA(2)], 'g');
        hold off;
%         disp("Points after affine and metric rectification:")
%         display(AA);
%         display(BB);
%         display(CC);
%         display(DD);


      
    end
    function rr=ratio(a,b,d)
        
        ab = sqrt((a(1) - b(1))^2 + (a(2) - b(2))^2);
        ad = sqrt((a(1) - d(1))^2 + (a(2) - d(2))^2);
        rr= ad/ ab;
    end

end