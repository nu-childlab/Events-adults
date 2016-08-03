function [] = jumpExpv6()
Screen('Preference', 'SkipSyncTests', 0);
close all;
sca
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
rng('shuffle');
KbName('UnifyKeyNames')

subj=input('Subject Number: ', 's');
subj = subjcheck(subj);

%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;
grassGreen = [0 .8 0];
skyBlue = [.4 .7 1];


textsize = 32;
textspace = 1;
crossTime = .5;



readp = csvread('eventsparameters.csv',1,0);
questions = {'MORE TIMES'...
    'HIGHER'...
    'LONGER'...
    'MORE'};
questions = questions(randperm(numel(questions)));
%questions(4) = {'Did the star jump more than the heart?'};

block1 = readp(randperm(size(readp,1)),:);
block2 = readp(randperm(size(readp,1)),:);
block3 = readp(randperm(size(readp,1)),:);
block4 = readp(randperm(size(readp,1)),:);

blocks = {block1 block2 block3 block4};

interjump = .1;




screens = Screen('Screens');
screenNumber = max(screens);
%Sets the display screen to the most external screen.
%PsychDebugWindowConfiguration(-1, .5) %opacity
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%opens a window in the most external screen and colors it)
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%Anti-aliasing or something? It's from a tutorial
ifi = Screen('GetFlipInterval', window);
%Drawing intervals; used to change the screen to animate the image
%screen refresh rate = approx. .0167
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%The size of the screen window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
%The center of the screen window
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(window));

%%%IMAGE 1

theImageLocation = 'red star.png';
%theImage = imread(theImageLocation);
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);

% Get the size of the image
[s1, s2, ~] = size(imagename);

% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
starTexture = Screen('MakeTexture', window, imagename);

%%%IMAGE 2

theImageLocation = 'blue heart.png';
%theImage = imread(theImageLocation);
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);

% Get the size of the image
[s1, s2, ~] = size(imagename);

% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
heartTexture = Screen('MakeTexture', window, imagename);

%%%GRASS

baseRect = [0 0 screenXpixels screenYpixels/4];
centeredRect = CenterRectOnPointd(baseRect, screenXpixels/2, screenYpixels - screenYpixels/8);
rectColor = grassGreen;
%This rectangle is the grass
time = 0;






initprint = 0;
initprintsubj = 0;
if ~(exist('~/Desktop/Data/EVENTS/EVENTSdata.csv', 'file') == 2)
    initprint = 1;
end
if ~(exist(['~/Desktop/Data/EVENTS/' subj '.csv'], 'file') == 2)
    initprintsubj = 1;
end
dataFile = fopen('~/Desktop/Data/EVENTS/EVENTSdata.csv', 'a');
subjFile = fopen(['~/Desktop/Data/EVENTS/' subj '.csv'],'a');
if initprint
    fprintf(dataFile, ['subj, time, A Number, A Height, A Jump Duration, A Total Duration,'...
        'B Number, B Height, B Jump Duration, B Total Duration, response, sentence, condition \n']);
end
if initprintsubj
    fprintf(subjFile, ['subj, time, A Number, A Height, A Jump Duration, A Total Duration,'...
        'B Number, B Height, B Jump Duration, B Total Duration, response, sentence, condition \n']);
end
lineFormat = '%s, %6.2f, %d, %d, %6.2f, %6.2f, %d, %d, %6.2f, %6.2f, %s, %s, %s \n';





ground = screenYpixels - screenYpixels/4;
starpos = screenXpixels/3;
heartpos = 2 * screenXpixels/3;

ListenChar(2);
instructions(window, screenXpixels, screenYpixels, textsize, textspace);

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

