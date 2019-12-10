library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART_FPGA_N4 is
  port (
    
    -- horloge
    mclk : in std_logic;
    -- les 5 boutons noirs
    btnC : in std_logic;
   -- le switchs pour reset
    -- swt : in std_logic;
	 
	 RXD : in std_logic;
	 TXD : out std_logic
  );
  
end UART_FPGA_N4;

architecture synthesis of UART_FPGA_N4 is

	COMPONENT UARTunit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cs : IN std_logic;
		rd : IN std_logic;
		wr : IN std_logic;
		RxD : IN std_logic;
		addr : IN std_logic_vector(1 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		TxD : OUT std_logic;
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT diviseurClk
	generic (facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;

	COMPONENT echoUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		IntR : IN std_logic;
		IntT : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);          
		cs : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		addr : OUT std_logic_vector(1 downto 0);
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
  
  signal nclk, cs, rd, wr, IntT, IntR : std_logic;
  signal d1, d2 : std_logic_vector (7 downto 0);
  signal addr : std_logic_vector (1 downto 0);
begin

  -- valeurs des sorties (à modifier)
	Inst_UARTunit: UARTunit PORT MAP(
		clk => nclk,
		reset => btnC,
		cs => cs,
		rd => rd,
		wr => wr,
		RxD => RXD,
		TxD => TXD,
		IntR => intR,
		IntT => intT,
		addr => addr,
		data_in => d2,
		data_out => d1
	);
	
	Inst_diviseurClk: diviseurClk 
	generic map (645)
	PORT MAP(	
		clk => mclk,
		reset => btnC,
		nclk => nclk
	);
	
	Inst_echoUnit: echoUnit PORT MAP(
		clk => nclk,
		reset => btnC,
		cs => cs,
		rd => rd,
		wr => wr,
		IntR => intR,
		IntT => intT,
		addr => addr,
		data_in => d1,
		data_out => d2
	);
 
end synthesis;
