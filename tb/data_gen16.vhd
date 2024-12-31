library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity data_gen16 is  
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    D0    : out std_logic_vector(15 downto 0);
    D1    : out std_logic_vector(15 downto 0);
    D2    : out std_logic_vector(15 downto 0);
    VOUT  : out std_logic;
    END_SIM : out std_logic);
end entity data_gen16;

architecture beh of data_gen16 is

  constant tco : time := 1 ns;

  type tval_t is array (0 to 5) of std_logic_vector(15 downto 0);
  constant ctvalA : tval_t := (
    ('0' & conv_std_logic_vector(15+3, 5) & conv_std_logic_vector(7, 3) & conv_std_logic_vector(0, 10-3)),  --15
    ('0' & conv_std_logic_vector(15+7, 5) & conv_std_logic_vector(19, 5) & conv_std_logic_vector(0, 10-5)),  --204
    ('0' & conv_std_logic_vector(15+10, 5) & conv_std_logic_vector(0, 10)),  --1024
    ('1' & conv_std_logic_vector(15+3, 5) & conv_std_logic_vector(7, 3) & conv_std_logic_vector(0, 10-3)),  -- -15
    ('1' & conv_std_logic_vector(15+7, 5) & conv_std_logic_vector(19, 5) & conv_std_logic_vector(0, 10-5)),  -- -204
    ('1' & conv_std_logic_vector(15+10, 5) & conv_std_logic_vector(0, 10))   -- -1024
    );  

  constant ctvalB : tval_t := (
    ('0' & conv_std_logic_vector(15+7, 5) & conv_std_logic_vector(19, 5) & conv_std_logic_vector(0, 10-5)),  --204
    ('0' & conv_std_logic_vector(15+10, 5) & conv_std_logic_vector(0, 10)),  --1024
    ('1' & conv_std_logic_vector(15+3, 5) & conv_std_logic_vector(7, 3) & conv_std_logic_vector(0, 10-3)),  -- -15
    ('1' & conv_std_logic_vector(15+7, 5) & conv_std_logic_vector(19, 5) & conv_std_logic_vector(0, 10-5)),  -- -204
    ('1' & conv_std_logic_vector(15+10, 5) & conv_std_logic_vector(0, 10)),   -- -1024
    ('0' & conv_std_logic_vector(15+3, 5) & conv_std_logic_vector(7, 3) & conv_std_logic_vector(0, 10-3))   --15    
    );  
  
  signal cnt : integer := 0;
  signal sEnd_sim : std_logic;

  signal sEnd_sim_pipe : std_logic_vector(5 downto 0);
  
begin  -- architecture beh

  process (CLK, RST_n) is
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      cnt <= 0;  
      D0 <= (others => '0');
      D1 <= (others => '0');
      D2 <= (others => '0');
      VOUT <= '0';
      sEnd_sim <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (cnt < 6) then
        cnt <= cnt + 1 after tco;
        D0 <= ctvalA(cnt) after tco;
        D1 <= ctvalB(cnt) after tco;
        VOUT <= '1' after tco;
        sEnd_sim <= '0' after tco;          
      else
        VOUT <= '0' after tco;
        sEnd_sim <= '1' after tco;
      end if;
    end if;
  end process;

  process (CLK, RST_n) is
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      sEnd_sim_pipe <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      sEnd_sim_pipe(0) <= sEnd_sim after tco;
      sEnd_sim_pipe(5 downto 1) <= sEnd_sim_pipe(4 downto 0) after tco;
    end if;
  end process;

  END_SIM <= sEnd_sim_pipe(5);

end beh;
