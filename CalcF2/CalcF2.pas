{$mode objfpc}
{$coperators on}
const
        fi='TMH.INP';
        fo='TMH.OUT';
        nFood=21; //co 21 mon an
        LimCost=24000; //suat com 24k, vi 1k mua com
        MinCalo=500;
        MaxCalo=600;
        nDay=6;
procedure fileio;
begin
        assign(input,fi); reset(input);
        assign(output,fo); rewrite(output);
end;
type    TFood=record
                calo,cost,time:longint;
                vote,perform:real;
        end;
        TMenu=record
                id:array[1..4] of longint;
                cost:longint;
                calo,wast,vote:real;
        end;
        Tdata=record
                id:longint;
                vote:real;
        end;
        Arr=array[1..147] of Tdata;
        MenuArr=array[0..1260] of TMenu;
var     Food:array[1..nFood] of TFood;
        cnt:array[1..nFood] of longint;
        choose:array[1..nDay] of longint;
        Menu:MenuArr;
        a:array[1..nDay] of Arr;
        nMenu:longint;
procedure enter;
var     i:longint;
begin
        for i:=1 to nFood do
                with food[i] do begin
                        readln(calo,cost,vote,perform);
                        perform/=100;
                end;
end;
function GetCaloFood(idx:longint):real;
begin
        with Food[idx] do
                exit(calo*perform);
end;
function GetWastFood(idx:longint):real;
begin
        with Food[idx] do
                exit(calo-calo*perform);
end;
procedure CalcMenu(var Menu:TMenu);
var     i:longint;
begin
        with Menu do begin
                calo:=0;
                cost:=0;
                wast:=0;
                vote:=0;
                for i:=1 to 4 do begin
                        calo+=GetCaloFood(id[i]);
                        wast+=GetWastFood(id[i]);
                        cost+=Food[id[i]].cost;
                        vote+=Food[id[i]].vote;
                end;
        end;
end;
procedure GenMenu;
var     i,j,tmp,n:longint;
begin
        //2 mon an man
        for i:=1 to 9 do
                for j:=i+1 to 10 do begin
                        inc(nMenu);
                        with Menu[nMenu] do begin
                                id[1]:=i;
                                id[2]:=j;
                        end;
                end;
        //mon rau
        tmp:=nMenu;
        for j:=1 to nMenu do
                Menu[j].id[3]:=11;
        for i:=12 to 17 do begin
                for j:=1 to tmp do begin
                        inc(nMenu);
                        with Menu[nMenu] do begin
                                id:=Menu[j].id;
                                id[3]:=i;
                        end;
                end;
        end;
        //mon canh
        tmp:=nMenu;
        for j:=1 to nMenu do
                Menu[j].id[4]:=18;
        for i:=19 to 21 do begin
                for j:=1 to tmp do begin
                        inc(nMenu);
                        with Menu[nMenu] do begin
                                id:=Menu[j].id;
                                id[4]:=i;
                        end;
                end;
        end;

        for i:=1 to nMenu do
                CalcMenu(Menu[i]);
        n:=0;
        for i:=1 to nMenu do begin
                if (Menu[i].cost>LimCost) or (Menu[i].calo<MinCalo) or (Menu[i].calo>MaxCalo) then
                        continue;
                inc(n);
                Menu[n]:=Menu[i];
        end;
        nMenu:=n;
end;
procedure UpdateFood(idx,typ:longint);
begin
        with Food[idx] do
                vote-=typ*0.5;
        inc(cnt[idx],typ);
end;
procedure UpdateMenu(idx, typ:longint);
var     i:longint;
begin
        with Menu[idx] do
                for i:=1 to 4 do
                        UpdateFood(id[i],typ);
end;
function IsAble(var Menu:Tmenu):boolean;
var     i:longint;
begin
        with Menu do
                for i:=1 to 4 do
                        if (cnt[id[i]]>=2) then
                                exit(false);
        exit(true);
end;
procedure sort(var a:Arr;l,r: longint);
      var
         i,j: longint;
         x,y:Tdata;
      begin
         i:=l;
         j:=r;
         x:=a[(l+r) div 2];
         repeat
           while a[i].vote>x.vote do
            inc(i);
           while x.vote>a[j].vote do
            dec(j);
           if not(i>j) then
             begin
                y:=a[i];
                a[i]:=a[j];
                a[j]:=y;
                inc(i);
                j:=j-1;
             end;
         until i>j;
         if l<j then
           sort(a,l,j);
         if i<r then
           sort(a,i,r);
      end;
function BackTrack(day:longint):boolean;
var     top,i:longint;
begin
        if (day>nDay) then
                exit(true);
        top:=0;
        for i:=1 to nMenu do begin
                CalcMenu(Menu[i]);
                if IsAble(Menu[i]) then begin
                        inc(top);
                        a[day][top].id:=i;
                        a[day][top].vote:=Menu[i].vote;
                end;
        end;
        if (top=0) then exit(false);
        sort(a[day],1,top);
        for i:=1 to top do begin
                updateMenu(a[day][i].id,1);
                if (BackTrack(day+1)) then begin
                        Choose[day]:=a[day][i].id;
                        exit(true);
                end;
                updateMenu(a[day][i].id,-1);
        end;
        exit(false);
end;
procedure Functionf; //maximize vote
var     i,j:longint;
        Wasted,used:real;
begin
        wasted:=0; used:=0;
        if BackTrack(1) then begin
                for i:=1 to nDay do
                        with Menu[choose[i]] do begin
                                wasted+=wast;
                                Used+=calo;
                        end;
                writeln('The amount of calories wasted: ',wasted:0:5);
                writeln('The amount of caloric intake: ',used:0:5);
                writeln('Performance: ',used/(used+wasted)*100:0:5,'%');
                for i:=1 to nDay do begin
                        write('Menu for day ',i,': ');
                        with Menu[choose[i]] do begin
                                for j:=1 to 4 do
                                        write(id[j],#32);
                                writeln;
                        end;
                end;
        end;

end;
procedure Solve;
begin
        GenMenu;
        Functionf;
end;
begin
        fileio;
        enter;
        solve;
end.