function generatedFiles = plc_postcg_callback_HIMA1(fileNames)
    
    % 讀取原始檔案
    fileName = fileNames{1};
    try
        str = fileread(fileName);
    catch
        error('無法讀取檔案: %s', fileName);
    end

    % 處理字串替換
    str = regexprep(str, ' DINT_TO_UDINT', ' A_TO_UDINT');
    str = regexprep(str, '(DINT_TO_UDINT', '(A_TO_UDINT');
    str = regexprep(str, ' UINT_TO_UDINT', ' A_TO_UDINT');
    str = regexprep(str, '(UINT_TO_UDINT', '(A_TO_UDINT');
    str = regexprep(str, ' INT_TO_DINT', ' A_TO_DINT');
    str = regexprep(str, '(INT_TO_DINT', '(A_TO_DINT');
    str = regexprep(str, ' INT_TO_UDINT', ' A_TO_UDINT');
    str = regexprep(str, '(INT_TO_UDINT', '(A_TO_UDINT');
    str = regexprep(str, ' UDINT_TO_DINT', ' A_TO_DINT');
    str = regexprep(str, '(UDINT_TO_DINT', '(A_TO_DINT');
    str = regexprep(str, ' UINT_TO_DINT', ' A_TO_DINT');
    str = regexprep(str, '(UINT_TO_DINT', '(A_TO_DINT');

    % 將處理後的內容寫回原始檔案
    try
        fid = fopen(fileName, 'w');
        fprintf(fid, '%s', str);
        fclose(fid);
    catch
        error('無法寫回檔案: %s', fileName);
    end
    generatedFiles = {fileName};

    % 獲取原始檔案的目錄和名稱
    [filePath, fileBaseName, ~] = fileparts(fileName);
    outputFolder = fullfile(filePath, 'ST_Code');

    % 確保輸出資料夾存在
    stDirOpen(outputFolder);

    % 打開檔案進行逐行處理
    fid = fopen(fileName, 'r');
    if fid == -1
        error('無法打開檔案: %s', fileName);
    end

    % 初始化變數
    part1FID = -1; % part1 標頭註解
    part2FID = -1; % part2 FUNCTION_BLOCK Name
    part3FID = -1; % part3 FUNCTION_BLOCK 定義區
    part4FID = -1; % part4 FUNCTION_BLOCK 內部
    part5FID = -1; % part5 END_FUNCTION_BLOCK
    part6FID = -1; % part6 TYPE 區塊
    part7FID = -1; % part7 VAR_GLOBAL 區塊
    
    isWritingPart1 = false;
    isWritingPart2 = false;
    isWritingPart3 = false;
    isWritingPart4 = false;
    isWritingPart5 = false;
    isWritingPart6 = false;
    isWritingPart7 = false;

    cutPart = 1;
    cutCount = 0;
    funcCount = 1;
    functionFolder = outputFolder; % 預設值

    % 逐行處理檔案內容
    while ~feof(fid)
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end

        % part1 標頭註解
        if cutPart == 1
            if ~isWritingPart1
                part1File = fullfile(functionFolder, sprintf('%s_Header_Comment.st', fileBaseName));
                cutCount = cutCount + 1;
                part1FID = stFileOpen(part1FID, part1File);
                isWritingPart1 = true;
                generatedFiles{end+1} = part1File;
            end

            if isWritingPart1
                if contains(line, '*)')
                    fprintf(part1FID, '%s\n', line);
                    isWritingPart1 = false;
                    cutPart = 2;
                else
                    fprintf(part1FID, '%s\n', line);
                end
            end
        end
        
        % part2 FUNCTION_BLOCK Name
        if cutPart == 2
            if ~isWritingPart2 && contains(line, 'FUNCTION_BLOCK')
                % 提取 FUNCTION_BLOCK 名稱
                parts = split(strtrim(line));
                if numel(parts) > 1
                    folderName = parts{2}; 
                else
                    folderName = sprintf('UnknownFB_%d', funcCount); % 若無法解析，給予預設名稱
                end
                
                % 創建 FUNCTION_BLOCK 專屬資料夾
                functionFolder = stCheckFuncNameCount(folderName, outputFolder, funcCount);
                funcCount = funcCount + 1;
                
                part2File = fullfile(functionFolder, sprintf('%s_P1_BlockFunctionName.st', folderName));
                part2FID = stFileOpen(part2FID, part2File);
                isWritingPart2 = true;
                generatedFiles{end+1} = part2File;
            elseif contains(line, 'TYPE')
                cutPart = 6;
            elseif contains(line, 'VAR_GLOBAL')
                cutPart = 7;
            end
        
            if isWritingPart2
                if contains(line, 'FUNCTION_BLOCK')
                    fprintf(part2FID, '%s\n', line);
                    
                else
                    isWritingPart2 = false;
                    cutPart = 3;
                end
            end
        end 

        % part3 FUNCTION_BLOCK 定義區
        if cutPart == 3
            if ~isWritingPart3
                part3File = fullfile(functionFolder, sprintf('%s_P2_BlockFunctionVar.st', folderName));
                cutCount = cutCount + 1;
                part3FID = stFileOpen(part3FID, part3File);
                isWritingPart3 = true;
                generatedFiles{end+1} = part3File;
            end

            if contains(line, 'HIMA_PlcCoderTest body')
                fprintf(part3FID, '%s\n', line);
                isWritingPart3 = false;
                cutPart = 4;
            else
                fprintf(part3FID, '%s\n', line);
            end
        end

        % part4 FUNCTION_BLOCK 內部
        if cutPart == 4
            if ~isWritingPart4
                part4File = fullfile(functionFolder, sprintf('%s_P3_BlockFunctionLogic.st', folderName));
                cutCount = cutCount + 1;
                part4FID = stFileOpen(part4FID, part4File);
                isWritingPart4 = true;
                generatedFiles{end+1} = part4File;
            end

            if contains(line, 'END_FUNCTION_BLOCK')
                isWritingPart4 = false;
                cutPart = 5;
            else
                if ~contains(line, 'HIMA_PlcCoderTest body')
                    fprintf(part4FID, '%s\n', line);
                end
            end
        end

        % part5 END_FUNCTION_BLOCK
        if cutPart == 5
            if ~isWritingPart5
                part5File = fullfile(functionFolder, sprintf('%s_P4_BlockFunctionEnd.st', folderName));
                cutCount = cutCount + 1;
                part5FID = stFileOpen(part5FID, part5File);
                isWritingPart5 = true;
                generatedFiles{end+1} = part5File;
            end

            if isWritingPart5
                fprintf(part5FID, '%s\n', line);
                isWritingPart5 = false;
                cutPart = 2;
            end
        end



        % part6 TYPE 區塊
        if cutPart == 6
            if ~isWritingPart6
                part6File = fullfile(outputFolder, sprintf('%s_TypeDef.st', fileBaseName));
                cutCount = cutCount + 1;
                part6FID = stFileOpen(part6FID, part6File);
                isWritingPart6 = true;
                generatedFiles{end+1} = part6File;
            end

            if isWritingPart6
                if contains(line, 'VAR_GLOBAL')
                    isWritingPart6 = false;
                    cutPart = 6;
                else
                    fprintf(part6FID, '%s\n', line);
                end
            end
        end

        % part7 VAR_GLOBAL 區塊
        if cutPart == 7
            if ~isWritingPart7
                part7File = fullfile(outputFolder, sprintf('%s_GlobalDef.st', fileBaseName));
                cutCount = cutCount + 1;
                part7FID = stFileOpen(part7FID, part7File);
                isWritingPart7 = true;
                generatedFiles{end+1} = part7File;
            end

            if isWritingPart7
                fprintf(part7FID, '%s\n', line);
            end
        end
    end % while end

    % 關閉所有檔案
    fclose(fid);
    if part1FID > 0, fclose(part1FID); end
    if part2FID > 0, fclose(part2FID); end
    if part3FID > 0, fclose(part3FID); end
    if part4FID > 0, fclose(part4FID); end
    if part5FID > 0, fclose(part5FID); end
    if part6FID > 0, fclose(part6FID); end
    if part7FID > 0, fclose(part7FID); end

    fprintf('檔案拆分完成！\n');
end

function newFd = stFileOpen(fd, fname)
    if fd > 0
        fclose(fd);
    end
    newFd = fopen(fname, 'w');
    if newFd == -1
        error('無法開啟檔案: %s', fname);
    end
end

function stDirOpen(outputFolder)
    % 確保輸出資料夾存在
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    else
        rmdir(outputFolder, 's');
        mkdir(outputFolder);
    end
end

function funcFolder = stCheckFuncNameCount(folderName, outputFolder, funcCnt)

    funcFolder = fullfile(outputFolder, sprintf('%03d_%s', funcCnt, folderName));

        if ~exist(funcFolder, 'dir')
            mkdir(funcFolder);
        else
            funcFolder = outputFolder; % 預設值，避免未定義
        end
end