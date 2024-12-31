library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.constants.all; 


--THIS IS THE TOP-LEVEL MODULE OF THE MULTIPLIER BASED ON THE BOOTH'S ALGORITHM
--IT IS A 16-BIT MULTIPLIER, WHERE EACH INPUT IS 16-BIT, WHILE THE OUTPUT IS CONSEQUENTLY ON 32.

--INTERNALLY, IT INSTANTIATES THE SUB MODULES :"MUX5to1", "ADDER"
--"ENCODER",WHICH ARE CONNECTED TOGETHER IN ORDER TO ACCOMPLISH THE ALGORITHM.

--THE ADDER MODULE IS THE ONE WE HAVE ALREADY DESIGNED CORRESPONDING 
--TO THE PENTIUM 4 ADDER BASED ON THE CLA CARRY GENERATOR AND THE
--CARRY SELECT SUM GENERATOR.ITS PARALLELISM IS HOWEVER 2*16 SINCE WE NEED TO
--ADD ALL THE PARTIAL SUMS THAT WILL,AT THE END,REPRESENT RESULT ON DOUBLE THE
--INPUT PARALLELISM

--THE MAIN APPROACH TO IMPLEMENT THE MULTIPLIER IS TO FIRSTLY GENERATE
--(HARDWIRED) ALL THE POSSIBLE NBIT SHIFTS OF THE "A" OPERAND, IN ORDER TO INCREASE
--THE SPEED OF THE SYSTEM AND PERFORM THE MULTIPLICATION IN A MORE "PARALLEL"
--WAY, AND ONLY SUM THE PARTIAL PRODUCT ONLY EVERY 2 CYCLES (RATHER THAN IN
--THE CASE OF THE ARRAY MULTIPLIER).
--WE ACCOMPLISH THE SHIFTS BY CREATING ARRAYS OF STD_LOGIC_VECTORS WHERE EACH
--ELEMENT IS THE SHIFTED VERSION OF THE PREVIOUS ELEMENT (A_POS AND A_NEG ARE
--RESPECTIVELY THE VECTOR CONTAININGS THE MULTIPLES OF A).

--IN TOTAL WE WILL USE NBIT/2 - 1 ADDERS, SINCE THE ADDER COMPLEXITY OF THE ALGORITHM IS
--LINEAR : #ADDERS = (NBIT / 2 ) - 1. (IN CASE OF 16 BITS AT THE INPUTS : WE
--WILL HAVE 16/2 - 1 = 7 ADDERS.

--TO AVOID VERY HIGH LATENCIES DUE TO THE CASCADE OF THE 7 ADDERS, A PIPELINED VERSION
--HAS BEEN DESIGNED INSTEAD, WITH A PIPELINE REGISTER TO STORE THE PARTIAL SUM EVERY 2 ADDERS.
--IN THIS CASE ONLY 3 REGISTERS ARE NEEDED AND THE OVERALL LATENCY IS 3 (4 CLOCK CYCLES BECAUSE THE ALU 
--HAS AN OUTPUT REGISTER CALLED ALR_OUT)
entity MUL is
	Port (	CLOCK : in std_logic;
          A:	In	std_logic_vector(15 downto 0);
          B:	In	std_logic_vector(15 downto 0);
		      Y:	Out	std_logic_vector(31 downto 0));
end MUL;

architecture BEHAVIORAL of MUL is


component REG is
  Generic (
      NBIT : integer := 32 -- default number of bits
  );
  Port (
      clk     : in std_logic;
      reset   : in std_logic;
      enable  : in std_logic;
      data_in : in std_logic_vector(NBIT-1 downto 0);
      data_out: out std_logic_vector(NBIT-1 downto 0)
  );
end component;

component ENCODER is
	Port (	INPUT:	In	std_logic_vector(2 downto 0);
		OUTPUT: Out	std_logic_vector(2 downto 0));
end component;

component ADDER is
  generic (NBIT: integer := 32;
           NBIT_PER_BLOCK: integer := 4);
  port (
         A: in std_logic_vector(NBIT-1 downto 0);
         B: in std_logic_vector(NBIT-1 downto 0);
         ADD_SUB: in std_logic; -- Bit to select addition/subtraction
         Cin: in std_logic; -- Transparent in addition, fixed to 1 in subtraction
         S: out std_logic_vector(NBIT-1 downto 0);
         Cout: out std_logic
         );
end component;

--declaration of the MUX 5 TO 1 MODULE
component MUX5to1 is
  Generic (NBIT: integer := 32);
  Port (
    A, B, C, D, E: in std_logic_vector(NBIT-1 downto 0);
    SEL: in std_logic_vector(2 downto 0);
    Y: out std_logic_vector(NBIT-1 downto 0)
  );
end component;

