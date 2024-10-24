function K=calibration(frame)
    [vo1,vo2,horz,v]=vanishing_points(frame);


    H=[0.4936    0.8091    0.0002;
        0.8091   -0.0028   -0.0026;
         0         0    1.0000];

    
    IAC=IACfunct(horz,v,vo1,vo2,H);
    display(IAC);

    % ω=[a^2  0       -u0*a^2
    %     *   1         -v0 
    %     *   *   fy^2 + a^2*u0^2 + v0^2]
    %
    % focal distance 𝑓x
    % focal distance 𝑓y 
    % principal point (u0,v0) 
    % aspect ratio a

    aa = sqrt(IAC(1,1));
    u0 = -IAC(1,3)/(aa^2);
    v0 = -IAC(2,3);
    fy = sqrt(IAC(3,3) - (aa^2)*(u0^2) - (v0^2));
    fx = fy / aa;
    display(aa);
    display(fx);
    display(fy);

    % K=calibration matrix  
    % 
    % K=[fx  0  u0
    %    0  fy  v0
    %    0   0  1 ]
         
    K = [fx 0 u0; 0 fy v0; 0 0 1];
    display(K);

    function [vo1,vo2,horz,v]=vanishing_points(frame)
        I=rgb2gray(frame);
        imshow(I),title(["Horizontal vanishing points:b   Line at the infinity:r ", ...
            "Vertical vanishing point:g"]);
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
        
        
   
        hold off; 
       end

end