function [PVpredict,PVClearsky,AC_power,error]=PVpredict(Location,Pvsystem,t,UTC,tree,WeatherforecastOrg,DiffMethod,Method)
clear AC_power;
%% time inputs
Starttime=t(1);
Endtime=t(end);
timestep=60;



%% Data aquiration (Clear Sky + AC Power)
PVClearsky=clearskygen(Pvsystem,Location,t,UTC);

AC_power=emoncms(1,320,Starttime,Endtime,timestep);
AC_power=AC_power(:,2)*1000; %%% kw to watts
NanIndex=isnan(AC_power);
pause(0.5)

%%Acquireforecastdata



Weather_data=weatherset(WeatherforecastOrg,Starttime,Endtime,2,timestep);

for i=1:length(PVClearsky)
if Weather_data(i,1)> 25 && Weather_data(i,3)==1
PVClearsky(i)=0.88*PVClearsky(i); %if Forecast-Temperature higher than 25 degree
                                  %efficiency of PV-System goes down

end
end

%% Prediction

Weather_data(NanIndex,:)=nan;

Diff=predict(tree,Weather_data);    %Use generated Tree for Prediction
%% Post-Processing (Plotting and Error calculation)
if isequal(DiffMethod, 'AbsoluteValues')
    %%%%Normal Version%%%%
    PVpredict=PVClearsky-abs(Diff);     %From Predicted Diff calculated PV Prediction
else
    %%%%Relative Change%%%%
    PVpredict=PVClearsky-abs(Diff.*PVClearsky);
end

PVpredict(find(PVpredict<=0))=0;    %set all values smaller zero to zero

PVpredict(find(PVClearsky==0))=0;   %when PVClearsky = 0 Predict should be zero as well (night..)
for i=1:length(PVClearsky)
    if PVpredict(i)>PVClearsky(i)
        PVpredict(i)=PVClearsky(i);
    end
end
error=errorcalc(PVpredict,AC_power);


end
