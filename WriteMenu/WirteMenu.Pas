var	s:array[1..21] of string;
	i,j,x:longint;
begin
	s[1]:='Cá chép rán';
	s[2]:='Cá thu sốt cà chua';
	s[3]:='Đùi gà rán';
	s[4]:='Giò lụa';
	s[5]:='Mực xào';
	s[6]:='Sườn lợn xào chua ngọt';
	s[7]:='Tép rán';
	s[8]:='Thăn lợn xào cô ve';
	s[9]:='Tôm chiên';
	s[10]:='Trứng rán';
	s[11]:='Củ quả luộc';
	s[12]:='Cải bắp luộc';
	s[13]:='Đậu rán';
	s[14]:='Đậu sốt cà chua';
	s[15]:='Giá xào';
	s[16]:='Nấm xào';
	s[17]:='Rau muống xào tỏi';
	s[18]:='Canh bí đỏ nấu sườn';
	s[19]:='Canh chua';
	s[20]:='Canh mùng tơi';
	s[21]:='Canh rau cải/ngót thịt bằm';
	for i:=1 to 6 do begin
			writeln('Menu for day ',i,': ');
			for j:=1 to 4 do begin
				read(x);
				writeln('     ',s[x]);
			end;
	end;
end.
