function headerCommentText = plc_header_hook(filePath, blockH, headerCommentText)


headerCommentText = [headerCommentText(1:end-7) ...
    sprintf([' * Plugin Header Copy              : Yes \n']) ...
    headerCommentText(end-6:end)];

end