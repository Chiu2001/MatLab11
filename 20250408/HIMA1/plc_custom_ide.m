function plc_ide_list = plc_custom_ide
%   Copyright 2012-2021 The MathWorks, Inc.
    plc_ide_list(1) = get_ide_info_myplcopen;
end

function ide_info = get_ide_info_myplcopen
    ide_info.name = 'HIMA_MITAC_1';
    ide_info.description = 'HIMA_1';
    ide_info.path = ''; % IDE path
    ide_info.format = 'generic'; % generic|xmls
    ide_info.fileExtension = 'st';
    ide_info.cfg = get_ide_cfg_HIMA1;
    ide_info.precg_callback = 'plc_precg_callback_HIMA1'; 
    ide_info.postcg_callback = 'plc_postcg_callback_HIMA1';
    ide_info.xmltree_callback = PLCCoder.PLCCGMgr.PLC_PLUGIN_CG_CALLBACK_EMPTY;
    ide_info.pluginVersion = 2.2;
    ide_info.compatibleBuildVersion = 1.6;
end

function cfg = get_ide_cfg_HIMA1
    cfg.fConvertDoubleToSingle = false;
    cfg.fConvertNamedConstantToInteger = true;
    cfg.fConvertEnumToInteger = true;
    cfg.fConvertOutputInitValueToAssignment = true;
    cfg.fSimplifyFunctionCallExpr = false;
    cfg.fHoistArrayIndexExprs = true;
    cfg.fUseQualifiedTypeConstant = true;
    cfg.fDefineFBExternalVariable = true;

    cfg.fConvertAggregateTypeFunctionToFB = true;
    cfg.fEmitVarDeclarationBeforeDescription = false;
    cfg.fRefactorInputAssignment = true;

    cfg.InlineBetweenUserFunctions = false; % 停用內聯最佳化
    cfg.OptimizeBlockIOStorage = false; % 避免刪除未使用的變數

    cfg.fInt16AsBaseInt = false;

    % cfg.fConvertUnsignedIntToSignedInt = false;
    % cfg.fConvertDoubleToSingle = false;
    % cfg.fConvertNamedConstantToInteger = true;
    % cfg.fConvertEnumToInteger = true;
    % cfg.fInt16AsBaseInt = false;
    % cfg.fConvertOutputInitValueToAssignment = true;
    % cfg.fDefineFBExternalVariable = true;
    % cfg.fConvertAggregateTypeFunctionToFB = true;
    % cfg.fUseQualifiedTypeConstant = true;
    % cfg.fConvertBooleanCast = true;
    % cfg.fErrorOnTrailingUS = true;
    % cfg.fHoistIntrinsicFcnCallNestedExpr = true;
    % cfg.fRefactorInputAssignment = true;
    % cfg.fEmitXsdSchema = 'none';
end