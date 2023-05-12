function [dt,ids] = convertJxTime(Data,k)

minDate = posixtime(datetime(2023,1,1));

if k == "" % Logs
    ids = Data.local_time > minDate;
else % Meta
    ids = strcmp(Data.data_type,k) & Data.local_time > minDate;
end

dt = datetime(Data.local_time(ids), 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
dt.TimeZone = 'America/Detroit';