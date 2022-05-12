library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity function_tb is
end;

architecture bench of function_tb is
        signal clk     : std_logic;
        signal reset_n : std_logic := '1';
        signal start   : std_logic := '1';
        signal sel     : std_logic :='0';
        signal A, B, C : unsigned(7 downto 0);
        signal D       : unsigned(31 downto 0);
        signal done    : std_logic;

    component arith_unit is
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            start   : in  std_logic;
            sel     : in  std_logic;
            A, B, C : in  unsigned(7 downto 0);
            D       : out unsigned(31 downto 0);
            done    : out std_logic
        );
    end component;

begin
        f_0 : arith_unit port map(
            clk => clk,
            reset_n => reset_n,
            start => start,
            sel => sel,
            a => A,
            b => B,
            c => C,
            d => D,
            done => done
        );

    process
        variable err         : boolean := false;
        variable line_output : line;
    begin
        for i in 0 to 128 loop
            for j in 0 to 128 loop
                for k in 0 to 128 loop
                    A <= to_unsigned(i, 8);
                    B <= to_unsigned(j, 8);
                    C <= to_unsigned(k, 8);
                    wait for 5 ns;
                    if (D /= ((j*k) * (j*k + j + i)) and not err) then
                        err := true;
                        report "not matching!" severity ERROR;
                    end if;
                end loop;
            end loop;
        end loop;

        line_output := new string'("===================================================================");
        writeline(output, line_output);
        if (err) then
            line_output := new string'("Errors encountered during simulation.");
        else
            line_output := new string'("Simulation is successful");
        end if;
        writeline(output, line_output);
        line_output := new string'("===================================================================");
        writeline(output, line_output);

        wait;
    end process;

end bench;