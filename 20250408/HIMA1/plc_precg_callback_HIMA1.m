function controller = plc_precg_callback_HIMA1(controller)
%   Copyright 2012-2020 The MathWorks, Inc.
    
    % do modifications to the controller struct here, f.ex.:
    for i = 1:length(controller.components)
        controller.components(i).body = sprintf('(*****<<<<< HIMA_PlcCoderTest body >>>>>*****)\r\n%s',controller.components(i).body);
    end

end