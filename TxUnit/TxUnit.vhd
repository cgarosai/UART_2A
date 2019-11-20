library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is

type t_etat is (IDLE, CHARGER_REGISTRE, ENVOI_START, 
					ENVOI_DATA, ENVOI_PAIRE, ENVOI_STOP);  
					
signal etat : t_etat;


begin

process(clk)
variable buf : std_logic_vector(7 downto 0);
variable reg : std_logic_vector(7 downto 0);
begin
	if(reset = '0') then
		etat <= IDLE;
		bufE <= '1';
		regE <= '1';
		
	elsif(rising_edge(clk)) then
		
		case etat is
		when IDLE => 
			bufE <= '1';
			regE <= '1';
			if(enable = '1' and ld = '1') then 
				etat <= CHARGER_REGISTRE;
				bufE <= '0';
				buf <= data;
			end if;
		
		when CHARGER_REGISTRE => 
			if(ld = 0 and enable = '1') then
				bufE = '1';
				regE = '0';
				reg <= buf;
				etat <= ENVOI_START;
			end if;
			
		end case;
	end if;
end process;
end behavorial;
