function [EMGData] = readUCI(f,notch)

class = 6;
channel = 2;
Labels = cell(12,1);
lvalue = {'cyl';'hook';'lat';'palm';'spher';'tip'};
data = zeros(3,1000);

sub = 2;
index = 3;
for j=1:sub
    for k=1:index
        switch j
            case 1
                filename = sprintf('./Database 1/female_%d.mat',k);
            case 2
                if k == 3
                   break;
                else
                    filename = sprintf('./Database 1/male_%d.mat',k);
                end
        end
  
        t1 = load(filename);
        
        for m=1:class
           for n=1:channel
                switch m
                    case 1
                        field = sprintf('cyl_ch%d',n);
                    case 2
                        field = sprintf('hook_ch%d',n);
                    case 3
                        field = sprintf('lat_ch%d',n);
                    case 4
                        field = sprintf('palm_ch%d',n);
                    case 5
                        field = sprintf('spher_ch%d',n);
                    case 6
                        field = sprintf('tip_ch%d',n);
                end
                temp_data = t1.(field);
                t2 = temp_data;
                t = zeros(3,1000);
                
                for a=1:500:size(t2,2)     
                    b=a+499;
                    win = t2(:,a:b);
                    if t == 0
                       t = win;
                    else
                       t = [t;win];
                    end
                end
                
            bf = filter(f,t);
            ft = filter(notch,bf);
        
            l(1:size(ft,1),1) = lvalue(m);

            if data == 0 
               data = ft;
               Labels = l;
            else
               data = [data;ft];
               Labels = [Labels;l];
            end
           end
       end
    end
end

EMGData.Data = data;
EMGData.Labels = Labels;
end