constant NBIT : integer := 16;
type signalVector is array(NBIT-1 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
type addervec is array((NBIT/2)-1 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
type regvec is array((NBIT/4) - 2 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
type pipe_1 is array((NBIT/4) - 1 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
type pipe_2 is array((NBIT/8) - 1 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);

signal zeros : std_logic_vector(2*NBIT - 1 downto 0) := (others => '0');
signal A_pos : signalVector; --array of std_logic_vectors to store POSITIVE SHIFTS
signal A_neg : signalVector; --array of std_logic_vectors to store NEGATIVE SHIFTS
signal addends : addervec;   --array to store the OUTPUTS OF THE MUXES
signal B_buff : std_logic_vector(NBIT downto 0);--VECTOR CONTAINING B & '0',NECESSARY FOR THE FIRST ENCODER
signal selector : std_logic_vector((NBIT/2)*3 -1 downto 0);--SELECTORS OF THE MUXES, THERE ARE 3 BITS EVERY 2 OF THE B FACTOR
signal cout_vec: std_logic_vector((NBIT/2) - 1 downto 0);--VECTOR CONTAINING THE USELESS CARRY OUT OF EACH ADDER
signal reg_in, reg_out, add_out: regvec;  --SIGNALS FOR THE INPUT-OUTPUT OF THE PIPELINE REGISTERS
signal mux_out : addervec;
signal pipe1 : pipe_1;    -- PIPELINE STAGE 1
signal pipe2 : pipe_2;    -- PIPELINE STAGE 2

begin

B_buff <= B & '0';
A_pos(0) <= (2*NBIT - 1 downto A'length => '0') & A;

--HARDWIRED SHIFTS

--shifting A left by 1 position each time, creating 0,A,2A,4A,8A .. up until (2^(NBIT-1))*A
shiftpos : for i in 1 to NBIT-1 generate
  A_pos(i) <= to_stdlogicvector(to_bitvector(A_pos(i-1)) sll 1);
end generate;

--shifting A left by 1 position each time, creating 0,-A,-2A,-4A,-8A .. up
--until -(2^(NBIT-1))*A
shiftneg : for i in 0 to NBIT-1 generate
  A_neg(i) <= std_logic_vector(-signed(A_pos(i)));
end generate;


addends(0) <= mux_out(0);
addends(1) <= mux_out(1);

SEL_CLOCK : process(CLOCK,mux_out)
begin
  if(CLOCK = '1' and CLOCK' event) then
      addends(2) <= mux_out(2);     --STAGE 1
      addends(3) <= mux_out(3);

      pipe1(3) <= mux_out(7);       --STAGE 2
      pipe1(2) <= mux_out(6);
      pipe1(1) <= mux_out(5);
      pipe1(0) <= mux_out(4);
      addends(5) <= pipe1(1);
      addends(4) <= pipe1(0);

      pipe2(1) <= pipe1(3);         --STAGE 3
      pipe2(0) <= pipe1(2);
      addends(7) <= pipe2(1);   
      addends(6) <= pipe2(0);                   
  end if;
end process;


--INSTANTIATION OF THE ELEMENTS AND ADDING UP
           
--SELECTORS OF THE MUXES
 
selectors : for i in 1 to NBIT/2 generate
  begin
    enc : encoder port map(B_buff((2*i) downto (2*(i-1))), selector((3*i)-1 downto (3*(i-1))));
  end generate;


--MULTIPLEXERS GENERATION
MUX_GEN : for i in 0 to (NBIT/2)-1 generate
  begin
    MUX_I : MUX5to1 generic map(2*NBIT) port map(zeros,A_pos(2*i),A_neg(2*i),A_pos((2*i)+1),A_neg((2*i)+1),selector(3*(i+1)-1 downto 3*i),mux_out(i));
  end generate;


--FIRST ADDER THAT IS DIFFERENT FROM THE OTHERS
ADD0 : ADDER generic map(2*NBIT,4) port map(A => addends(0),B => addends(1), ADD_SUB => '0', CIN => '0', S => reg_in(0), Cout => cout_vec(0));

--FIRST PIPELINE REGISTER THAT IS DIFFERENT FROM THE OTHERS
REG0 : REG generic map(2*NBIT)
    port map(clk => CLOCK, reset => '0', enable => '1', data_in => reg_in(0), data_out => reg_out(0));


--LOOP IN ORDER TO CREATE THE LAST 2 STAGES THAT COULD BE REPEATED
add : for i in 1 to (NBIT/4)-2 generate
  begin
    ADD_0i : ADDER generic map(2*NBIT,4) port map(A => reg_out(i-1), B => addends(2*i), ADD_SUB => '0', CIN => '0', S => add_out(i-1), Cout => cout_vec(i));
    ADD_1i : ADDER generic map(2*NBIT,4) port map(A => add_out(i-1), B => addends(2*i + 1), ADD_SUB => '0', CIN => '0', S => reg_in(i), Cout => cout_vec(i+1));
    REG_i : REG generic map(2*NBIT) port map(clk => CLOCK, reset => '0', enable => '1', data_in => reg_in(i), data_out => reg_out(i));
  end generate;

--PENULTIMATE ADDER
ADD_N_1 : ADDER generic map(2*NBIT,4) port map(A => reg_out((NBIT/4)-2),B => addends((NBIT/2)-2), ADD_SUB => '0', CIN => '0', S => add_out((NBIT/4)-2), Cout => cout_vec((NBIT/2)-2));

--LAST ADDER
ADD_N : ADDER generic map(2*NBIT,4) port map(A => add_out((NBIT/4)-2),B => addends((NBIT/2)-1), ADD_SUB => '0', CIN => '0', S => Y, Cout => cout_vec((NBIT/2)-1));


end BEHAVIORAL;