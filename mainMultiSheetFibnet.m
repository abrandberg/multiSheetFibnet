

% Meta instructions
clear; close all; clc
format compact; format long
ctrl.workingDir = cd;
addpath(fullfile(ctrl.workingDir,'auxilliaryFunctions'))

formatSpec = '%5s %20s %40s\n';
formatSpecInform = '%20s %s\n';
fprintf(formatSpec,'->','Start of','mainMultiSheetFibnet.m');
fprintf('%s \n','Warning: Material numbers will not be preserved. Only first ply .mat propagated.')
% Inputs: File and directory pointers


targetDir = {'C:\Users\augus\Documents\softwareProjects\multiSheetFibnet\tempGeneration' ,...
             'C:\Users\augus\Documents\softwareProjects\multiSheetFibnet\tempGeneration' ,...
             'C:\Users\augus\Documents\softwareProjects\multiSheetFibnet\tempGeneration' };
% Supply the target directories as a list where
% Each COLUMN is a ply, going from the bottom ply to the top ply
% Each ROW    is an output, consisting of the combined plies specified on that row.

networkName = {'file1_L8.0_W8.0_g200.0', ...
               'file1_L8.0_W8.0_g60.0', ...
               'file1_L8.0_W8.0_g200.0'};
% Supply the names of each ply. This is important mainly because the grammage may 
% not be the same in all cases.

fprintf(formatSpec,'->','Number of sheets',num2str(size(targetDir,1)));


outputDir = {'C:\Users\augus\Documents\softwareProjects\multiSheetFibnet\tempGeneration'};
outputName = {'TEST'};






offsetType = 'relative';
offsetMatrix = [150 150]*1e-6;

if strcmp(offsetType,'relative')
    offsetMatrix = cumsum(offsetMatrix);
elseif strcmp(offsetMatrix,'absolute')
    offsetMatrix = offsetMatrix;
end

fprintf(formatSpec,'->','Offset option',offsetType);
% A matrix consisting of offset values from the centroid of each ply to the centroid of
% the next one. Dimensions should be one less column than targetDir, same number of rows.

% Visualization options
histogramOptions = {'normalization','probability','edgeColor',[1 1 1]};


if sum(strcmp(histogramOptions,'probability')) > 0
    yLab = 'Relative frequency';
elseif sum(strcmp(histogramOptions,'pdf')) > 0
    yLab = 'pdf';
elseif sum(strcmp(histogramOptions,'count')) > 0
    yLab = 'Observations';
end

% Verify inputs.
% There will be a function here
fprintf(formatSpec,'->','','Input check');
assert(sum(size(networkName) == size(targetDir)) == length(size(networkName) == size(targetDir)), ...
       'Network name array size does not match directory name array.')
assert(sum(size(networkName) == (size(offsetMatrix)+[0 1])) == length(size(networkName) == size(offsetMatrix)), ...
       'Network name array size does not match offsetMatrix array.')

% Check that network names don't have file extensions



% Visualize inputs.
% There will be a function here


% Maybe wrap everything below in a nice function to seperate inputs and outputs?
% Initialize
fprintf(formatSpec,'->','','Initialization');
nodalData = cell(size(targetDir));
realData = cell(size(targetDir));
elementData = cell(size(targetDir));



% Construct

