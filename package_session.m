% [CURATIONARRAY] = PACKAGE_SESSION(VIDEODIR, DATADIR) returns a single 
% structure (CURATIONARRAY) with all relevant data for training and 
% curation. VIDEODIR is the path to a session of whisker video while
% DATADIR is the path to all tracking data. It is designed to be used with 
% the Janelia Farm whisker Tracker. VIDEODIR and DATADIR can be the same
% if video and data files are stored in the same directory. 


% Created: 2018-11-12 by J. Sy
% Last Updated: 2018-11-12 by J. Sy

function [curationArray] = package_session(videoDir, dataDir)

% Find videos in directory, accept mp4 or avi
mp4List = dir([videoDir '/*.mp4']);
aviList = dir([videoDir '/*.avi']);
if ~isempty(mp4List) || ~isempty(aviList) 
    vidList = vertcat(mp4List, aviList);
else
    error('No avi or mp4 video files found in video directory')
end

% Make WL files
Whisker.makeAllDirectory_WhiskerTrial_2pad(videoDir, 0)

% Loop through video list for packaging 
curationArray = cell(1,length(vidList));
for i = 1:length(vidList)
    wtFileName = [dataDir filesep vidList(i).name(1:end-4) '.WT'];
    fullVideoName = [videoDir filesep vidList(i).name];
    distanceInfo = find_distance_info(whiskerFileName, fullVideoName);
    curationArray{i}.distanceToPole = distanceInfo;
    curationArray{i}.video = fullVideoName;
end

% FIND_DISTANCE_INFO reads a .whiskers file, calculates bar position, and
% finds distance to pole information
% function [dist] = find_distance_info(whiskersFile, video)
% [r, stuff] = load_whiskers_file(whiskersFile);
% 
% end