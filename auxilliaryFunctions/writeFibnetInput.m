function writeFibnetInput(fileName,dataNodes,dataElements,dataType,dataMaterials)


nodeInputFile = horzcat(fileName,'.xyz');
fileID = fopen(nodeInputFile,'w');
fprintf(fileID,'%12.0i %17.10E %17.10E %17.10E\n',dataNodes'); 
fclose(fileID);

elementInputFile = horzcat(fileName,'.nod');
fileID = fopen(elementInputFile,'w');
fprintf(fileID,'%12.0i %11.0i %11.0i %11.0i %11.0i %11.0i\n',dataElements'); 
fclose(fileID);

typeInputFile = horzcat(fileName,'.typ');
fileID = fopen(typeInputFile,'w');
fprintf(fileID,'%12.0i %1.0i %17.10E %17.10E %17.10E\n',dataType'); 
fclose(fileID);

matInputFile = horzcat(fileName,'.mat');
fileID = fopen(matInputFile,'w');
fprintf(fileID,'%12.0i %17.11E %17.11E\n',dataMaterials'); 
fclose(fileID);