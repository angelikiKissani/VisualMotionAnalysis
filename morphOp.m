%% Detect Objects
function [mask] = morphOp(frame,finger,i)

    % I set mask as the forefround that I detected in the Foreground
    % Detection function.
    mask = finger.detector.step(frame);
    %I also select a random frame for rectification and then calibration
     if i==0
        %H=hor_rectification(frame);
        %K=calibration(frame);
        %vert_rectification(frame,K);
        %localization()
     end

    % I will now use some morphological 
    %operations to eliminate noise and fill in gaps.
    %strel function is a stucturing element. I selected a disk-shaped
    %stucturing element with radius 5 for the morphological 
    % opening and with radius  60 for the closing
        
    mask = imopen(mask, strel("disk",4));
    mask = imclose(mask, strel("disk",22));
    mask = imfill(mask,'holes');
   
end