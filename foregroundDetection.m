%% Foreground Detection of fingers
function finger = foregroundDetection()

    %This is the Video Reader
    finger.reader = VideoReader('organ/organ.mp4');

    %I create two video  players. 
    %One will display the original video and the other will display the
    %video with the mask  that will cover the background.
    
    finger.origPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    finger.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    finger.maskAlone= vision.VideoPlayer('Position', [740, 400, 700, 400]);

    %Now I'm using the foreground Detector to find the moving objects
    %that belong to the foreground and separate them from the background
    %This function generates a mask that is binary, 0 for the
    %background of the image and 1 for the foreground.
    
    finger.detector = vision.ForegroundDetector('NumGaussians', 2 , ...
        'NumTrainingFrames', 5 , 'MinimumBackgroundRatio', 0.7);

end
