function output = classify_activity(p,net,classnames)

output = predict(net,p');
[~,class] = max(output);
classnames(class)

end