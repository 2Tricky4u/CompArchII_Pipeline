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
    
    signal sel_curr, start_curr : std_logic;
    signal m1a, m1b : unsigned(7 downto 0);
    signal m1r_next, m1r_curr, a1r_next, a1r_curr, a2r, m2m_next, m2m_curr : unsigned(15 downto 0);
    signal a1a, a1atemp : unsigned(15 downto 0) := (others => '0');
    signal m2r, m3r, a3r : unsigned(31 downto 0);
begin
     --First multiplication
     m1a <= B when sel = '0' else A;
     m1b <= C when sel ='0' else A;
     c1 : multiplier port map ( A => m1a, B => m1b, P => m1r_next);
 
     --First addition
     a1atemp(7 downto 0) <= A;
     a1a <= a1atemp when sel = '0' else shift_left(a1atemp, 1);
     a1r_next <= a1a + B;
 
     --Second addition
     a2r <= m1r_next + a1r_next;
 
     --Second multiplication
     m2m_next <= a2r when sel = '0' else m1r_next;
     c2 : multiplier16 port map ( A => m1r_curr, B => m2m_curr, P => m2r);
 
     --Third multiplication
     c3 : multiplier16 port map ( A => a1r_curr, B => a1r_curr, P => m3r);
 
     --Third addition
     a3r <= m2r + m3r;
 
     --out
     D <= m2r when sel_curr = '0' else a3r;
     done <= start_curr ;

     --1st stage dff
    process(clk, reset_n, m1r_curr, m2m_curr, a1r_curr)
    begin
    if(reset_n = '0') then
        sel_curr <= '0';
        start_curr <= '0';
        m1r_curr <= (others => '0');
        m2m_curr <= (others => '0');
        a1r_curr <= (others => '0');
    else
        if(rising_edge(clk)) then
            sel_curr <= sel;
            start_curr <= start;
            m1r_curr <= m1r_next;
            m2m_curr <= m2m_next;
            a1r_curr <= a1r_next;
        end if;
    end if;
    end process;
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

    signal sel0, start0, sel1, start1: std_logic;
    signal m1a, m1b : unsigned(7 downto 0);
    signal m1r_next, m1r_curr, a1r_next, a1r_curr, a1r2_next, a1r2_curr, a2r, m2m : unsigned(15 downto 0);
    signal a1a, a1atemp : unsigned(15 downto 0) := (others => '0');
    signal m2r_next, m2r_curr, m3r, a3r : unsigned(31 downto 0);
begin
     --First multiplication
     m1a <= B when sel = '0' else A;
     m1b <= C when sel ='0' else A;
     c1 : multiplier port map ( A => m1a, B => m1b, P => m1r_next);
 
     --First addition
     a1atemp(7 downto 0) <= A;
     a1a <= a1atemp when sel = '0' else shift_left(a1atemp, 1);
     a1r_next <= a1a + B;
 
     --Second addition
     a2r <= m1r_curr + a1r_curr;
 
     --Second multiplication
     m2m <= a2r when sel0 = '0' else m1r_curr;
     c2 : multiplier16 port map ( A => m1r_curr, B => m2m, P => m2r_next);
 
     --Third multiplication
     c3 : multiplier16 port map ( A => a1r2_curr, B => a1r2_curr, P => m3r);
 
     --Third addition
     a3r <= m2r_curr + m3r;
 
     --out
     D <= m2r_curr when sel1 = '0' else a3r;
     done <= start1 ;

    --stages dff
    process(clk, reset_n)
    begin
    if(reset_n = '0') then
        sel0 <= '0';
        sel1 <= '0';
        start0 <= '0';
        start1 <= '0';
        m1r_curr <= (others => '0');
        m2r_curr <= (others => '0');
        a1r_curr <= (others => '0');
        a1r2_curr <= (others => '0');
    else
        if(rising_edge(clk)) then
            sel0 <= sel;
            sel1 <= sel0;
            start0 <= start;
            start1 <= start0;
            m1r_curr <= m1r_next;
            m2r_curr <= m2r_next;
            a1r_curr <= a1r_next;
            a1r2_curr <= a1r_curr;
        end if;
    end if;
    end process;
end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================
-- 2 tick sel in multiplier
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
    signal sel0, sel1, start0, start1 : std_logic;
    signal m1a, m1b : unsigned(7 downto 0);
    signal m1r_next, m1r_curr, a1r_next, a1r_curr, a2r, m2m : unsigned(15 downto 0);
    signal a1a, a1atemp : unsigned(15 downto 0) := (others => '0');
    signal m2r, m3r, a3r : unsigned(31 downto 0);
begin
     --First multiplication
     m1a <= B when sel = '0' else A;
     m1b <= C when sel ='0' else A;
     c1 : multiplier port map ( A => m1a, B => m1b, P => m1r_next);
 
     --First addition
     a1atemp(7 downto 0) <= A;
     a1a <= a1atemp when sel = '0' else shift_left(a1atemp, 1);
     a1r_next <= a1a + B;
 
     --Second addition
     a2r <= m1r_curr + a1r_curr;
 
     --Second multiplication
     m2m <= a2r when sel0 = '0' else m1r_curr;
     c2 : multiplier16_pipeline port map (clk => clk, reset_n => reset_n, A => m1r_curr, B => m2m, P => m2r);
 
     --Third multiplication
     c3 : multiplier16_pipeline port map ( clk => clk, reset_n => reset_n, A => a1r_curr, B => a1r_curr, P => m3r);
 
     --Third addition
     a3r <= m2r + m3r;
 
     --out
     D <= m2r when sel1 = '0' else a3r;
     done <= start1 ;

     --1st stage dff
    process(clk, reset_n, m1r_curr, m2m, a1r_curr)
    begin
    if(reset_n = '0') then
        sel0 <= '0';
        sel1 <= '0';
        start0 <= '0';
        start1 <= '0';
        m1r_curr <= (others => '0');
        a1r_curr <= (others => '0');
    else
        if(rising_edge(clk)) then
            sel0 <= sel;
            sel1 <= sel0;
            start0 <= start;
            start1 <= start0;
            m1r_curr <= m1r_next;
            a1r_curr <= a1r_next;
        end if;
    end if;
    end process;
end two_stage_pipeline_2;
