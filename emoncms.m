function data = emoncms(API_opt,FeedId,Starttime,Endtime,delta)
t=Starttime:minutes(delta):Endtime;
toriginal = t;
days = round(datenum(duration(Endtime - Starttime,'Format','d')));
data=zeros(0,0);
if days < 123
    interval=delta*60;
    if API_opt==1
        API='9bf0be7d612e9d4a608f7ec519f64f87';
    else 
        API='fceb1d23bb716422095318980b5b73f8';
    end

    if delta <=10
        data=[];
        for i=1:1440:length(t)

        Starttime=(floor(86400 * (datenum(t(i)) - datenum('01-Jan-1970'))))*1000;
        if i+1439 <= length(t)
        Endtime=(floor(86400 * (datenum(t(i+1439)) - datenum('01-Jan-1970'))))*1000;
        else 
        Endtime=(floor(86400 * (datenum(t(end)) - datenum('01-Jan-1970'))))*1000;
        end

        url=['http://129.187.90.167/emoncms/feed/data.json?id=' num2str(FeedId) '&apikey=' API '&start=' num2str(Starttime) '&end=' num2str(Endtime) '&interval=' num2str(interval)];
        contents = urlread(url);
        MatContents=str2num(contents);
        ndata(:,1)=MatContents(1:2:end)/1000;  %%%%GMT Time
        ndata(:,2)=MatContents(2:2:end);
        data=[data;ndata];
        clear ndata
        pause(0.1)
        end
    else
    Starttime=(floor(86400 * (datenum(t(1)) - datenum('01-Jan-1970'))))*1000;
    Endtime=(floor(86400 * (datenum(t(end)) - datenum('01-Jan-1970'))))*1000;




    url=['http://129.187.90.167/emoncms/feed/data.json?id=' num2str(FeedId) '&apikey=' API '&start=' num2str(Starttime) '&end=' num2str(Endtime) '&interval=' num2str(interval)];
    contents = urlread(url);
    MatContents=str2num(contents);
    data(:,1)=MatContents(1:2:end)/1000;  %%%%GMT Time
    data(:,2)=MatContents(2:2:end);

    end
    data=missingData(data,delta,t);
else
    n = floor(days / 123);
    for intervalls = 1:n+1
        InterEndtime1 = datetime(addtodate(datenum(Starttime),123,'day'),'ConvertFrom','datenum');
        if intervalls == n+1
            InterEndtime1 = Endtime;
        end
        t=Starttime:minutes(delta):InterEndtime1;
        interval=delta*60;
        if API_opt==1
            API='9bf0be7d612e9d4a608f7ec519f64f87';
        else 
            API='fceb1d23bb716422095318980b5b73f8';
        end

        if delta <=10
            datapart=[];
            for i=1:1440:length(t)
            
            Starttime=(floor(86400 * (datenum(t(i)) - datenum('01-Jan-1970'))))*1000;
            if i+1439 <= length(t)
            InterEndtime=(floor(86400 * (datenum(t(i+1439)) - datenum('01-Jan-1970'))))*1000;
            else 
            InterEndtime=(floor(86400 * (datenum(InterEndtime1) - datenum('01-Jan-1970'))))*1000;
            end

            url=['http://129.187.90.167/emoncms/feed/data.json?id=' num2str(FeedId) '&apikey=' API '&start=' num2str(Starttime) '&end=' num2str(InterEndtime) '&interval=' num2str(interval)];
            contents = urlread(url);
            MatContents=str2num(contents);
            ndata(:,1)=MatContents(1:2:end)/1000;  %%%%GMT Time
            ndata(:,2)=MatContents(2:2:end);
            datapart=[datapart;ndata];
            clear ndata
            pause(0.1)
            end
        else
            Starttime=(floor(86400 * (datenum(t(1)) - datenum('01-Jan-1970'))))*1000;
            InterEndtime=(floor(86400 * (datenum(InterEndtime1) - datenum('01-Jan-1970'))))*1000;




            url=['http://129.187.90.167/emoncms/feed/data.json?id=' num2str(FeedId) '&apikey=' API '&start=' num2str(Starttime) '&end=' num2str(InterEndtime) '&interval=' num2str(interval)];
            contents = urlread(url);
            MatContents=str2num(contents);
            datapart(:,1)=MatContents(1:2:end)/1000;  %%%%GMT Time
            datapart(:,2)=MatContents(2:2:end);
            interdata = zeros(length(data) + length(datapart),2);
        end

        interdata(1:length(data),:) = data;
        interdata(length(data)+1:length(data)+length(datapart),:) = datapart;
        
        data = interdata;

        clear datapart interdata
        
        Starttime = InterEndtime1;
    end
    data=missingData(data,delta,toriginal);
end
end

