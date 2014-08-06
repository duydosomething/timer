library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DividerPackage.all;
use ieee.numeric_std.all; 


entity timer2 is
port(
		clock:            in std_logic;
      start:            in std_logic;
      InitialTime:      in std_logic_vector (5 downto 0);   
      done:             out std_logic := '0';
		seg:              out std_logic_vector(6 downto 0);
      dp:               out std_logic;
      an:               out std_logic_vector(0 to 3)

	  );	  
end timer2;

ARCHITECTURE behavior of timer2 is
signal dp_value: std_logic_vector(3 downto 0) := "1101";
signal clock_7segment:std_logic := '0';
signal go: std_logic := '0';
signal stop: std_logic := '0';
signal SlowClock:std_logic := '0';
signal product: unsigned(11 downto 0);
signal sixty: std_logic_vector(11 downto 0) := "000000111100";
signal six: std_logic_vector(5 downto 0) := "111100";
signal ten: std_logic_vector(5 downto 0) := "001010";
signal minutes: std_logic_vector(11 downto 0);
signal seconds: std_logic_vector(11 downto 0);
signal temp: unsigned(11 downto 0);
signal tsec2:	  std_logic_vector(5 downto 0);
signal	tsec1:	std_logic_vector(5 downto 0);
signal	tmin2:	std_logic_vector(5 downto 0);
signal	tmin1:	std_logic_vector(5 downto 0);
signal   sec2:	  std_logic_vector(3 downto 0);
signal	sec1:	 std_logic_vector(3 downto 0);
signal	min2:	 std_logic_vector(3 downto 0);
signal	min1:	 std_logic_vector(3 downto 0);
signal tempsegm2: std_logic_vector(6 downto 0);
signal tempsegm1: std_logic_vector(6 downto 0);
signal tempsegs2: std_logic_vector(6 downto 0);
signal tempsegs1: std_logic_vector(6 downto 0);

begin

