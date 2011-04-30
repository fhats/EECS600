function [FileNum,MaxLength]=FileNormalization(CurrentPath)
% 
%
%  FILENORMALIZATION normalize all the .wav files to the maxmium data length    
%   of files in that directory.                                                 
%   [FILENUM,MAXLENGTH]=FILENORMALIZATION(CURENTPATH) requred the first file in 
%   that directory with file name endingin with 1.WAV.                          
%   The file length is the length of the longest files, with                    
%   fix((MAXLENGTH-OriginalLength)/2) at the beginning of the file and          
%   MAXLENGTH-fix((MAXLENGTH-OriginalLength)/2) at the end.                     
%                                                                              
%   FILENUM  :Number of .wav files normalized.                                  
%   MAXLENGTH:Length of the normailized files(Maxmium length of all the files   
%            in that directory).                                               
%                                                                              
%   Zhenhai Wang, October 2002.
%   zhenhai@ieee.org  
%
% 

if (nargin==0),
    CurrentPath='';
end;
[newfile,newpath] = uigetfile([CurrentPath,'*.wav']);
FName=strtok(newfile,'1');
FileNum=0;
while(newfile~=0)
    while (exist([newpath,FName,int2str(FileNum+1),'.wav'])==2)
        FileNum=FileNum+1;
        [Siz,Fs,bits] = wavread([newpath,FName,int2str(FileNum),'.wav'],0);
        Lengths(FileNum)=Siz(1);
    end
    MaxLength=max(Lengths);
    for k=1:FileNum
        [T,Fs,bits] = wavread([newpath,FName,int2str(k),'.wav']);
        TopZeros=fix((MaxLength-length(T))/2);
        EndZeros=MaxLength-length(T)-TopZeros;
        wavwrite([zeros(TopZeros,1);T;zeros(EndZeros,1)],Fs,[newpath,FName,int2str(k),'.wav'])
    end
    return;
end