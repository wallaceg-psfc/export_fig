function export_fig(figname,varargin)
% EXPORT_FIG exports data from MATLAB .fig file to hdf5 file
%      EXPORT_FIG(figname,varargin)
%      Input:
%      - figname     string of .fig filename with extension removed (e.g.
%      'example1' for a figure named 'example1.fig')  Include path if
%      figure is not in current folder.  Optional second argument is a
%      string containing a description of the figure file, e.g. 'Figure N
%      from J. Doe, et al, 2017.'

if ischar(figname)
    if exist([figname '.fig'],'file')
        s=load([figname '.fig'],'-mat','hgS_070000');
        struct2h5(s,[figname '.h5'])
        h5writeatt([figname '.h5'],'/','WorkingDirectory',pwd)
        h5writeatt([figname '.h5'],'/','SourceFile',[figname '.fig'])
        h5writeatt([figname '.h5'],'/','CreationDate',datestr(now))
        h5writeatt([figname '.h5'],'/','UserName',getenv('USER'))
        if ~isempty(varargin)
            h5writeatt([figname '.h5'],'/','Description',varargin{1})
        end
    else
        disp(['File ' figname '.fig does not exist.  Input argument figname should not include .fig extension.'])
    end
else
    disp('Input argument figname must be a string.')
end

%---------------------------------
function struct2h5(Xname,h5name)
% Recursively search the content of a structure and dump plot data into
% netcdf file
%
% Input:
% - Xname/X     one can give as argument either the structure to display or
%               or a string (the name in the current workspace of the
%               structure to display)
%
% - h5name      filename for .h5 file
%
% Recursive search based on fn_structdisp code by Thomas Deneux

if ischar(Xname)
    X = evalin('caller',Xname);
else
    X = Xname;
    Xname = inputname(1);
end

if ~isstruct(X)
    error('argument should be a structure or the name of a structure')
end

if exist(h5name,'file')==2
    delete(h5name)
end
ind_list=[0 1 1 1 1 1];
Xname_prev='';
rec_struct2h5(Xname,X,h5name,Xname_prev,ind_list);

%---------------------------------
function [Xname_prev,ind_list]=rec_struct2h5(Xname,X,h5name,Xname_prev,ind_list)

%-- PARAMETERS (Edit this) --%
CELLMAXROWS = 0;
CELLMAXCOLS = 0;
CELLMAXELEMS = 0;
%----- PARAMETERS END -------%
strind=strfind(Xname,'(');
if isempty(strind)
    strind=length(Xname);
end

if isfield(X,'XData')&&isfield(X,'YData')&&(~isfield(X,'HitTest'))&&(numel(X.XData)>0)&&(numel(X.YData)>0)
    if strncmp(Xname,Xname_prev,strind(end))
        ind_list(2)=ind_list(2)+1;
    else
        ind_list(1)=ind_list(1)+1;
        ind_list(2:6)=1;
        Xname_prev=Xname;
    end
    displayname=['/DATA/Plot' num2str(ind_list(1)) '/Data' num2str(ind_list(2)) '/'];
    % x and y data for all plots
    h5create(h5name,[displayname 'XData'],[size(X.XData,1) size(X.XData,2)])
    h5write(h5name,[displayname 'XData'],X.XData)
    h5create(h5name,[displayname 'YData'],[size(X.YData,1) size(X.YData,2)])
    h5write(h5name,[displayname 'YData'],X.YData)
    if isfield(X,'UData')&&~isempty(X.UData)
        % for plots with error bars
        h5create(h5name,[displayname 'UData'],[size(X.UData,1) size(X.UData,2)])
        h5write(h5name,[displayname 'UData'],X.UData)
    end
    if isfield(X,'LData')&&~isempty(X.LData)
        h5create(h5name,[displayname 'LData'],[size(X.LData,1) size(X.LData,2)])
        h5write(h5name,[displayname 'LData'],X.LData)
    end
    if isfield(X,'VData')&&~isempty(X.VData)
        h5create(h5name,[displayname 'VData'],[size(X.VData,1) size(X.VData,2)])
        h5write(h5name,[displayname 'VData'],X.VData)
    end
    if isfield(X,'WData')&&~isempty(X.WData)
        h5create(h5name,[displayname 'WData'],[size(X.WData,1) size(X.WData,2)])
        h5write(h5name,[displayname 'WData'],X.WData)
    end
    if isfield(X,'ZData')&&~isempty(X.ZData)
        % for 3D plots
        h5create(h5name,[displayname 'ZData'],[size(X.ZData,1) size(X.ZData,2)])
        h5write(h5name,[displayname 'ZData'],X.ZData)
    end
    % write attribute data
    h5writeatt(h5name,displayname,'StructPath',Xname)
    if isfield(X,'LineStyle')
        % for plots with defined LineStyle
        h5writeatt(h5name,displayname,'LineStyle',X.LineStyle)
    end
    if isfield(X,'Marker')
        % for plots with defined Marker shape
        h5writeatt(h5name,displayname,'Marker',X.Marker)
    end
    if isfield(X,'Color')
        % for plots with defined Color [r g b]
        h5writeatt(h5name,displayname,'Color [r g b]',X.Color)
    end
    if isfield(X,'DisplayName')
        % for plots with defined DisplayName (in legend)
        h5writeatt(h5name,displayname,'DisplayName',X.DisplayName)
    end
    if isfield(X,'LineWidth')
        % for plots with defined LineWidth
        h5writeatt(h5name,displayname,'LineWidth',X.LineWidth)
    end
