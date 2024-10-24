
clear;
close all;
% Create System objects used for reading video, detecting moving objects,
% and displaying the results.
i=10;
finger = foregroundDetection();
%I create a new avi file called result.avi where I'm going to
%write a new video file with the results of the analysis.
v = VideoWriter('organ/organ_result.avi');
v2=VideoWriter('organ/mask_organ.avi');
%Open the file to write
open(v);
open(v2);
% Detect moving objects, and track them across video frames.
while hasFrame(finger.reader)

    %for each frame we are doing the following process
    
    frame = readFrame(finger.reader);
    mask = morphOp(frame,finger,i);
    
    %display the results and return the new frame with the mask
    [fmask,mask] = displayResults(finger,frame,mask);
    
    %I extract the fmask to write the new frame to the new file
    %the new frame has the mask over the original frame
    writeVideo(v,fmask);
    writeVideo(v2,im2uint8(~mask));
    i=i-1;
       
end
close(v);
close(v2);

