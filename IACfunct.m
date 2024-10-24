function [IAC]=IACfunct(h,v,vo1,vo2,H)

% Calibration from rectified face plus orthogonal
% vanishing points
% v=vertical vanishing point
% vo1,vo2= orthogonal vanishing points
% Camera calibration (assume skew = 0)
%    w= [ a 0 b
%         0 1 c 
%         b c d ]
    syms a b c d;
    w= [a 0 b; 0 1 c; b c d];
    X = []; 
    Y = [];


%% Solve l′∞=ω𝐯 
    eqn = [];
    for ii= 1:size(h,2)
         hi = h(:,ii);
         hx = [0 -hi(3,1) hi(2,1); hi(3,1) 0 -hi(1,1); -hi(2,1) hi(1,1) 0];
         xi = v(:,ii);
         eqn = [hx(1,:)*w*xi == 0, hx(2,:)*w*xi == 0];
    
    end
% Transform equations into matrices 
    [A,y] = equationsToMatrix(eqn,[a,b,c,d]);
    
    X = [X;double(A)];
    Y = [Y;double(y)];
%% Orthogonality relation
    eqn = [];
    % Solve vo1'*ω*vo2 = 0
    for ii = 1:size(vo1,2)
        vo1i = vo1(:,ii);
        vo2i = vo2(:,ii);
        eqn = [eqn, vo1i.'*w*vo2i==0];
    end

    if size(eqn,2)>0
        % Transform equations into matrices 
        [A,y] = equationsToMatrix(eqn,[a,b,c,d]);
        X = [X;double(A)];
        Y = [Y;double(y)];
    end
%% add constraints on homography
    if size(H)>0

        %Columns of H
        h1 = H(:,1);
        h2 = H(:,2);
    
        % First equation h1'*w*h2 = 0
        eq1 = h1.' * w * h2 == 0;
        % Second equation h1'*w*h1-h2'*w*h2=0
        eq2 = h1.' * w * h1 == h2.'*w*h2;
        % Transform equations into matrices 
        [A,y] = equationsToMatrix([eq1,eq2],[a,b,c,d]);
        A = double(A);
        y = double(y);
        X = [X;A];
        Y = [Y;y];
    end
    
    % fit a linear model without intercept
    lm = fitlm(X,Y, 'y ~ x1 + x2 + x3 + x4 - 1');
    % Coefficients
    W = lm.Coefficients.Estimate;
    
    %Solution
    %W_e = X.'*X \ (X.'*Y)
    IAC = double([W(1,1) 0 W(2,1); 0 1 W(3,1); W(2,1) W(3,1) W(4,1)]);
end
