library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    FErr, OErr, DRdy : out std_logic);
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

type t_etat_recep is (Idle, Reception); 

signal etatRecep : t_etat_recep;

begin

Proc_Cpt16 : process(enable)
variable cpt : natural; -- Permet de compter les fronts d'enable
variable cptTrame : natural; -- Permet de compter les bits reçut jusqu'à la fin d'une trame.
-- Taille d'une trame : 1 bit start + 8 bit donnée + 1 parité + 1 stop = 11 bits.
begin 
	if(reset = '0') then
		etatCpt <= Idle;
	elsif(rising_edge(enable)) then
		case etatCpt is 
		when Idle => 
			tmpclk <= '0';
			tmprxd <= '1';
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
				cpt := 8;
			end if;
			
			if(cptTrame = 0) then -- Si on a reçu toute la trame (11 bits)
				cptTrame := 11;
				if(rxd = '1') then -- On va soit retourner à Cpt1 si une autre transmission suit, c'est à dire 
					etatCpt <= Idle; -- si on recoit un autre bit de start (rxd = '0') dès la fin de la trame.
				end if; -- Ou si Rxd = '1', on va alors repasser en idle qui attendra la réception d'une future trame.
			end if; 
		end case;
	end if;
end process;

Proc_ctrlReception : process(clk)

variable regRecep : std_logic_vector(10 downto 0); -- Le registre sauvegardant la réception des 11 bits d'une trame.
variable cptBit : natural; -- Numérotation du bit qui est en réception.
variable bitParite : std_logic;
variable DRdyInter : std_logic;
variable frontMontantEn : std_logic;
begin 
	if(reset = '0') then
		etatRecep <= Idle;
		DRdyInter := '0';
		DRdy <= '0';
		OErr <= '0';
		FErr <= '0';
	elsif(rising_edge(clk)) then
		case etatRecep is 
		when Idle =>
		
			if(DRdyInter = '1') then
				if(rd = '0') then 
					OErr <= '1';
					DRdy <= '0';
					DRdyInter := '0';
				end if;
			else 
				DRdy <= '0';
				OErr <= '0';
				FErr <= '0';
		
				if(tmpclk = '1') then
					etatRecep <= Reception;
					cptBit := 10;
					regRecep(cptBit) := tmprxd;
					frontMontantEn := '0';
				end if;	
			end if;

		when Reception =>
			if(tmpclk = '1' and frontMontantEn = '1') then 
				frontMontantEn := '0';
				cptBit := cptBit - 1;
				regRecep(cptBit) := tmprxd;
				
				if(cptBit = 0) then
				-- Verif des bits de stop/parité
				-- Envoi de la data si c'est bon.
					bitParite := '0';
					bitParite := regRecep(2) xor bitParite;
				   bitParite := regRecep(3) xor bitParite;
				   bitParite := regRecep(4) xor bitParite;
				   bitParite := regRecep(5) xor bitParite;
				   bitParite := regRecep(6) xor bitParite;
				   bitParite := regRecep(7) xor bitParite;
				   bitParite := regRecep(8) xor bitParite;
				   bitParite := regRecep(9) xor bitParite;
					if(not (bitParite = regRecep(1))) then
						FErr <= '1';
					elsif(regRecep(0) = '0') then
						FErr <= '1';
					else
						DRdy <= '1';
						DRdyInter := '1';
						data <= regRecep(9 downto 2);
					end if;
					etatRecep <= Idle;
				end if;
			elsif (tmpclk = '0') then frontMontantEn := '1'; 
			end if; 
		end case;
	end if;
end process; 

end behavorial;
