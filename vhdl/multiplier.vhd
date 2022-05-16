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
    --signal a0, a1, a2, a3, a4, a5, a6, a7, B1 : unsigned(15 downto 0) := (others => '0');
    signal a0, a1, a2, a3, a4, a5, a6, a7 : unsigned(9 downto 0) := (others => '0');
    signal b0, b1, b2, b3 : unsigned(11 downto 0) := (others => '0');
    signal c0, c1 : unsigned(15 downto 0);
begin
------------------------------------------------------------------------
--B1(7 downto 0) <= B;
--a0 <= B1 when A(0) = '1' else (others => '0');
--a1 <= shift_left(B1, 1) when A(1) = '1' else (others => '0');
--a2 <= shift_left(B1, 2) when A(2) = '1' else (others => '0');
--a3 <= shift_left(B1, 3) when A(3) = '1' else (others => '0');
--a4 <= shift_left(B1, 4) when A(4) = '1' else (others => '0');
--a5 <= shift_left(B1, 5) when A(5) = '1' else (others => '0');
--a6 <= shift_left(B1, 6) when A(6) = '1' else (others => '0');
--a7 <= shift_left(B1, 7) when A(7) = '1' else (others => '0');
------------------------------------------------------------------------
--a0 <= "00000000"& B when A(0) = '1' else (others => '0');
--a1 <= "0000000" & B & '0' when A(1) = '1' else (others => '0');
--a2 <= "000000" & B & "00" when A(2) = '1' else (others => '0');
--a3 <= "00000" & B & "000" when A(3) = '1' else (others => '0');
--a4 <= "0000" & B & "0000" when A(4) = '1' else (others => '0');
--a5 <= "000" & B & "00000" when A(5) = '1' else (others => '0');
--a6 <= "00" & B & "000000" when A(6) = '1' else (others => '0');
--a7 <= "0" & B & "0000000" when A(7) = '1' else (others => '0');
--
--P <= a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;
------------------------------------------------------------------------
a0 <= ("00" & B) when A(0) = '1' else (others => '0');
a1 <= ("0" & B & "0") when A(1) = '1' else (others => '0');
a2 <= ("00" & B) when A(2) = '1' else (others => '0');
a3 <= ("0" & B & "0") when A(3) = '1' else (others => '0');
a4 <= ("00" & B) when A(4) = '1' else (others => '0');
a5 <= ("0" & B & "0") when A(5) = '1' else (others => '0');
a6 <= ("00" & B) when A(6) = '1' else (others => '0');
a7 <= ("0" & B & "0") when A(7) = '1' else (others => '0');

b0 <= "00" & (a0 + a1);
b1 <= (a2 + a3) & "00";
b2 <= "00" & (a4 + a5);
b3 <= (a6 + a7) & "00";

c0 <= "0000" & (b0 + b1);
c1 <= (b2 + b3) & "0000";

P <= C0 + C1;

------------------------------------------------------------------------

--process(A,B)
--variable result : unsigned(15 downto 0) := (others => '0');
--variable tmp : unsigned(15 downto 0) := (others => '0');
--begin
--for i in 0 to 7 loop
--    if(A(i) = '1') then
--        tmp(15 downto 8) := (others => '0');
--        tmp(7 downto 0) := B;
--        result := result + (shift_left(tmp, i));
--    end if;
--end loop;
--P <= result;
--result := (others => '0');    
--end process;
  
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

    signal out1, out2, out3, out4 : unsigned(15 downto 0) := (others => '0');
    --signal out12, out22, out32, out42 : unsigned(31 downto 0) := (others => '0');

begin
    a1 : multiplier port map( A => A(7 downto 0), B => B(7 downto 0), P => out1);
    a2 : multiplier port map( A => A(15 downto 8), B => B(7 downto 0), P => out2);
    a3 : multiplier port map( A => A(7 downto 0), B => B(15 downto 8), P => out3);
    a4 : multiplier port map( A => A(15 downto 8), B => B(15 downto 8), P => out4);
    P <= ("0000000000000000" & out1) + ("00000000" & out2 & "00000000") + ("00000000" & out3 & "00000000") + (out4 & "0000000000000000");
    --out12(15 downto 0) <= out1;
    --out22(15 downto 0) <= out2;
    --out32(15 downto 0) <= out3;
    --out42(15 downto 0) <= out4;
    --P <= out12 + shift_left(out22, 8) + shift_left(out32, 8) + shift_left(out42, 16);
    
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

    signal a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : unsigned(17 downto 0) := (others => '0');
    signal b0_n, b0_c, b1_n, b1_c, b2_n, b2_c, b3_n, b3_c, b4_n, b4_c, b5_n, b5_c, b6_n, b6_c, b7_n, b7_c : unsigned(19 downto 0) := (others => '0');
    signal c0, c1, c2, c3 : unsigned(23 downto 0);
    signal d0, d1 : unsigned( 31 downto 0);

begin
    a0 <= ("00" & B) when A(0) = '1' else (others => '0');
    a1 <= ("0" & B & "0") when A(1) = '1' else (others => '0');
    a2 <= ("00" & B) when A(2) = '1' else (others => '0');
    a3 <= ("0" & B & "0") when A(3) = '1' else (others => '0');
    a4 <= ("00" & B) when A(4) = '1' else (others => '0');
    a5 <= ("0" & B & "0") when A(5) = '1' else (others => '0');
    a6 <= ("00" & B) when A(6) = '1' else (others => '0');
    a7 <= ("0" & B & "0") when A(7) = '1' else (others => '0');
    a8 <= ("00" & B) when A(8) = '1' else (others => '0');
    a9 <= ("0" & B & "0") when A(9) = '1' else (others => '0');
    a10 <= ("00" & B) when A(10) = '1' else (others => '0');
    a11 <= ("0" & B & "0") when A(11) = '1' else (others => '0');
    a12 <= ("00" & B) when A(12) = '1' else (others => '0');
    a13 <= ("0" & B & "0") when A(13) = '1' else (others => '0');
    a14 <= ("00" & B) when A(14) = '1' else (others => '0');
    a15 <= ("0" & B & "0") when A(15) = '1' else (others => '0');
    

    b0_n <= "00" & (a0 + a1);
    b1_n <= (a2 + a3) & "00";
    b2_n <= "00" & (a4 + a5);
    b3_n <= (a6 + a7) & "00";
    b4_n <= "00" & (a8 + a9);
    b5_n <= (a10 + a11) & "00";
    b6_n <= "00" & (a12 + a13);
    b7_n <= (a14 + a15) & "00";

    c0 <= "0000" & (b0 + b1);
    c1 <= (b2 + b3) & "0000";
    c2 <= "0000" & (b4 + b5);
    c3 <= (b6 + b7) & "0000";

    d0 <= "00000000" & (c0 + c1);
    d1 <= (c2 + c3) & "00000000";

    P <= d0 + d1;

    process(clk, reset_n)
    begin
    if(reset_n = '0') then
        b0_c <= (others => '0');
        b1_c <= (others => '0');
        b2_c <= (others => '0');
        b3_c <= (others => '0');
        b4_c <= (others => '0');
        b5_c <= (others => '0');
        b6_c <= (others => '0');
        b7_c <= (others => '0');
    else
        if(rising_edge(clk)) then
            b0_c <= b0_n;
            b1_c <= b1_n;
            b2_c <= b2_n;
            b3_c <= b3_n;
            b4_c <= b4_n;
            b5_c <= b5_n;
            b6_c <= b6_n;
            b7_c <= b7_n;    
        end if;
    end if;
    end process;
end pipeline;
