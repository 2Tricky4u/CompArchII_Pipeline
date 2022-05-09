-- =============================================================================
-- ================================= multiplier ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        A, B : in  unsigned(7 downto 0);
        P    : out unsigned(15 downto 0)
    );
end multiplier;

architecture combinatorial of multiplier is
    signal a0 : unsigned(15 downto 0) := (others => '0');
    signal a1 : unsigned(15 downto 0) := (others => '0');
    signal a2 : unsigned(15 downto 0) := (others => '0');
    signal a3 : unsigned(15 downto 0) := (others => '0');
    signal a4 : unsigned(15 downto 0) := (others => '0');
    signal a5 : unsigned(15 downto 0) := (others => '0');
    signal a6 : unsigned(15 downto 0) := (others => '0');
    signal a7 : unsigned(15 downto 0) := (others => '0');
    signal result : unsigned(15 downto 0) := (others => '0');
    signal B1 : unsigned(15 downto 0);
begin
--process(A,B)
--variable result : unsigned(15 downto 0) := (others => '0');
--begin
--for i in 0 to 7 loop
--    if(A(i) = '1') then
--    result := result + (shift_left(B, i));
--    end if;
--end loop;
--P <= result;    
--end process; 
B1(15 downto 8) <= "00000000" ;
B1(7 downto 0) <= B;
a0 <= B1 when A(0) = '1' else (others => '0');
a1 <= shift_left(B1, 1) when A(1) = '1' else (others => '0');
a2 <= shift_left(B1, 2) when A(2) = '1' else (others => '0');
a3 <= shift_left(B1, 3) when A(3) = '1' else (others => '0');
a4 <= shift_left(B1, 4) when A(4) = '1' else (others => '0');
a5 <= shift_left(B1, 5) when A(5) = '1' else (others => '0');
a6 <= shift_left(B1, 6) when A(6) = '1' else (others => '0');
a7 <= shift_left(B1, 7) when A(7) = '1' else (others => '0');

result <= a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;

P <= result;
  
end combinatorial;

-- =============================================================================
-- =============================== multiplier16 ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16 is
    port(
        A, B : in  unsigned(15 downto 0);
        P    : out unsigned(31 downto 0)
    );
end multiplier16;

architecture combinatorial of multiplier16 is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

begin
end combinatorial;

-- =============================================================================
-- =========================== multiplier16_pipeline ===========================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16_pipeline is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        A, B    : in  unsigned(15 downto 0);
        P       : out unsigned(31 downto 0)
    );
end multiplier16_pipeline;

architecture pipeline of multiplier16_pipeline is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

begin
end pipeline;
