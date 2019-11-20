library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 generic(facteur : natural);
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is

begin
process(clk)
	variable cpt : natural := 0;
begin
	if(reset = '0') then
		cpt := 0;
		enableTX <= '0';
	elsif(rising_edge(clk)) then
		cpt := cpt + 1;
		if(cpt = facteur) then
			enableTX  <= '1';
			cpt := 0;
		else			
			enableTX <= '0';
		end if;
		enableRX <= '1';
	elsif(falling_edge(clk)) then 
		enableRX <= '1'; 
	end if;
end process;
end behavorial;
