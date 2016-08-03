function [] = events3v2pauses()
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

cond=input('Initial Condition (m or q): ', 's');
cond = condcheck(cond);

%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;
grassGreen = [0 .8 0];
pink = [1 .6 .8];
skyBlue = [.4 .7 1];


textsize = 32;
textspace = 1;
crossTime = .5;


if strcmp(subj, 's999')
    readp = csvread('eventsparameterstest.csv',1,0);
else
    readp = csvread('eventsparametersv2.csv',1,0);
end

questions = {'MORE TIMES'...
    'HIGHER'...
    'LONGER'...
    'MORE'};

interjump = .1;




screens = Screen('Screens');
screenNumber = max(screens);
%Sets the display screen to the most external screen.
PsychDebugWindowConfiguration(-1, .5) %opacity
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
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);
[s1, s2, ~] = size(imagename);
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
starTexture = Screen('MakeTexture', window, imagename);

%%%IMAGE 2

theImageLocation = 'blue heart.png';
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);
[s1, s2, ~] = size(imagename);
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
heartTexture = Screen('MakeTexture', window, imagename);

%%%GRASS

baseRect = [0 0 screenXpixels/2 screenYpixels];
centeredRect = CenterRectOnPointd(baseRect, screenXpixels/4, screenYpixels/2);
rectColor = pink;
time = 0;




%%%DATA SAVING

initprint = 0;
if ~(exist('~/Desktop/Data/EVENTS/EVENTS3v2pauses/EVENTS3v2pausesdata.csv', 'file') == 2)
    initprint = 1;
end
dataFile = fopen('~/Desktop/Data/EVENTS/EVENTS3v2pauses/EVENTS3v2pausesdata.csv', 'a');
subjFile = fopen(['~/Desktop/Data/EVENTS/EVENTS3v2pauses/' subj '.csv'],'a');
if initprint
    fprintf(dataFile, ['subj,time,A Number,A Height,A Jump Duration,A Total Duration,'...
        'B Number,B Height,B Jump Duration,B Total Duration,response,sentence,condition \n']);
end
fprintf(subjFile, ['subj,response time,A Number,A Height,A Jump Duration,A Total Duration,'...
    'B Number,B Height,B Jump Duration,B Total Duration,response,sentence,condition \n']);

lineFormat = '%s,%6.2f,%d,%d,%6.2f,%6.2f,%d,%d,%6.2f,%6.2f,%s,%s,%s \n';





ground = screenYpixels - screenYpixels/4;
starxpos = screenXpixels/4;
heartxpos = 3 * screenXpixels/4;

%ListenChar(2);
instructions(window, screenXpixels, screenYpixels, textsize, textspace);
blockbreakScreen(window, textsize, textspace, screenYpixels, '1')

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;
pauseframes = repmat([ground], 1, round(interjump/ifi));

if strcmp(cond, 'm')
    condlist = {'m';'q'};
else
    condlist = {'q';'m'};
end

