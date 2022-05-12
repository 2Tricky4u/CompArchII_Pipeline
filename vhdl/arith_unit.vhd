library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_unit is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
    );
end arith_unit;

-- =============================================================================
-- =============================== COMBINATORIAL ===============================
-- =============================================================================

architecture combinatorial of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

    signal m1a, m1b : unsigned(7 downto 0);
    signal m1r, a1r, a2r, m2m : unsigned(15 downto 0);
    signal a1a, a1atemp : unsigned(15 downto 0) := (others => '0');
    signal m2r, m3r, a3r : unsigned(31 downto 0);
    
begin
    --First multiplication
    m1a <= B when sel = '0' else A;
    m1b <= C when sel ='0' else A;
    c1 : multiplier port map ( A => m1a, B => m1b, P => m1r);

    --First addition
    a1atemp(7 downto 0) <= A;
    a1a <= a1atemp when sel = '0' else shift_left(a1atemp, 1);
    a1r <= a1a + B;

    --Second addition
    a2r <= m1r + a1r;

    --Second multiplication
    m2m <= a2r when sel = '0' else m1r;
    c2 : multiplier16 port map ( A => m1r, B => m2m, P => m2r);

    --Third multiplication
    c3 : multiplier16 port map ( A => a1r, B => a1r, P => m3r);

    --Third addition
    a3r <= m2r + m3r;

    --out
    D <= m2r when sel = '0' else a3r;
    done <= start;
end combinatorial;

-- =============================================================================
-- ============================= 1 STAGE PIPELINE ==============================
-- =============================================================================

architecture one_stage_pipeline of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

    signal m1a, m1b : unsigned(7 downto 0);
    signal m1r, a1r, a2r, m2m : unsigned(15 downto 0);
    signal a1a, a1atemp : unsigned(15 downto 0) := (others => '0');
    signal m2r, m3r, a3r : unsigned(31 downto 0);
begin
     --First multiplication
     m1a <= B when sel = '0' else A;
     m1b <= C when sel ='0' else A;
     c1 : multiplier port map ( A => m1a, B => m1b, P => m1r);
 
     --First addition
     a1atemp(7 downto 0) <= A;
     a1a <= a1atemp when sel = '0' else shift_left(a1atemp, 1);
     a1r <= a1a + B;
 
     --Second addition
     a2r <= m1r + a1r;
 
     --Second multiplication
     m2m <= a2r when sel = '0' else m1r;
     c2 : multiplier16 port map ( A => m1r, B => m2m, P => m2r);
 
     --Third multiplication
     c3 : multiplier16 port map ( A => a1r, B => a1r, P => m3r);
 
     --Third addition
     a3r <= m2r + m3r;
 
     --out
     D <= m2r when sel = '0' else a3r;
     done <= start;
end one_stage_pipeline;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE I =============================
-- =============================================================================

architecture two_stage_pipeline_1 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================

architecture two_stage_pipeline_2 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16_pipeline
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            A, B    : in  unsigned(15 downto 0);
            P       : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_2;