for aLoop = 1:size(targetDir,1)         % For each sheet to be generated

    fprintf(formatSpecInform,'',['Forming sheet : ' num2str(aLoop) ' Number of plies : ' num2str(size(targetDir,2))]);
    
    for bLoop = 1:size(targetDir,2)     % For each ply in the sheet on row aLoop of targetDir   
        [nodalData{aLoop,bLoop},realData{aLoop,bLoop},elementData{aLoop,bLoop},materialData] = importNetworks(targetDir{aLoop,bLoop},networkName{aLoop,bLoop});
    end
    
    for cLoop = 2:size(targetDir,2)     % Now that we have the data in memory, we can merge.
        nodeMax = max(nodalData{aLoop,cLoop-1}(:,1));
        elementMax = max(elementData{aLoop,cLoop-1}(:,1));
        realMax = max(realData{aLoop,cLoop-1}(:,1));
               
        % Update nodal arrays
        nodalData{aLoop,cLoop}(:,4) = nodalData{aLoop,cLoop}(:,4) + offsetMatrix(aLoop,cLoop-1);    % Offsets height
        nodalData{aLoop,cLoop}(:,1) = nodalData{aLoop,cLoop}(:,1) + nodeMax;
        
        % Update real arrays
        realData{aLoop,cLoop}(:,1) = realData{aLoop,cLoop}(:,1) + realMax;
        
        % Update element arrays
        elementData{aLoop,cLoop}(:,1) = elementData{aLoop,cLoop}(:,1) + elementMax;
        elementData{aLoop,cLoop}(:,2:4) = elementData{aLoop,cLoop}(:,2:4) + nodeMax;
        elementData{aLoop,cLoop}(:,5) = elementData{aLoop,cLoop}(:,5) + realMax;
        
    end
    
    nodalDataOut = nan(max(nodalData{aLoop,cLoop}(:,1)),4);
    realDataOut = nan(max(realData{aLoop,cLoop}(:,1)),5);
    elementDataOut = nan(max(elementData{aLoop,cLoop}(:,1)),6);
    
    for dLoop = 1:size(targetDir,2) % Collect everything in one array
       nodalDataOut(nodalData{aLoop,dLoop}(1,1):nodalData{aLoop,dLoop}(end,1),:) = nodalData{aLoop,dLoop}; 
       realDataOut(realData{aLoop,dLoop}(1,1):realData{aLoop,dLoop}(end,1),:) = realData{aLoop,dLoop}; 
       elementDataOut(elementData{aLoop,dLoop}(1,1):elementData{aLoop,dLoop}(end,1),:) = elementData{aLoop,dLoop}; 
    end
    
    
    % Assert output is compact and unique
    fprintf(formatSpec,'->','','Output check');
    assert(sum(diff(nodalDataOut(:,1))~=1)==0,'Nodal numbering is not compressed and/or not unique')
    assert(sum(diff(realDataOut(:,1))~=1)==0,'Real set numbering is not compressed and/or not unique')
    assert(sum(diff(elementDataOut(:,1))~=1)==0,'Element numbering is not compressed and/or not unique')
    assert(min(unique(nodalDataOut(:,1)) == unique(elementDataOut(:,2:4)))> 0,'Element array references non-existing node or unused node in node array')

    % If assertions are true, write to file
    if ~(exist(outputDir{aLoop},'dir') == 7)
        fprintf(formatSpecInform,'','Output dir missing. Creating.');
        mkdir(outputDir{aLoop})
    end
    fprintf(formatSpec,'->','','Writing output');
    writeFibnetInput([outputDir{aLoop} filesep outputName{aLoop}],nodalDataOut,elementDataOut,realDataOut,materialData);
    fprintf(formatSpec,'->','','Output complete');
end
fprintf(formatSpec,'->','End of','Forming');


fprintf(formatSpec,'->','','Visualization');
for eLoop = 1:size(targetDir,1)
    xau = linspace(min(nodalDataOut(:,4)),max(nodalDataOut(:,4)),100);
    figure;
    
    hold on
    for fLoop = 1:size(targetDir,2)
        histogram(nodalData{1,fLoop}(:,4),xau,histogramOptions{:},'DisplayName',['Ply ' num2str(fLoop)])
        hold on
    end
    histogram(nodalDataOut(:,4),xau,histogramOptions{:},'DisplayName',['Sheet ' num2str(eLoop)])
    xlabel('New $z$ [m]','interpreter','latex')
    ylabel(yLab,'interpreter','latex')
    legend('location','best','interpreter','latex')
    set(gca,'TickLabelInterpreter','latex')
end



fprintf(formatSpec,'->','End of','mainMultiSheetFibnet.m');