for c = 1:2
    condition = condlist{c};
    
    questions = questions(randperm(numel(questions)));
    
    block1 = readp(randperm(size(readp,1)),:);
    block2 = readp(randperm(size(readp,1)),:);
    block3 = readp(randperm(size(readp,1)),:);
    block4 = readp(randperm(size(readp,1)),:);
    
    blocks = {block1 block2 block3 block4};
    
    if strcmp(condition, 'q')
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
                
                posUp = linspace(ground,starHeight,round(starframes/2));
                posDown = linspace (starHeight,ground,round(starframes/2));
                starypos = [posUp posDown pauseframes];
                
                posUp = linspace(ground,heartHeight,round(heartframes/2));
                posDown = linspace (heartHeight,ground,round(heartframes/2));
                heartypos = [posUp posDown pauseframes];
                
                sentence = ['Did the star move ' questions{b} ' than the heart?'];
                
                fixCross(xCenter, yCenter, window, crossTime);
                
                %%%STAR ANIMATION
                Screen('FillRect', window, skyBlue);
                for j = 1:starJumps;
                    t1 = GetSecs();
                    m = 1;
                    while m <= numel(starypos)
                        %x = starcount(m);
                        %ypos = starHeight * sin(x);
                        starYpos = starypos(m);
                        
                        
                        starXpos = starxpos;
                        heartYpos = ground;
                        heartXpos = heartxpos;
                        
                        
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
                    
                    
                    %WaitSecs(interjump);
                end
                
                
                %%%HEART ANIMATION
                
                for j = 1:heartJumps;
                    t1 = GetSecs();
                    m = 1;
                    while m <= numel(heartypos)
                        %x = heartcount(m);
                        %ypos = heartHeight * sin(x);
                        starYpos = ground;
                        starXpos = starxpos;
                        heartYpos = heartypos(m);
                        heartXpos = heartxpos;
                        
                        
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
                    
                    %WaitSecs(interjump);
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
            elseif b == 4 && c == 1
                blockbreakScreen(window, textsize, textspace, screenYpixels, '2')
            end
        end
    else
        for b = 1:numel(blocks)
            blok = blocks{b};
            switchScreen(window, textsize, textspace, questions{b}, screenYpixels)
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
                
                sentence = ['Did the star move ' questions{b} ' than the heart?'];
                
                fixCross(xCenter, yCenter, window, crossTime);
                
                %%%STAR ANIMATION
                Screen('FillRect', window, skyBlue);
                
                starposUp = linspace(ground,starHeight,round(starframes/2));
                starposDown = linspace (starHeight-1,ground-1,round(starframes/2));
                ypos = [starposUp starposDown pauseframes];
                starposList = repmat(ypos, 1, starJumps);
                
                heartposUp = linspace(ground,heartHeight,round(heartframes/2));
                heartposDown = linspace (heartHeight,ground,round(heartframes/2));
                ypos = [heartposUp heartposDown pauseframes];
                heartposList = repmat(ypos, 1, heartJumps);
                
                starXpos = starxpos;
                heartXpos = heartxpos;

                count = 1;
                t1 = GetSecs();
                while count <= numel(starposList) || count <= numel(heartposList)
                    if count > numel(starposList)
                        starYpos = ground;
                    else
                        starYpos = starposList(count);
                    end
                    if count > numel(heartposList)
                        heartYpos = ground;
                    else
                        heartYpos = heartposList(count);
                    end
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
                    count = count + 1;
                end
                
                Screen('FillRect', window, black);
                t2 = GetSecs();
                time = t2 - t1;
                [response, responsetime] = getResponse(window, sentence, textsize, screenYpixels);
                
                fprintf(dataFile, lineFormat, subj, responsetime*1000, starJumps, starHeight, starTime,...
                    starTime*starJumps, heartJumps, heartHeight, heartTime, heartTime*heartJumps, response, sentence, 'simultaneous');
                fprintf(subjFile, lineFormat, subj, responsetime*1000, starJumps, starHeight, starTime,...
                    starTime*starJumps, heartJumps, heartHeight, heartTime, heartTime*heartJumps, response, sentence, 'simultaneous');
                
            end
            %%%Break
            if b ~= 4
                breakScreen(window, textsize, textspace)
            elseif b == 4 && c == 1
                blockbreakScreen(window, textsize, textspace, screenYpixels, '2')
            end
        end
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

function [] = blockbreakScreen(window, textsize, textspace, screenYpixels, c)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+22);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['Part ' c], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar to continue.', 'center', screenYpixels/2+75,...
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
    sent = ['\n\n The star moved ' question ' than the heart.'];
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
    %response = '-1';
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
                    inLoop=false;
                end
                if code== 13
                    response= 'j';
                    inLoop=false;
                end
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
    if strcmp(subj,'s')
        subj = input(['Please enter a subject ' ...
                'ID:'], 's');
        subj = subjcheck(subj);
    end
    numstrs = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0'];
    for x = 2:numel(subj)
        if ~any(subj(x) == numstrs)
            subj = input(['Subject ID ' subj ' is invalid. It should ' ...
                'consist of an "s" followed by only numbers. Please use a ' ...
                'different ID:'], 's');
            subj = subjcheck(subj);
            return
        end
    end
    if (exist([subj '.csv'], 'file') == 2) && ~strcmp(subj, 's999')...
            && ~strcmp(subj,'s998')
        temp = input(['Subject ID ' subj ' is already in use. Press y '...
            'to continue writing to this file, or press '...
            'anything else to try a new ID: '], 's');
        if strcmp(temp,'y')
            return
        else
            subj = input(['Please enter a new subject ' ...
                'ID:'], 's');
            subj = subjcheck(subj);
        end
    end
end

function [cond] = condcheck(cond)
    while ~strcmp(cond, 'm') && ~strcmp(cond, 'q')
        cond = input('Condition must be m or q. Please enter m (simul) or q (seq):', 's');
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
        ' sentences relative to short animations. There are 2 sets of 4 blocks in the experiment,',...
        ' and each block contains 30 trials. In each block, you will be asked to evaluate',...
        ' a different sentence. You will be given a short break between blocks. \n\n',...
        ' For each animation, you will indicate whether the sentence accurately describes',...
        ' that animation by pressing ' quote 'f' quote ' for YES or ' quote 'j' quote ' for NO.',...
        ' You will be reminded of these response keys throughout. '];
    
    DrawFormattedText(window, intro, 'center', screenYpixels/3, textcolor, 70, 0, 0, textspace);
    
    intro2 = ['The experiment will proceed in two main parts. Please indicate to the experimenter if you have any questions, '...
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