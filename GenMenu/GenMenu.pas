{$mode objfpc}
{$coperators on}
const
        fi='TMH.INP';
        fo='TMH.OUT';
        nFood=21; //co 21 mon an
        LimCost=24000; //suat com 24k, vi 1k mua com
        MinCalo=500;
        MaxCalo=600;
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
        MenuArr=array[0..1260] of TMenu;
var     Food:array[1..nFood] of TFood;
        Menu:MenuArr;
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
        writeln(nMenu);
end;
procedure Solve;
begin
        GenMenu;
end;
begin
        fileio;
        enter;
        solve;
end.