classnames = {'bed','fall','pickup','run','sitdown','standUp','walk','NoActivity'};
output = zeros([1,8]);
beta = 0.5;
net = importKerasNetwork('models/model_arch1.json','WeightFile','models/model4.h5', 'classnames', ...
    classnames,'OutputLayerType','classification');
spmd(2) 
if labindex == 1
    my_activity;
elseif labindex == 2
    while 1
        clc
        p = labReceive(1);
        classify_activity(p,net,classnames);
            
    end
end
    
end

%delete(gcp('nocreate'))

    