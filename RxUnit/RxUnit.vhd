library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture behavorial of RxUnit is

signal tmpclk : std_logic; -- Signaux intermédiaires de clk et de rxd venant du Proc_cpt16 vers le Proc_ctrlReception
signal tmprxd : std_logic;
-- Etat du process cpt16
type t_etat_cpt is (Idle, cpt1, cpt2); 
-- Etat de base : Idle, quand Rxd passe à 0, on commence la réception (11 fois cpt1 et cpt2 pour réceptionner toute la trame)
-- Cpt1 : Première phase de comptage de 8 enable, on affcte tmpclk et tmprxd à la fin du comptage.
-- Cpt2 : Deuxième phase de comptage, si on a vu toute la trame passée à la fin de cette phase
-- on va soit retourné en idle, soit relancé la réception d'une trame avec cpt1.
signal etatCpt : t_etat_cpt;

begin

Proc_Cpt16 : process(enable)
variable cpt : natural; -- Permet de compter les fronts d'enable
variable cptTrame : natural; -- Permet de compter les bits reçut jusqu'à la fin d'une trame.
-- Taille d'une trame : 1 bit start + 8 bit donnée + 1 parité + 1 stop = 11 bits.
begin 
	if(reset = 0) then
		etatCpt <= Idle;
	elsif(rising_edge(enable)) then
		case etatCpt is 
		when Idle => 
			tmpclk <= 0;
			tmprxd <= 1;
			cpt := 8;
			cptTrame := 11;
			if(rxd = '0') then 
				etatCpt <= cpt1;
			end if;
			
		when cpt1 =>
			cpt := cpt - 1;
			if(cpt = 0) then 
				etatCpt <= cpt2;
				tmpclk <= '1';
				tmprxd <= rxd;
				cpt := 8;
			end if;
			
		when cpt2 =>
		if(tmpclk = '1') then -- On rabaisse le signal tmpclk. 
			tmpclk <= '0';
		end if;
		
		cpt := cpt - 1;
		
		if(cpt = 0) then -- Fin du comptage, on repasse à cpt1 en décrémenter le nombre de bits encore à recevoir.
			cptTrame := cptTrame - 1;
			etatCpt <= cpt1;
		end if;
		
		if(cptTrame = 0) then -- Si on a reçu toute la trame (11 bits)
			cptTrame := 11;
			if(rxd = '1') then -- On va soit retourner à Cpt1 si une autre transmission suit, c'est à dire 
				etatCpt <= Idle; -- si on recoit un autre bit de start (rxd = '0') dès la fin de la trame.
			end if; -- Ou si Rxd = '1', on va alors repasser en idle qui attendra la réception d'une future trame.
		end if; 
	end if;
end process;

Proc_ctrlReception : process(clk)

variable regRecep : std_logic_vector(10 downto 0); -- Le registre sauvegardant la réception des 11 bits d'une trame.
variable cptBit : natural; -- Numérotation du bit qui est en réception.

type t_etat_recep is (Idle, Reception); 

signal etatRecep : t_etat_cpt;

begin 
	if(reset = 0) then
		etatRecep <= Idle;
	elsif(rising_edge(clk)) then
		case etatRecep is 
		when Idle =>
			DRdy <= '0';
			Ferr <= '0';
			OErr <= '0';
			if(tmpclk = '1') then
				etatRecep <= Reception;
				cptBit := 11;
			end if;	
				
		when Reception =>
			if(tmpclk = '1') then 
				cptBit := cptBit - 1;
				regRecep(cptBit) := rxdtmp;
				-- Bit de poids fort ou faible en premier ???? 
				if(cptBit = 0) then 
				-- Verif des bits de stop/parité
				-- Envoi de la data si c'est bon.
				
	end if;
end process; 

end behavorial;
