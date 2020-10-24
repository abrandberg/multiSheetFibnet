function [nodalData,realSetData,elementData,materialData] = importNetworks(targetDir,networkName)

targetPointer = [targetDir filesep networkName];


% disp('-> Importing nodal data.')
% tic
nodalData = importNodalData(horzcat(targetPointer,'.xyz'));
% toc

% disp('-> Importing type data')
% tic 
realSetData = importTypeData(horzcat(targetPointer,'.typ'));
% toc

% disp('-> Importing element data')
% tic 
elementData = importElementData(horzcat(targetPointer,'.nod'));
% toc

% disp('-> Importing element data')
% tic 
materialData = importMaterialData_v2(horzcat(targetPointer,'.mat'));
% toc