--Process for 7 segment refresh
process (clock)
	variable counter: integer := 0;
	begin
		if(clock 'event and clock = '1') then
		if(counter >= 0 and counter < 100) then
			counter := counter +1;
			clock_7segment <= '0';
		elsif (counter < 200) then
			counter := counter +1;
			clock_7segment <= '1';
		else
			counter := 0;
		end if;
		end if;
	end process;

--Process for Slow clock
process (clock)
variable counter: integer := 0;
begin
        if(clock'event and clock = '1') then
               if(counter >= 0 and counter < 25000000) then
                       counter := counter +1;
                       SlowClock <= '0';
               elsif (counter < 50000000) then
                       counter := counter +1;
                       SlowClock <= '1';
               else
                       counter := 0;
               end if;
        end if;
end process;

--Multiplier process
process(InitialTime)
begin

product <= unsigned(InitialTime) * unsigned(six);

end process;



--down counter
process(SlowClock, start, product)
begin
if start = '0' and go = '0' then
temp <= product;
else
go <= '1';

if SlowClock'event and SlowClock ='1' then
		if go = '1' and stop = '0' then
			temp <= temp - 1;
		if temp = "000000000001" then
			done <= '1';
			stop <= '1';
		end if;
		end if;	
end if;
end if;
end process;


--divider
process(temp)
begin
	seconds <= module(std_logic_vector(temp), sixty);
	minutes <= divide(std_logic_vector(temp), sixty);
end process;

--process for left second
process(seconds)
begin
tsec2 <= divide(seconds(5 downto 0), ten);
end process;

--process for right second
process(seconds)
begin
tsec1 <= module(seconds(5 downto 0), ten);
end process;

--process for left minute
process(minutes)
begin
tmin2 <= divide(minutes(5 downto 0), ten);
end process;

--process for right minute
process(minutes)
begin
tmin1 <= module(minutes(5 downto 0), ten);
end process;

sec2 <= tsec2(3 downto 0);
sec1 <= tsec1(3 downto 0);
min2 <= tmin2(3 downto 0);
min1 <= tmin1(3 downto 0);

process(sec2)
		begin
		 tempsegs2(0) <= (not(sec2(3)) and not(sec2(2)) and not(sec2(1)) and sec2(0)) or 
		      (not(sec2(3)) and sec2(2) and not(sec2(1)) and not(sec2(0))) or 
		      (sec2(3) and sec2(2) and not(sec2(1)) and sec2(0)) or 
		      (sec2(3) and not(sec2(2)) and sec2(1) and sec2(0)); 
		 tempsegs2(1) <= (not(sec2(3)) and sec2(2) and not(sec2(1)) and sec2(0)) or
		     (sec2(2) and sec2(1) and not(sec2(0))) or
		     (sec2(3) and sec2(1) and sec2(0)) or 
		     (sec2(3) and sec2(2) and not(sec2(1)) and not(sec2(0))); 
		 tempsegs2(2)<= (not(sec2(3)) and not(sec2(2)) and sec2(1) and not(sec2(0))) or
		     (sec2(3) and sec2(2) and not(sec2(1)) and not(sec2(0))) or 
		     (sec2(3) and sec2(2) and sec2(1)); 
		 tempsegs2(3) <= (not(sec2(3)) and sec2(2) and not(sec2(1)) and not(sec2(0))) or 
		     (not(sec2(3)) and not(sec2(2)) and not(sec2(1)) and sec2(0)) or
		     (sec2(2) and sec2(1) and sec2(0)) or
		     (sec2(3) and not(sec2(2)) and sec2(1) and not(sec2(0))); 
		 tempsegs2(4) <= (not(sec2(3)) and sec2(2) and not(sec2(1)) and not(sec2(0))) or 
			  (not(sec2(3)) and sec2(0)) or
			  (sec2(3) and not(sec2(2)) and not(sec2(1)) and sec2(0)); 
		 tempsegs2(5)<= (not(sec2(3)) and not(sec2(2)) and not(sec2(1)) and sec2(0)) or
		     (not(sec2(3)) and not(sec2(2)) and sec2(1) and not(sec2(0))) or
		     (not(sec2(3)) and sec2(1) and sec2(0)) or 
		     (sec2(3) and sec2(2) and not(sec2(1)) and sec2(0)); 
		 tempsegs2(6) <= (not(sec2(3) or sec2(2) or sec2(1))) or
		     (not(sec2(3)) and sec2(2) and sec2(1) and sec2(0)) or
		    (sec2(3) and sec2(2) and not(sec2(1)) and not(sec2(0)));
		
	end process;		
	
	process(sec1)
		begin
		 tempsegs1(0) <= (not(sec1(3)) and not(sec1(2)) and not(sec1(1)) and sec1(0)) or 
		      (not(sec1(3)) and sec1(2) and not(sec1(1)) and not(sec1(0))) or 
		      (sec1(3) and sec1(2) and not(sec1(1)) and sec1(0)) or 
		      (sec1(3) and not(sec1(2)) and sec1(1) and sec1(0)); 
		 tempsegs1(1) <= (not(sec1(3)) and sec1(2) and not(sec1(1)) and sec1(0)) or
		     (sec1(2) and sec1(1) and not(sec1(0))) or
		     (sec1(3) and sec1(1) and sec1(0)) or 
		     (sec1(3) and sec1(2) and not(sec1(1)) and not(sec1(0))); 
		 tempsegs1(2)<= (not(sec1(3)) and not(sec1(2)) and sec1(1) and not(sec1(0))) or
		     (sec1(3) and sec1(2) and not(sec1(1)) and not(sec1(0))) or 
		     (sec1(3) and sec1(2) and sec1(1)); 
		 tempsegs1(3) <= (not(sec1(3)) and sec1(2) and not(sec1(1)) and not(sec1(0))) or 
		     (not(sec1(3)) and not(sec1(2)) and not(sec1(1)) and sec1(0)) or
		     (sec1(2) and sec1(1) and sec1(0)) or
		     (sec1(3) and not(sec1(2)) and sec1(1) and not(sec1(0))); 
		 tempsegs1(4) <= (not(sec1(3)) and sec1(2) and not(sec1(1)) and not(sec1(0))) or 
			  (not(sec1(3)) and sec1(0)) or
			  (sec1(3) and not(sec1(2)) and not(sec1(1)) and sec1(0)); 
		 tempsegs1(5)<= (not(sec1(3)) and not(sec1(2)) and not(sec1(1)) and sec1(0)) or
		     (not(sec1(3)) and not(sec1(2)) and sec1(1) and not(sec1(0))) or
		     (not(sec1(3)) and sec1(1) and sec1(0)) or 
		     (sec1(3) and sec1(2) and not(sec1(1)) and sec1(0)); 
		 tempsegs1(6) <= (not(sec1(3) or sec1(2) or sec1(1))) or
		     (not(sec1(3)) and sec1(2) and sec1(1) and sec1(0)) or
		    (sec1(3) and sec1(2) and not(sec1(1)) and not(sec1(0)));
		
	end process;	
	
	process(min2)
		begin
		 tempsegm2(0) <= (not(min2(3)) and not(min2(2)) and not(min2(1)) and min2(0)) or 
		      (not(min2(3)) and min2(2) and not(min2(1)) and not(min2(0))) or 
		      (min2(3) and min2(2) and not(min2(1)) and min2(0)) or 
		      (min2(3) and not(min2(2)) and min2(1) and min2(0)); 
		 tempsegm2(1) <= (not(min2(3)) and min2(2) and not(min2(1)) and min2(0)) or
		     (min2(2) and min2(1) and not(min2(0))) or
		     (min2(3) and min2(1) and min2(0)) or 
		     (min2(3) and min2(2) and not(min2(1)) and not(min2(0))); 
		 tempsegm2(2)<= (not(min2(3)) and not(min2(2)) and min2(1) and not(min2(0))) or
		     (min2(3) and min2(2) and not(min2(1)) and not(min2(0))) or 
		     (min2(3) and min2(2) and min2(1)); 
		 tempsegm2(3) <= (not(min2(3)) and min2(2) and not(min2(1)) and not(min2(0))) or 
		     (not(min2(3)) and not(min2(2)) and not(min2(1)) and min2(0)) or
		     (min2(2) and min2(1) and min2(0)) or
		     (min2(3) and not(min2(2)) and min2(1) and not(min2(0))); 
		 tempsegm2(4) <= (not(min2(3)) and min2(2) and not(min2(1)) and not(min2(0))) or 
			  (not(min2(3)) and min2(0)) or
			  (min2(3) and not(min2(2)) and not(min2(1)) and min2(0)); 
		 tempsegm2(5)<= (not(min2(3)) and not(min2(2)) and not(min2(1)) and min2(0)) or
		     (not(min2(3)) and not(min2(2)) and min2(1) and not(min2(0))) or
		     (not(min2(3)) and min2(1) and min2(0)) or 
		     (min2(3) and min2(2) and not(min2(1)) and min2(0)); 
		 tempsegm2(6) <= (not(min2(3) or min2(2) or min2(1))) or
		     (not(min2(3)) and min2(2) and min2(1) and min2(0)) or
		    (min2(3) and min2(2) and not(min2(1)) and not(min2(0)));
		
	end process;	
	process(min1)
		begin
		 tempsegm1(0) <= (not(min1(3)) and not(min1(2)) and not(min1(1)) and min1(0)) or 
		      (not(min1(3)) and min1(2) and not(min1(1)) and not(min1(0))) or 
		      (min1(3) and min1(2) and not(min1(1)) and min1(0)) or 
		      (min1(3) and not(min1(2)) and min1(1) and min1(0)); 
		 tempsegm1(1) <= (not(min1(3)) and min1(2) and not(min1(1)) and min1(0)) or
		     (min1(2) and min1(1) and not(min1(0))) or
		     (min1(3) and min1(1) and min1(0)) or 
		     (min1(3) and min1(2) and not(min1(1)) and not(min1(0))); 
		 tempsegm1(2)<= (not(min1(3)) and not(min1(2)) and min1(1) and not(min1(0))) or
		     (min1(3) and min1(2) and not(min1(1)) and not(min1(0))) or 
		     (min1(3) and min1(2) and min1(1)); 
		 tempsegm1(3) <= (not(min1(3)) and min1(2) and not(min1(1)) and not(min1(0))) or 
		     (not(min1(3)) and not(min1(2)) and not(min1(1)) and min1(0)) or
		     (min1(2) and min1(1) and min1(0)) or
		     (min1(3) and not(min1(2)) and min1(1) and not(min1(0))); 
		 tempsegm1(4) <= (not(min1(3)) and min1(2) and not(min1(1)) and not(min1(0))) or 
			  (not(min1(3)) and min1(0)) or
			  (min1(3) and not(min1(2)) and not(min1(1)) and min1(0)); 
		 tempsegm1(5)<= (not(min1(3)) and not(min1(2)) and not(min1(1)) and min1(0)) or
		     (not(min1(3)) and not(min1(2)) and min1(1) and not(min1(0))) or
		     (not(min1(3)) and min1(1) and min1(0)) or 
		     (min1(3) and min1(2) and not(min1(1)) and min1(0)); 
		 tempsegm1(6) <= (not(min1(3) or min1(2) or min1(1))) or
		     (not(min1(3)) and min1(2) and min1(1) and min1(0)) or
		    (min1(3) and min1(2) and not(min1(1)) and not(min1(0)));
		
	end process;	
	
process (clock_7segment)
	variable state : integer := 0;
	begin
	if(clock_7segment'event and clock_7segment = '1') then
		if(state =0) then
			seg <= tempsegm2;
			dp<=dp_value(0);
			an <= "1110";
			state := state+1;
		elsif (state =1) then
			seg <=  tempsegm1;
			dp<=dp_value(1);
			an <= "1101";
			state := state+1;
		elsif (state =2) then
			seg <=  tempsegs2;
			dp<=dp_value(2);
			an <= "1011";
			state := state+1;
		elsif (state =3) then
			seg <=  tempsegs1;
			dp<=dp_value(3);
			an <= "0111";
			state := state+1;
		else
			state := 0;
		end if;	
		end if;
	end process;
	
end behavior;