library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity partial_gen is
    port(
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        P0 : out std_logic_vector(31 downto 0);
        P1 : out std_logic_vector(31 downto 0);
        P2 : out std_logic_vector(31 downto 0);
        P3 : out std_logic_vector(31 downto 0);
        P4 : out std_logic_vector(31 downto 0);
        P5 : out std_logic_vector(31 downto 0);
        P6 : out std_logic_vector(31 downto 0);
        P7 : out std_logic_vector(31 downto 0);
        P8 : out std_logic_vector(31 downto 0)
    );
end partial_gen;

architecture BEHAVIORAL of partial_gen is

begin

    P0 <= (others => '0') when (not(B(0 downto 0) xor '0') and not(B(1 downto 1) xor B(0 downto 0))) = '1' else 
        "000000000000" & not(B(1 downto 1)) & B(1 downto 1) & B(1 downto 1) & '0' & A when (B(0 downto 0) xor '0') = '1' else -- +A
        "000000000000" & not(B(1 downto 1)) & B(1 downto 1) & B(1 downto 1) & A & '0'; -- +2A

    P1 <= "00000000000" & '1' & not(B(1 downto 1)) & "00000000000000000" & '0' & '0' when (not(B(2 downto 2) xor B(1 downto 1)) and not(B(3 downto 3) xor B(2 downto 2))) = '1' else 
          "00000000000" & '1' & not(B(1 downto 1)) & '0' & A & '0' & '0' when (B(2 downto 2) xor B(1 downto 1)) = '1' else -- +-A
          "00000000000" & '1' & not(B(1 downto 1)) & A & "00" & '0'; -- +-2A
    
    P2 <= "000000000" & '1' & not(B(3 downto 3)) & "00000000000000000" & '0' & B(1 downto 1) & "00" when (not(B(4 downto 4) xor B(3 downto 3)) and not(B(5 downto 5) xor B(4 downto 4))) = '1' else 
        "000000000" & '1' & not(B(3 downto 3)) & '0' & A & '0' & B(1 downto 1) & "00" when (B(4 downto 4) xor B(3 downto 3)) = '1' else -- +-A
        "000000000" & '1' & not(B(3 downto 3)) & A & "00" & B(1 downto 1) & "00"; -- +-2A
    
    P3 <= "0000000" & '1' & not(B(5 downto 5)) & "00000000000000000" & '0' & B(3 downto 3) & "0000" when (not(B(6 downto 6) xor B(5 downto 5)) and not(B(7 downto 7) xor B(6 downto 6))) = '1' else 
        "0000000" & '1' & not(B(5 downto 5)) & '0' & A & '0' & B(3 downto 3) & "0000" when (B(6 downto 6) xor B(5 downto 5)) = '1' else -- +-A
        "0000000" & '1' & not(B(5 downto 5)) & A & "00" & B(3 downto 3) & "0000"; -- +-2A

    P4 <= "00000" & '1' & not(B(7 downto 7)) & "00000000000000000" & '0' & B(5 downto 5) & "000000" when (not(B(8 downto 8) xor B(7 downto 7)) and not(B(9 downto 9) xor B(8 downto 8))) = '1' else 
        "00000" & '1' & not(B(7 downto 7)) & '0' & A & '0' & B(5 downto 5) & "000000" when (B(8 downto 8) xor B(7 downto 7)) = '1' else -- +-A
        "00000" & '1' & not(B(7 downto 7)) & A & "00" & B(5 downto 5) & "000000"; -- +-2A

    P5 <= "000" & '1' & not(B(9 downto 9)) & "00000000000000000" & '0' & B(7 downto 7) & "00000000" when (not(B(10 downto 10) xor B(9 downto 9)) and not(B(11 downto 11) xor B(10 downto 10))) = '1' else 
        "000" & '1' & not(B(9 downto 9)) & '0' & A & '0' & B(7 downto 7) & "00000000" when (B(10 downto 10) xor B(9 downto 9)) = '1' else -- +-A
        "000" & '1' & not(B(9 downto 9)) & A & "00" & B(7 downto 7) & "00000000"; -- +-2A
    
    P6 <= "0" & '1' & not(B(11 downto 11)) & "00000000000000000" & '0' & B(9 downto 9) & "0000000000" when (not(B(12 downto 12) xor B(11 downto 11)) and not(B(13 downto 13) xor B(12 downto 12))) = '1' else 
        "0" & '1' & not(B(11 downto 11)) & '0' & A & '0' & B(9 downto 9) & "0000000000" when (B(12 downto 12) xor B(11 downto 11)) = '1' else -- +-A
        "0" & '1' & not(B(11 downto 11)) & A & "00" & B(9 downto 9) & "0000000000"; -- +-2A
    
    P7 <= not(B(13 downto 13)) & "00000000000000000" & '0' & B(11 downto 11) & "000000000000" when (not(B(14 downto 14) xor B(13 downto 13)) and not(B(15 downto 15) xor B(14 downto 14))) = '1' else 
        not(B(13 downto 13)) & '0' & A & '0' & B(11 downto 11) & "000000000000" when (B(14 downto 14) xor B(13 downto 13)) = '1' else -- +-A
        not(B(13 downto 13)) & A & "00" & B(11 downto 11) & "000000000000"; -- +-2A

    P8 <= "0000000000000000" & '0' & B(13 downto 13) & "00000000000000" when (not('0' xor B(15 downto 15))) = '1' else 
        A & '0' & B(13 downto 13) & "00000000000000"; -- +-A

end BEHAVIORAL;