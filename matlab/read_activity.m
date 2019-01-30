%   Further Modified by Muhammad Sulaiman
%   Email: almani.sulaiman@yahoo.com

function read_activity()


% classnames = {'bed','fall','walk','pickup','run','sitdown','standUp','NoActivity'};
% net = importKerasNetwork('models/model_arch.json','WeightFile','models/model.h5', 'classnames', ...
%     classnames,'OutputLayerType','classification');

%fig= figure;
%hPan = uipanel(fig,'Units','normalized');
while 1
%% Build a TCP Server and wait for connection
    port = 8090;
    t = tcpip('0.0.0.0', port, 'NetworkRole', 'server');
    t.InputBufferSize = 1024;
    t.Timeout = 150;
    fprintf('Waiting for connection on port %d\n',port);
    fopen(t);
    fprintf('Accept connection from %s\n',t.RemoteHost);

%% Initialize variables
    csi_entry = [];
    index = 1;                     % The index of the plots which need shadowing
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas
    p = zeros([500,90]);
    
    
%% Process all entries in socket
    % Need 3 bytes -- 2 byte size field and 1 byte code
    while 1
        % Read size and code from the received packets
        s = warning('error', 'instrument:fread:unsuccessfulRead');
        try
            field_len = fread(t, 1, 'uint16');
        catch
            warning(s);
            disp('Timeout, please restart the client and connect again.');
            break;
        end

        code = fread(t,1); 
        % If unhandled code, skip (seek over) the record and continue
        if (code == 187) % get beamforming or phy data
            bytes = fread(t, field_len-1, 'uint8');
            bytes = uint8(bytes);
            if (length(bytes) ~= field_len-1)
                fclose(t);
                return;
            end
        else if field_len <= t.InputBufferSize  % skip all other info
            fread(t, field_len-1, 'uint8');
            continue;
            else
                continue;
            end
        end                                                                       
        
        if (code == 187) % (tips: 187 = hex2dec('bb')) Beamforming matrix -- output a record
            csi_entry = read_bfee(bytes);
        
            perm = csi_entry.perm;
            Nrx = csi_entry.Nrx;
            if Nrx > 1 % No permuting needed for only 1 antenna
                if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                    if broken_perm == 0
                        broken_perm = 1;
                        fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', 'server', Nrx, int2str(perm));
                    end
                else
                    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
                end
            end
        end
       
        csi = get_scaled_csi(csi_entry);%CSI data
        
	%You can use the CSI data here.
            
        csi = squeeze(csi)';
        p(1:end-1,:) = p(2:end,:);
        %p(end,:) = abs(csi(:))'; 
        p(end,:) = db(csi(:))'; 
        index = mod(index + 1,35);
        if index == 0
            labSend(p,2)
        end
%         index = mod(index+1,100);
%         if index == 0
%             classify(net,p')
%         end
%         uicontrol(hPan,'Style','text','HorizontalAlignment','center','FontSize',25,'Units','normalized',...
%             'Position',[0.2,0.4,0.6,0.2],'String',char(classify(net,p')))
        csi_entry = [];

    end
%% Close file
     fclose(t);
     delete(t);
end 

end