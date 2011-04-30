function [Fs,Siz,MaxLength]=WaveSeg(StartFrame,Startfile,CurrentPath)
% 
%
%  FILESEG Segment a large .wav file to seperated files.
%   [FS,SIZ,MAXLENGTH]=FILESEG(STARTFRAME,STARTFILE,CURENTPATH) seperates the .WAV file
%   in the CURENTPATH into segmented files. 
%   Through running File WaveSeg.m, the spectrogram of the .wav file is shown in as many
%   as 5 subplots a figure and in as many figures(If the file is long enough), 24 second
%   each. Every twice the clicks of the LEFT MOUSE BUTTON will produce one .wav file 
%   containing the data between the two limiters with direction marks indicating the 
%   begaining and end of the file. When finishing the segmentation of one subplot, click
%   the RIGHT MOUSE BUTTON once to preceed to the next subplot. The same is true when all
%   5 subplots are done in one FIGURE.   Only the first file's path and name is required,
%   the other files will follow suit with the file names in ascending order at the same
%   path. And the file names will be labeled on the plot next to the beginning limiter with
%   file extensions omitted for the neatness of the plot. After saving all the segmented
%   files are saved, the running of function FileNormalization.m will normalize the file
%   to the same length so that the data can be used as training or testing data for
%   classification of human speech and marine mammal calls. If anything goes wrong and you
%   have to restart the process, you don't need to begin right from the very start, find
%   the frame or figure number(STARTFRAME, start from 1) and the segment(STARTFILE: start
%   from 1) you just stoped, and use them as the INPUT, you can resume the process.
%   
%   STARTFRAME:Designed for better time arrangement, segment files at once not needed
%   STARTFILE :File name to begin to save with
%   CURRENTPATH:The path wanted to operated on, which can be '' if no known
%   FS         :Data Sampling Frequency
%   SIZ        :Data size containing in the big file
%   MAXLENGTH  :The maxlength of the segmened file
%
%   Zhenhai Wang, April 2002.
%   zhenhai@ieee.org  
%
% 
if (nargin==0)
    StartFrame=0;
    Startfile=1;
elseif (nargin==1)
    Startfile=1;
end;
CurrentPath=''; 