for b = 1:numel(blocks)
    switchScreen(window, textsize, textspace, questions{b}, screenYpixels)
    blok = blocks{b};
    for t = 1:numel(blok(:,1))
        vars = blok(t,:);

        starJumps = vars(1);
        starHeight = vars(2);
        starTime = vars(3)/starJumps;
        heartJumps = vars(4);
        heartHeight = vars(5);
        heartTime = vars(6)/heartJumps;

        starframes = round(starTime / ifi) + 1;
        starcount=linspace(0,pi,starframes);
        heartframes = round(heartTime / ifi) + 1;
        heartcount=linspace(0,pi,heartframes);

        sentence = ['Did the star jump ' questions{b} ' than the heart?'];
        
        fixCross(xCenter, yCenter, window, crossTime);

        %%%STAR ANIMATION
        Screen('FillRect', window, skyBlue);
        for j = 1:starJumps;
            t1 = GetSecs();
            m = 1;
            while m <= numel(starcount)
                x = starcount(m);
                ypos = starHeight * sin(x);
                starYpos = ground - ypos;
                starXpos = starpos;
                heartYpos = ground;
                heartXpos = heartpos;


                stardestRect = [starXpos - 128/2, ... %left
                        starYpos - 128/2, ... %top
                        starXpos + 128/2, ... %right
                        starYpos + 128/2]; %bottom

                heartdestRect = [heartXpos - 128/2, ... %left
                        heartYpos - 128/2, ... %top
                        heartXpos + 128/2, ... %right
                        heartYpos + 128/2]; %bottom
                Screen('FillRect', window, rectColor, centeredRect);
                Screen('DrawTexture', window, starTexture, [], stardestRect, 0);
                Screen('DrawTexture', window, heartTexture, [], heartdestRect, 0);
                vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

                % Increment the time
                time = time + ifi;
                m =  m + 1;
            end
            t2 = GetSecs();
            time = t2 - t1;

            WaitSecs(interjump);
        end


        %%%HEART ANIMATION

        for j = 1:heartJumps;
            t1 = GetSecs();
            m = 1;
            while m <= numel(heartcount)
                x = heartcount(m);
                ypos = heartHeight * sin(x);
                starYpos = ground;
                starXpos = starpos;
                heartYpos = ground - ypos;
                heartXpos = heartpos;


                stardestRect = [starXpos - 128/2, ... %left
                        starYpos - 128/2, ... %top
                        starXpos + 128/2, ... %right
                        starYpos + 128/2]; %bottom

                heartdestRect = [heartXpos - 128/2, ... %left
                        heartYpos - 128/2, ... %top
                        heartXpos + 128/2, ... %right
                        heartYpos + 128/2]; %bottom
                Screen('FillRect', window, rectColor, centeredRect);
                Screen('DrawTexture', window, starTexture, [], stardestRect, 0);
                Screen('DrawTexture', window, heartTexture, [], heartdestRect, 0);
                vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                %vbl  = Screen('Flip', window, starttime + .005);

                % Increment the time
                time = time + ifi;
                m =  m + 1;
            end
            t2 = GetSecs();
            time = t2 - t1;

            WaitSecs(interjump);
        end

        Screen('FillRect', window, black);
        [response, responsetime] = getResponse(window, sentence, textsize, screenYpixels);

        fprintf(dataFile, lineFormat, subj, responsetime*1000, starJumps, starHeight, starTime,...
            starTime*starJumps, heartJumps, heartHeight, heartTime, heartTime*heartJumps, response, sentence, 'sequential');
        fprintf(subjFile, lineFormat, subj, responsetime*1000, starJumps, starHeight, starTime,...
            starTime*starJumps, heartJumps, heartHeight, heartTime, heartTime*heartJumps, response, sentence, 'sequential');

    end
    %%%Break
    if b ~= 4
        breakScreen(window, textsize, textspace)
    end
end
finish(window, textsize, textspace);
sca
ListenChar(1);
fclose('all');
end



function [] = breakScreen(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['That' quote 's it for that block! \n\n' ...
        ' Please press the spacebar when you are ready to continue to the next block. '], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = switchScreen(window, textsize, textspace, question, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    DrawFormattedText(window, ['In this block, you are being asked to say'...
        ' whether the following sentence accurately describes the animation: '], 'center', (screenYpixels/2)-150,...
        textcolor, 70, 0, 0, textspace);
    sent = ['\n\n The star jumped ' question ' than the heart.'];
    Screen('TextSize',window, textsize+6);
    DrawFormattedText(window, sent, 'center', 'center', textcolor, 70, 0, 0, textspace);
    
    Screen('TextSize',window,textsize);
        DrawFormattedText(window, ['Ready? Press spacebar to continue.'], 'center', (screenYpixels/2) + 150,...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function[] = fixCross(xCenter, yCenter, window, crossTime)
    fixCrossDimPix = 40;
    white = WhiteIndex(window);
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(crossTime);
end

function [] = sentDisplay(window, sentence, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    DrawFormattedText(window, sentence, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [response, time] = getResponse(window, sentence, textsize, screenYpixels)
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+6);
    quote = '''';
    DrawFormattedText(window, sentence, 'center', 'center', textcolor, 70, 0, 0, 1.5);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, ['Press ' quote 'f' quote ' for YES and ' quote 'j' quote ' for NO'],...
        'center', screenYpixels/2 + 80, textcolor, 70);
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    inLoop=true;
    yesno = [KbName('f') KbName('j')];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == yesno)
                endtime = GetSecs;
                if code == 9
                    response = 'f';
                end
                if code== 13
                    response= 'j';
                end
                inLoop=false;
            end
        end
    end
    time = endtime - starttime;
end


function [subj] = subjcheck(subj)
    if ~strncmpi(subj, 's', 1)
        %forgotten s
        subj = ['s', subj];
    end
    numstrs = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0'];
    for x = 2:numel(subj)
        if ~any(subj(x) == numstrs)
            subj = input(['Subject ID' subj ' is invalid. It should ' ...
                'consist of an "s" followed by only numbers. Please use a ' ...
                'different ID:'], 's');
            subj = subjcheck(subj);
            return
        end
    end
end

function [] = instructions(window, screenXpixels, screenYpixels, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    quote = '''';
    intro = ['Welcome to the experiment. In this experiment, you will be asked to evaluate',...
        ' sentences relative to short animations. There are 4 blocks in the experiment,',...
        ' and each block contains 30 trials. In each block, you will be asked to evaluate',...
        ' a different sentence. You will be given a short break between blocks. \n\n',...
        ' For each animation, you will indicate whether the sentence accurately describes',...
        ' that animation by pressing ' quote 'f' quote ' for YES or ' quote 'j' quote ' for NO.',...
        ' You will be reminded of these response keys throughout. '];
    
    DrawFormattedText(window, intro, 'center', screenYpixels/3, textcolor, 70, 0, 0, textspace);
    
    intro2 = ['Please indicate to the experimenter if you have any questions, '...
        'or are ready to begin the experiment. \n\n When the experimenter has '...
        'left the room, you may press spacebar to begin.'];
    
    DrawFormattedText(window, intro2, 'center', 2*screenYpixels/3, textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);

end

function [] = finish(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    closing = ['Thank you for your participation.\n\nPlease let the ' ...
        'experimenter know that you are finished.'];
    DrawFormattedText(window, closing, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('ESCAPE'));
    KbStrokeWait;
    Screen('Flip', window);
end