elseif isfield(X,'Faces')&&~isfield(X,'HitTest')
    if strncmp(Xname,Xname_prev,strind(end))
        ind_list(2)=ind_list(2)+1;
    else
        ind_list(1)=ind_list(1)+1;
        ind_list(2:6)=1;
        Xname_prev=Xname;
    end
    displayname=['/DATA/Plot' num2str(ind_list(1)) '/Data' num2str(ind_list(2)) '/'];
    h5create(h5name,[displayname 'FaceCoords'],[size(X.Faces,1) size(X.Faces,2)])
    h5write(h5name,[displayname 'FaceCoords'],X.Faces)
    % write attribute data
    h5writeatt(h5name,displayname,'StructPath',Xname)
    if isfield(X,'Color')
        % for plots with defined Color [r g b]
        h5writeatt(h5name,displayname,'Color [r g b]',X.Color)
    end
    if isfield(X,'DisplayName')
        % for plots with defined DisplayName (in legend)
        h5writeatt(h5name,displayname,'DisplayName',X.DisplayName)
    end
elseif isfield(X,'String')&&(~isempty(X.String))&&min(~strcmp(X.String,' '))&&strncmp(Xname,Xname_prev,strind(end))&&isfield(X,'VerticalAlignment')&&isfield(X,'Rotation')
    %         disp(X)
    if iscell(X.String)
        X.String=char(X.String);
    end
    displayname=['/DATA/Plot' num2str(ind_list(1)) '/'];
    if strcmp(X.VerticalAlignment,'bottom')&&(X.Rotation==0)
        labeltype='Title';
        h5writeatt(h5name,displayname,[labeltype num2str(ind_list(5))],reshape(X.String',1,numel(X.String)))
        ind_list(5)=ind_list(5)+1;
    elseif (strcmp(X.VerticalAlignment,'cap')||strcmp(X.VerticalAlignment,'top'))&&(X.Rotation==0)
        labeltype='XLabel';
        h5writeatt(h5name,displayname,[labeltype num2str(ind_list(3))],reshape(X.String',1,numel(X.String)))
        ind_list(3)=ind_list(3)+1;
    elseif (X.Rotation==90)
        labeltype='YLabel';
        h5writeatt(h5name,displayname,[labeltype num2str(ind_list(4))],reshape(X.String',1,numel(X.String)))
        ind_list(4)=ind_list(4)+1;
    else
        labeltype='UnknownLabel';
        h5writeatt(h5name,displayname,[labeltype num2str(ind_list(6))],reshape(X.String',1,numel(X.String)))
        ind_list(6)=ind_list(6)+1;
    end
elseif isfield(X,'type')
    if strcmp(X.type,'histogram')
        if isfield(X.properties,'Data')
            if strncmp(Xname,Xname_prev,strind(end))
                ind_list(2)=ind_list(2)+1;
            else
                ind_list(1)=ind_list(1)+1;
                ind_list(2:6)=1;
                Xname_prev=Xname;
            end
            displayname=['/DATA/Plot' num2str(ind_list(1)) '/Data' num2str(ind_list(2)) '/'];
            % x and y data for all plots
            h5create(h5name,[displayname 'XData'],[size(X.properties.Data,1) size(X.properties.Data,2)])
            h5write(h5name,[displayname 'XData'],X.properties.Data)
        end
    end
end

if isstruct(X)
    F = fieldnames(X);
    nsub = length(F);
    Y = cell(1,nsub);
    subnames = cell(1,nsub);
    for i=1:nsub
        f = F{i};
        Y{i} = X.(f);
        subnames{i} = [Xname '.' f];
    end
else
    return
end

for i=1:nsub
    a = Y{i};
    if isstruct(a) || isobject(a)
        if length(a)==1
            [Xname_prev,ind_list]=rec_struct2h5(subnames{i},a,h5name,Xname_prev,ind_list);
        else
            for k=1:length(a)
                [Xname_prev,ind_list]=rec_struct2h5([subnames{i} '(' num2str(k) ')'],a(k),h5name,Xname_prev,ind_list);
            end
        end
    elseif iscell(a)
        if size(a,1)<=CELLMAXROWS && size(a,2)<=CELLMAXCOLS && numel(a)<=CELLMAXELEMS
            [Xname_prev,ind_list]=rec_struct2h5(subnames{i},a,h5name,Xname_prev,ind_list);
        end
    end
end