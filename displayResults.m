%% Display Tracking Results
function [fmask,mask]= displayResults(finger,frame,mask)
   
    %In this section we are going to display the results
    %First I convert the frame and the mask to uint8 RGB.
    %I want the background to be shown as black and the front as white.
    
    frame = im2uint8(frame);
    mask = ~repmat(mask, [1, 1, 3]);
    
    %Now I insert the mask that was created into each frame. 
    
    fmask = insertObjectMask(frame,mask,'Color','black','Opacity',1);

    %Finally I display the results. One player with the original video%
    %and one with the mask inserted.
    
    finger.origPlayer.step(frame);
    finger.maskPlayer.step(fmask);
    finger.maskAlone.step(~mask);
    
    

    

end