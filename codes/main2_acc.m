function main2_acc(brej_healthy,brej_faulty,feature,datawidth,brej_dataset)

%this program uses 4 threshold values which can be changed by the user
thresh_zcr=1;           %threshold value for zcr
thresh_separation=1;   %threshold value for sepation
thresh_ratio=1.2;       %threshold value for ratio of means
thresh_std=1.6;         %threshold value for standard deviation of means of datasets
%In order to looosen the thresholds,the user is advised to change the...
%...threshold values from bottom to top i.e., do for std then move to zcr
score=ones(1,feature);sepcount=0;dataset=0;

%this function finds which dataset has to be rejected
k=rej_func(brej_healthy,brej_faulty,feature,datawidth,brej_dataset,thresh_zcr,thresh_separation,thresh_ratio,thresh_std);
if(k~=0)
fprintf('Dataset rejected = %d\n',k)
else
    fprintf('No Dataset rejected\n');
end
%if k is non zero,then some dataset has to be rejected.The removal of that particular dataset is below
if(k~=0)
    ind=datawidth*(k-1);
    if(ind~=0)
        healthy(1:ind,:)=brej_healthy(1:ind,:);
        faulty(1:ind,:)=brej_faulty(1:ind,:);
    end
    healthy(ind+1:(brej_dataset*datawidth)-datawidth,:)=brej_healthy(ind+datawidth+1:(brej_dataset*datawidth),:);
    faulty(ind+1:(brej_dataset*datawidth)-datawidth,:)=brej_faulty(ind+datawidth+1:(brej_dataset*datawidth),:);
    dataset=brej_dataset-1;
else
    healthy=brej_healthy;faulty=brej_faulty; 
end
        
diffdata=healthy-faulty;
for j=1:feature
    count = 0;  
    for i=1:((datawidth*dataset)-1)
        if(diffdata(i+1,j)>=0 && diffdata(i,j)<=0)
            count=count+1;
        else if(diffdata(i+1,j)<=0 && diffdata(i,j)>=0)
                count=count+1;
            end;
        end;
    end;
    if(j==20)
     disp(count);   
    end
    if (count>thresh_zcr)
        score(1,j)=0;
    end    
end;

for i=1:feature
    if(score(1,i)~=0)
        meanh=mean(healthy(:,i));
        meanf=mean(faulty(:,i));
    else
        continue;
    end
    if(meanh>meanf)
        upper=healthy(:,i);
        lower=faulty(:,i);
    else
        upper=faulty(:,i);
        lower=healthy(:,i);
    end
    
    for j=1:dataset*datawidth
        if(lower(j,1)>=min(upper)||upper(j,1)<max(lower))
            sepcount=sepcount+1;
        end
        
    end
    if((sepcount>thresh_separation)||abs((mean(upper)/mean(lower))<thresh_ratio))       %threshold for separation
        score(1,i)=0;
    end
    sepcount=0;
end


for i=1:feature;  
    h=zeros(1,dataset);f=zeros(1,dataset);
    nor_hea=healthy(:,i);nor_fau=faulty(:,i);
    std_hea=std(nor_hea);std_fau=std(nor_fau);
    mn_hea=mean(nor_hea);mn_fau=mean(nor_fau);
    nor_hea(:,1)=(nor_hea(:,1)-mn_hea)/std_hea;nor_fau(:,1)=(nor_fau(:,1)-mn_fau)/std_fau;
    for j=0:(dataset-1)
        ind=datawidth*j+1:datawidth*j+datawidth;
        temp_hea=nor_hea(ind,1);temp_fau=nor_fau(ind,1);
        h(j+1)=mean(temp_hea);  f(j+1)=mean(temp_fau);
    end
    if(std(h)+std(f)>thresh_std)       %threshold for standard deviation
        score(i)=0;
    end
end


for i=1:feature;
    if(score(i)~=0)
        fprintf('feature%d\n',i);
        x_plot = 1:(dataset+1)*datawidth;
        disp(dataset);
        disp(datawidth);
        disp((dataset+1)*datawidth);
        h = figure;
        plot(x_plot, brej_healthy(:,i), '-g', x_plot, brej_faulty(:,i), '-b');
        set(gca,'XTick',0:datawidth:(dataset+1)*datawidth);
        disp((dataset+1)*datawidth);
        grid on;
        
        path = sprintf('F:\\Desktop\\result\\Fea_%d',i);
        legend({'Healthy','Faulty'}, 'Location', 'NorthEast');
        ti = sprintf('Fea%d',i);
        title(ti);
        xlabel('Samples');ylabel('Amplitude');
        saveas(h,path,'png');
        close;
        
    end
