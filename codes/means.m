temp=0;count1=0;count2=0;tmean=0;nmean1h=0;nmean2h=0;
nmean1f=0;nmean2f=0;mh=0;mf=0;arr=zeros(1,629); 
for i=1:629;
    for j=0:7
        ind=32*j+1:32*j+32;
        temp_hea=acc(ind,i);
        temp_lov=acclov(ind,i);
        h=mean(temp_hea);
        f=mean(temp_lov);
        mh=mh+h;
        mf=mf+f;
        if(abs((h/f))>1)
            count1=count1+1;
            nmean1h=nmean1h+h;
            nmean1f=nmean1f+f;
        end
        if(abs((f/h))>1)
            count2=count2+1;
            nmean2h=nmean2h+h;
            nmean2f=nmean2f+f;
        end
    end
    tmean=max(abs(mh),abs(mf))/min(abs(mh),abs(mf));
    if(mh/mf<0)
      tmean=-tmean;  
    end
    if(count1>count2)
        arr(i)=abs(((nmean1h/nmean1f)-1)*100);
        else
        arr(i)=abs(((nmean2f/nmean2h)-1)*100);
    end
    arr(i)=arr(i)+abs((tmean-1)*100);
    if(count1==3||count1==4||count1==5||(count1==0&&count2==0))
     arr(i)=0; 
    end
    count1=0;count2=0;
    nmean1f=0;nmean2f=0;nmean1h=0;nmean2h=0;tmean=0;mh=0;mf=0;
end
disp(arr);