function localization()

    %Homography
    H=[0.4936    0.8091    0.0002;
    0.8091   -0.0028   -0.0026;
         0         0    1.0000];

    %calibration matrix
    K =1.0e+03 *    [1.0175         0    1.2124;
                     0    0.9225   -0.0891;
                     0         0    0.0010];
    %vertical fascade points
   
    A=[85.36 246.17];
    B=[128.80 241.72];
    C=[162.56 304.96];
    D=[119.11 309.40];
    image_points = [A; B; C; D];


    %Facades ratios
    r_ver=0.1208;

    l_r = 500;
    s_r = l_r * r_ver;

    real_points = [0 0;0 l_r;s_r l_r; s_r 0];   
    

    %now I use the real and image points to find the homography
    % between the world reference frame and the image reference frame 
    tform = fitgeotrans(image_points, real_points, 'projective');
    H_imgtoworld  = (tform.T).';
    
    % world reference frame 
    % to image reference frame homography 
    H_worldtoimg = H_imgtoworld * H;
    H_worldtoimg =inv(H_worldtoimg);

    % splitting homography columns for the localization process 
    h1 = H_worldtoimg(:,1);
    h2 = H_worldtoimg(:,2);
    h3 = H_worldtoimg(:,3);

    lambda = 1 / norm(K \ h1);
    
    % r1 = K^-1 * h1 normalized
    r1 = (K \ h1) * lambda;
    r2 = (K \ h2) * lambda;
    r3 = cross(r1,r2);
    
    % rotation R of the world with respect to the camera
    R = [r1, r2, r3];

    %because of data noise
    % If R is not a true rotation matrix, then 
    % svd can be used to approximate it and produce an orthogonal matrix. 
    [U, ~, V] = svd(R);
    R = U * V';
    
    % Now I find the translation vector. 
    % This vector is the position of the plane wrt
    % the reference frame of the camera.
    T = (K \ (lambda * h3));
    
    cameraRotation = R.';
    cameraPosition = -R.' * T;%We want T to be in the plane reference frame,
    % where R.' is the rotation of the camera with respect 
    % to the plane, since T is expressed in the camera 
    % reference frame. 
    
    display(cameraPosition)
    display(cameraRotation)

end