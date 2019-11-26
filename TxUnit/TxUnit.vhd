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
					ENVOI_DATA, ENVOI_PARITE, ENVOI_STOP);  
					
signal etat : t_etat;


begin

process(clk)
variable buf : std_logic_vector(7 downto 0);
variable reg : std_logic_vector(7 downto 0);
variable cpt : natural; 
variable bitP : std_logic; -- Bit de parité : Xor entre tous les bits de la transmission.
variable flagBufChange : std_logic := '0'; -- Flag si le buffer change en cours de transmission
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
			txd <= '1';
			if(enable = '1' and ld = '1') then 
				etat <= CHARGER_REGISTRE;
				bufE <= '0';
				buf := data;
			end if;
		
		when CHARGER_REGISTRE => 
			if(ld = '0' and enable = '1') then
				bufE <= '1';
				regE <= '0';
				reg := buf;
				etat <= ENVOI_START;
				flagBufChange := '0';
			end if;
			
		when ENVOI_START => 
			if(enable = '1') then
				etat <= ENVOI_DATA;
				txd <= '0';
				cpt := 8;
				bitP := '0';
				if(ld = '1') then 
					bufE <= '0';
					buf := data;
					flagBufChange := '1';
				end if;
			end if;
		
		when ENVOI_DATA => 
			if(enable = '1') then 
				cpt := cpt - 1;
				txd <= buf(cpt);
				bitP := bitP xor buf(cpt); -- Calcul du bit de parité en fonction du bit précédent.
				if(cpt = 0) then
					etat <= ENVOI_PARITE;
				end if;
				if(ld = '1') then 
					bufE <= '0';
					buf := data;
					flagBufChange := '1';
				end if;
			end if;
		
		when ENVOI_PARITE =>
			if(enable = '1') then
				etat <= ENVOI_STOP;
				txd <= bitP;
				if(ld = '1') then 
					bufE <= '0';
					buf := data;
					flagBufChange := '1';					
				end if;
			end if;
			
		when ENVOI_STOP =>
		if(enable = '1') then
			txd <= '1';
			regE <= '1';
			
			if(ld = '0') then 
				if (flagBufChange = '1') then
					etat <= CHARGER_REGISTRE;
				else 
					etat <= IDLE;
				end if;
			elsif(ld = '1') then
				etat <= CHARGER_REGISTRE;
				bufE <= '0';
				buf := data;
			end if;
		end if;
		end case;
	end if;
end process;
end behavorial;
