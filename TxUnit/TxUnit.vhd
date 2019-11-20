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

end behavorial;
