clear;clc;close all;
%---------------------------------------------------------
input_file1 = 'IG1850_f09_g16.cism.h.0002-01-01-00000.nc_yellow';
input_file2 = 'IG1850_f09_g16.cism.h.0011-01-01-00000.nc';
% ------------------
VAR = 'temp'
%---------------------------------------------------------
% varibles:
% temp(time, level, y1, x1) ;ice temperature
% usurf(time, y1, x1)       ;ice upper surface elevation
% thk(time, y1, x1)         ;ice thickness
% artm(time, y1, x1)        ;annual mean air temperature
% acab(time, y1, x1)        ;accumulation, ablation rate
% bmlt(time, y1, x1)        ;basal melt rate
% bwat(time, y1, x1)        ;basal water depth
% topg(time, y1, x1)        ;bedrock topography
% uvel(time, level, y0, x0) ;ice velocity in x direction
% uflx(time, y0, x0)        ;flux in x direction
% vvel(time, level, y0, x0) ;ice velocity in y direction
% vflx(time, y0, x0)        ;flux in y direction
% coordinates
% level(level)              ;sigma layers,positive = "down"
% x0(x0)                    ;Cartesian x-coordinate, velocity grid
% y0(y0)                    ;Cartesian x-coordinate, velocity grid
% x1(x1)                    ;Cartesian y-coordinate
% y1(y1)                    ;Cartesian y-coordinate

% read in coordinates
ncid = netcdf.open(input_file1);
varid = netcdf.inqVarID(ncid,'x1');
x1 = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'y1');
y1 = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'y0');
y0 = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'x0');
x0 = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'level');
level = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'time');
TIME = netcdf.getVar(ncid,varid);


%----------------------------------------------------
% convert x,y to lon,lat
% later...
% temperorily use this
RATIO = abs(y0(1)-y0(end))/abs(x0(1)-x0(end));
%-----------------------------------------------------

if strcmp('uvel',VAR) || strcmp('vvel',VAR) || strcmp('temp',VAR)
    nz = 11;
else
    nz = 1;
end

% read in variables and close files
varid = netcdf.inqVarID(ncid,VAR);
TEMP = netcdf.getVar(ncid,varid);
netcdf.close(ncid);
ncid = netcdf.open(input_file2);
varid = netcdf.inqVarID(ncid,VAR);
TEMP2 = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,'time');
TIME2 = netcdf.getVar(ncid,varid);
netcdf.close(ncid);
TEMP(abs(TEMP(:))<1e-6) = NaN;
TEMP2(abs(TEMP2(:))<1e-6) = NaN;
addpath('m_map')
%-----------------------------------------------------
%draw figures

scrsz = get(0,'ScreenSize');

for z = 1:nz 
    
    figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)*9/10])
    
    if 0 % draw original field
        TITLE = [ VAR ' for LEVEL=' num2str(level(z)) ';TIME=' num2str(TIME) ];
        NAME_SAVE = [VAR '_for_LEVEL' num2str(level(z)) '_TIME' num2str(TIME) '.png'];
        % -----------------------------------------------
        % color settings
        ll =  linspecer;
        MAX = max(TEMP(:));
        MIN = min(TEMP(:));
        inv = (MAX-MIN)/10;
        k=0;
        while inv < 1
            inv = inv * 10;
            k=k+1;
        end
        inv = floor(inv)/(10^k);
        ca_max = ceil(MAX/inv)*inv;
        ca_min = floor(MIN/inv)*inv;
        DL = ca_min:inv:ca_max;
        INV = floor(size(ll,1)/length(DL));
        lineStyles = (ll(1:INV:end,:));
        lineStyles =  lineStyles(1:length(DL)-1,:);
        %----------------------------------------
        colormap(lineStyles)
        contourf(squeeze(TEMP(:,:,z))',DL)
        hcb=colorbar;
        set(hcb,'YTick',[DL])
        set(gcf,'color','w')
        caxis([ca_min ca_max])
        set(gca,'fontsize',30)
        daspect([1 RATIO 1])
        title(TITLE)
        set(gcf,'paperpositionmode','auto')
        pause
        %   print(NAME_SAVE,'-dpng')
        close all
    end % end of draw original field
    
    if 1 % draw difference
        TITLE = [VAR ' DIFF for LEVEL=' num2str(level(z)) ';TIME2=' num2str(TIME2) '-TIME1=' num2str(TIME) ];
        NAME_SAVE = [VAR '_for_LEVEL' num2str(level(z)) '_TIME2' num2str(TIME2) '_TIME1' num2str(TIME)  '.png'];
        % ---------------------------------------------------------------
        % color settings
        ll =  linspecer;
        MAX = max(TEMP2(:)-TEMP(:));
        MIN = min(TEMP2(:)-TEMP(:));
        inv = (MAX-MIN)/10;
        k=0;
        while inv < 1
            inv = inv * 10;
            k=k+1;
        end
        inv = floor(inv)/(10^k);
        ca_max = ceil(MAX/inv)*inv;
        ca_min = floor(MIN/inv)*inv;
        DL = ca_min:inv:ca_max;
        INV = floor(size(ll,1)/length(DL));
        lineStyles = (ll(1:INV:end,:));
        lineStyles =  lineStyles(1:length(DL)-1,:);
        %-----------------------------------------------------------------
        colormap(lineStyles)
        contourf(squeeze(TEMP2(:,:,z)-TEMP(:,:,z))',DL)
        hold on
        contour(squeeze(TEMP2(:,:,z)-TEMP(:,:,z))',[0 0],'r','linewidth',3)
        hcb=colorbar;
        set(hcb,'YTick',[DL])
        set(gcf,'color','w')
        caxis([ca_min ca_max])
        set(gca,'fontsize',30)
        daspect([1 RATIO 1])
        title(TITLE)
        set(gcf,'paperpositionmode','auto')
        %print(NAME_SAVE,'-dpng')
        pause
        close all
    end % end of draw difference
    
end


