{$mode objfpc}
{$coperators on}
uses    GSet,windows;
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
                cost,pos:longint;
                encode:int64;
                calo,wast:real;
        end;
        Tpair=record
                wast:real;
                encode:int64;
                id:longint;
        end;
        LessPair=class
                public
                class function c(const a,b:Tpair):boolean;
        end;
        Tmyset=specialize TSet<Tpair,LessPair>;
        MenuArr=array[0..1260] of TMenu;
class function LessPAir.c(const a,b:Tpair):boolean;
begin
        exit(a.wast<b.wast);
end;
var     Food:array[1..nFood] of TFood;
        base:array[0..21] of int64;
        Menu:MenuArr;
        Match:array[0..600000] of TMenu;
        nMenu:longint;
        myset:TmySet;
        time:int64;
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
                for i:=1 to 4 do begin
                        calo+=GetCaloFood(id[i]);
                        wast+=GetWastFood(id[i]);
                        cost+=Food[id[i]].cost;
                end;
        end;
end;
procedure GenMenu;
var     i,j,tmp,n:longint;
begin
        base[0]:=1;
        for i:=1 to 21 do
                base[i]:=base[i-1]*6;
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
        for j:=1 to nMenu do begin
                Menu[j].id[3]:=11;
        end;
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
                with Menu[n] do begin
                        encode:=base[id[1]-1]+base[id[2]-1]+base[id[3]-1]+base[id[4]-1];
                        pos:=n;
                end;
        end;
        nMenu:=n;
end;
function ValidMenu(u:int64):boolean;
var     i:longint;
begin
        for i:=21 downto 0 do begin
                if (u div base[i]>2) then exit(false);
                u:=u mod base[i];
        end;
        exit(true);
end;
procedure FunctionF; //minimize the amount of wasted calories
var     i,j,top,save,save1,save2:longint;
        tmp:int64;
        pair:Tpair;
        saveIT,IT:Tmyset.Titerator;
        res,consumed:real;
begin
        top:=0;
        for i:=1 to nMenu do
                for j:=i to nMenu do begin
                        inc(top);
                        with Match[top] do begin
                                encode:=Menu[i].encode+Menu[j].encode;
                                id[1]:=Menu[i].pos;
                                id[2]:=Menu[j].pos;
                                wast:=Menu[i].wast+Menu[j].wast;
                        end;
                end;
        save:=top;
        for i:=1 to save do begin
                for j:=match[i].id[2]+1 to nMenu do begin
                        tmp:=match[i].encode+Menu[j].encode;
                        inc(top);
                        Match[top]:=Match[i];
                        Match[top].encode:=tmp;
                        Match[top].id[3]:=j;
                        Match[top].wast+=Menu[j].wast;
                end;
        end;
        for i:=1 to save do begin
                Match[i].id[3]:=Match[i].id[2];
                Match[i].encode+=Menu[Match[i].id[3]].encode;
                Match[i].wast+=Menu[Match[i].id[3]].wast;
        end;
        save:=0;
        myset:=Tmyset.create;
        for i:=1 to top do if (ValidMenu(Match[i].encode)) then begin
                inc(save);
                Match[save]:=Match[i];
                pair.wast:=Match[save].wast;
                pair.encode:=Match[save].encode;
                pair.id:=save;
                myset.insert(pair);
        end;
        top:=save;
        saveIT:=Myset.Min;
        res:=999999999;
        for i:=1 to top do begin
                it:=saveIT;
                repeat
                        pair:=IT.data;
                        if ValidMenu(pair.encode+Match[i].encode) then
                                if (pair.wast+match[i].wast<=res) then begin
                                        res:=pair.wast+match[i].wast;
                                        save1:=pair.id;
                                        save2:=i;
                                end;
                until not IT.next;
        end;
        write('The amount of calories wasted: ');
        writeln(res:0:5,' kcal');
        write('The amount of caloric intake: ');
        consumed:=0;
        with match[save1] do
                for i:=1 to 3 do
                        consumed+=Menu[id[i]].calo;
        with match[save2] do
                for i:=1 to 3 do
                        consumed+=Menu[id[i]].calo;
        writeln(consumed:0:5,' kcal');
        writeln('Performance: ',consumed/(res+consumed)*100:0:5,'%');
        //ValidMenu(match[save1].encode+match[save2].encode);
        with match[save1] do begin
                for i:=1 to 3 do begin
                        write('Menu for day ',i,': ');
                        for j:=1 to 4 do
                                write(Menu[id[i]].id[j],#32);
                        writeln;
                end;
        end;
        with match[save2] do begin
                for i:=1 to 3 do begin
                        write('Menu for day ',i+3,': ');
                        for j:=1 to 4 do
                                write(Menu[id[i]].id[j],#32);
                        writeln;
                end;
        end;
end;
procedure Solve;
begin
        GenMenu;
        FunctionF;
end;
begin
        time:=gettickcount;
        fileio;
        enter;
        solve;
        writeln('Running time: ',gettickcount-time,' ms');
end.
