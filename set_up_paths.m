function set_up_paths()    
    filePath = searchFolderForFile(pwd, 'PathsAdder.m');
    addpath(filePath);
    PathsAdder.addPaths();    
end

function filePath = searchFolderForFile(folder, filename)
    fileList = dir(fullfile(folder, '**/*.*'));
    fileList = fileList(~[fileList.isdir]);
    file = fileList(strcmpi({fileList.name}, filename));
    filePath = file.folder;    
end