end
end







function rejected=rej_func(healthy,faulty,feature,datawidth,dataset,thresh_zcr,thresh_separation,thresh_ratio,thresh_std)


score=ones(1,feature);rej=zeros(1,feature);
rejection=zeros(1,dataset);
diffdata=healthy-faulty;
for j=1:feature
    count = 0;  M=0;prev=0;           
    for i=1:((datawidth*dataset)-1)
        if(diffdata(i+1,j)>=0 && diffdata(i,j)<=0)
            count=count+1;
        else if(diffdata(i+1,j)<=0 && diffdata(i,j)>=0)
                count=count+1;
            end;
        end;
         
        if(mod(i+1,datawidth)==0)
           if((count-prev)>M)
            M=count-prev; 
            prev=count;
            index=(i+1)/datawidth;
           end
        end
        
    end;
    
   
    if(count>2&&count>thresh_zcr)
        if((M/count)>0.8)
         rej(1,j)=index;
         count=count-M; 
        end
    end
    if (count>thresh_zcr)
        score(1,j)=0;
    end
    
end;



for i=1:feature
    if(score(1,i)~=0)
        meanh=mean(healthy(:,i));
        meanf=mean(faulty(:,i));
    else
        continue;
    end
    if(meanh>meanf)
        upper=healthy(:,i);
        lower=faulty(:,i);
    else
        upper=faulty(:,i);
        lower=healthy(:,i);
    end
    sepcounter=zeros(1,dataset);
    for k=0:dataset-1
        temp=0;
        ind=datawidth*k;
        if(ind~=0)
            rej_upper(1:ind,1)=upper(1:ind,1);
            rej_lower(1:ind,1)=lower(1:ind,1);
        end
        rej_upper(ind+1:(dataset*datawidth)-datawidth,1)=upper(ind+datawidth+1:(dataset*datawidth),1);
        rej_lower(ind+1:(dataset*datawidth)-datawidth,1)=lower(ind+datawidth+1:(dataset*datawidth),1);
        
        for j=1:((dataset*datawidth)-datawidth)
            if(rej_lower(j,1)>=min(rej_upper)||rej_upper(j,1)<max(rej_lower))
                temp=temp+1;                
            end
        end
        sepcounter(k+1)=temp;
    end
   
    sepcount=min(sepcounter);
    rej(i)=find(sepcounter==sepcount,1);
    if((sepcount>thresh_separation)||abs((mean(upper)/mean(lower))<thresh_ratio))       %threshold for separation
        score(i)=0;
        rej(i)=0;
    end
end

for i=1:feature;  
    h=zeros(1,dataset);f=zeros(1,dataset);
    nor_hea=healthy(:,i);nor_fau=faulty(:,i);
    std_hea=std(nor_hea);std_fau=std(nor_fau);
    mn_hea=mean(nor_hea);mn_fau=mean(nor_fau);
    nor_hea(:,1)=(nor_hea(:,1)-mn_hea)/std_hea;nor_fau(:,1)=(nor_fau(:,1)-mn_fau)/std_fau;
    for j=0:(dataset-1)
        ind=datawidth*j+1:datawidth*j+datawidth;
        temp_hea=nor_hea(ind,1);temp_fau=nor_fau(ind,1);
        h(1,j+1)=mean(temp_hea);  f(1,j+1)=mean(temp_fau);
    end
    if(std(h)+std(f)>thresh_std)       %threshold for standard deviation
        score(i)=0;
    end
    
end

gcount=0;
for i=1:feature;
    
    if(score(i)~=0)
        gcount=gcount+1;
        if(rej(i)~=0)
        rejection(rej(i))=rejection(rej(i))+1;
        end
    end
end
if((max(rejection)/gcount)>0.5)
    rejected=find(rejection==max(rejection),1);
else
    rejected=0;
end
end





        

    