WHALE='RIGHT WHALE';
[Filename,Path] = uigetfile([CurrentPath,'.wav']);
SpecPath=[Path,strtok(Filename,'.'),'\'];
while(Filename~=0)
    [Siz,Fs,bits] = wavread([Path,Filename],0);
    NumFrame=fix(Siz(1)/(Fs*120));
    FrameLeftover=mod(Siz(1),(Fs*120));
    NumPlot=fix(FrameLeftover/(Fs*24));
    PlotLeftover=mod(FrameLeftover,(Fs*24));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    fstart = 30;
    if WHALE=='RIGHT WHALE'
        fend = 8000;
    elseif WHALE=='HUMPBACK WHALE'
        fend = 3000;
    end
    freqbin = 240;
    fratio = power(fend/fstart, 1/(freqbin - 1));
    flist =  fstart*fratio.^[0:freqbin-1];
    if Fs>16000
        WinLength=2048*1.5;
        NOVERLAP=2048;
    else
        WinLength=512;
        NOVERLAP=256;
    end
    WINDOW = kaiser(WinLength, 8);
    Timelength=Fs*24;
    NumOfLeftClick=0;
    FrameBreakLabel=0;
    SpecLength=fix(((Fs*24)-NOVERLAP)/(WinLength-NOVERLAP))-1;
    LastPlot=0;
    LastFigure=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    for w=StartFrame:NumFrame
        if (w==NumFrame)
            [T,Fs,Bits] = wavread([Path,Filename],[Fs*120*w+1 Siz(1)]);
            K=NumPlot;
            EndLabel=1;
        else
            [T,Fs,Bits] = wavread([Path,Filename],[Fs*120*w+1 Fs*120*(w+1)]);
            K=4;
            EndLabel=0;
        end
        if size(T,2)~=1   %Find the whalesound channel
            T=T(:,2);
        end
        BUTTON=1;
        Latestfigure=figure(w+1);
        for k=0:K
            SubNum=mod(k, 5) + 1;
            subplot(5, 1, SubNum);
            
            if (EndLabel==1&k==K)
                sgram=specgram(T(k*Timelength+1:FrameLeftover),flist,Fs,WINDOW,NOVERLAP);
                Tempsgram=zeros(freqbin,SpecLength);
                Tempsgram(1:size(sgram,1),1:size(sgram,2))=sgram;
                sgram=Tempsgram;
            else
                sgram=specgram(T(k*Timelength+1:(k+1)*Timelength),flist,Fs,WINDOW,NOVERLAP);
            end
            sgram = abs(sgram);
            sgram = sgram /max(max(sgram));
            imagesc(imadjust(sgram, [0.02, 0.2], [], 0.3));
            H=gca;
            axis xy;
            Spacing=size(sgram,2)/8;
            SPX=fix(Spacing*[1:8]);
            if (EndLabel==1&k==K)
                V= axis;
                axis([V(1) SpecLength V(3) V(4)]); 
            end
            [token,rem] = strtok(Filename,'_');
            labelname=strcat(token,'\',rem);
            if (mod(k, 5) == 0)
                title(['Frame # ',int2str(w+1+(k)*0.4)]);
%                 eval(['title ', [labelname,'------FS-',int2str(Fs),'------Kaiser(',int2str(WinLength),',8)','------Overlap-',int2str(NOVERLAP),'------Frame-',int2str(w+(k)*0.4) ]]);
            end;
            set(gca,'FontSize',  6);
            set(gca,'Xcolor',[1,0,0],'Ycolor',[1,0,0]);
            set(gca,'XTick',SPX);
            set(gca,'XTickLabel',  (3:3:24)+(k*24)+(w*120) );
            SPY=freqbin/4*[1:4];
            set(gca,'YTick',SPY);
            set(gca,'YTickLabel',fix(flist(SPY)));
            colormap(jet);
            %[Sig,fs,bits] = wavread('Utopia Asterisk.WAV');
            %sound(Sig,fs,bits);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            while BUTTON==1
                [TemS,TemE,BUTTON] = ginput(1);
                if BUTTON==1
                    NumOfLeftClick=NumOfLeftClick+1;
                    Start_End(NumOfLeftClick)=TemS;
                    if (mod(NumOfLeftClick,2)~=0)
                        Mark='>';
                    else
                        Mark='<';
                    end
                    line([TemS TemS],[0 3000],'color',[1 1 1],'LineWidth',0.75,'Marker',Mark,'MarkerFaceColor',[1 1 0],'MarkerSize',4);
                    drawnow;
                    if (mod(NumOfLeftClick,2)==0)%"Writefile"
                        if (FrameBreakLabel==0)
                            FStartPt=floor((k1*size(sgram,2)+Start_End(NumOfLeftClick-1))*(Fs*24)/size(sgram,2));
                            FEndPt=ceil((k*size(sgram,2)+Start_End(NumOfLeftClick))*(Fs*24)/size(sgram,2));
                            DataToWrite=T(FStartPt:FEndPt);
                        elseif (FrameBreakLabel==1)
                            FEndPt=ceil((Start_End(NumOfLeftClick))*(Fs*24)/size(sgram,2));
                            DataToWrite=[TempT;T(1:FEndPt)];
                            FrameBreakLabel=0;
                        end
                        
%MANNUALLY SELECT THE PATH TO SAVE                        
                        if (NumOfLeftClick==2)
                            [newfile,newpath] = uiputfile([SpecPath,'Seg',int2str(Startfile),'.wav']);
                            FName=strtok(newfile,int2str(Startfile));
                        end
                        newfile=[FName,int2str(Startfile+NumOfLeftClick/2-1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%AUTOMATICALLY SELECT THE PATH TO SAVE
%                         newpath=SpecPath;
%                         FName='Seg';
%                         newfile=[FName,int2str(Startfile+NumOfLeftClick/2-1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        wavwrite(DataToWrite,Fs,[newpath,newfile,'.wav']);
                        Lengths(fix(NumOfLeftClick/2))=length(DataToWrite);
                        if (LastPlot~=0)
                            if (LastFigure~=0)
                                set(0,'CurrentFigure',LastFigure);
                            end
                            set(gcf,'CurrentAxes',LastPlot);
                            text(Start_End(NumOfLeftClick-1)+3,220,newfile,'color',[1 1 1],'FontSize',8);
                            set(0,'CurrentFigure',Latestfigure);
                            set(gcf,'CurrentAxes',H);
                            LastPlot=0;
                            LastFigure=0;
                        else
                            text(Start_End(NumOfLeftClick-1)+3,220,newfile,'color',[1 1 1],'FontSize',8);
                        end
                    end
                    k1=k;
                end
            end
            k1=k;
            BUTTON=1;
            set(H,'Xcolor',[0,0,0],'Ycolor',[0,0,0]);
            
            if (mod(NumOfLeftClick,2)~=0)
                LastPlot=gca;
            else
                LastPlot=0;
            end 
        end
        if (mod(NumOfLeftClick,2)~=0&k==4)
            FStartPt=floor((k1*size(sgram,2)+Start_End(NumOfLeftClick))*(Fs*24)/size(sgram,2));
            TempT=T(FStartPt:Timelength*5);
            FrameBreakLabel=1;
            LastFigure=gcf;
        else
            LastFigure=0;
            TempT=[];
        end   
        if (w==StartFrame)
%MANNUALLY SELECT THE PATH TO SAVE                        
%             [FrameFile,FramePath] = uiputfile([SpecPath,'Frame',int2str(StartFrame),'.png']);
%             FrameName=strtok(FrameFile,int2str(StartFrame));
%AUTOMATICALLY SELECT THE PATH TO SAVE
              FrameName='Frame';
              FramePath=SpecPath;
        end
        [FrameFile,FramePath] = uiputfile([SpecPath,'Frame',int2str(w+1),'.png']);
        saveas(Latestfigure,[FramePath,FrameName,int2str(w+1),'.png']);
    end
    MaxLength=max(Lengths);
    return;
end
