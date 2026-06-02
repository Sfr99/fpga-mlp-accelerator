library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.weights_pkg.ALL;
use work.test_pkg.ALL;

entity tb_top is
end tb_top;

architecture sim of tb_top is
    signal clk, reset, start, done : std_logic := '0';
    signal inputs_flat : std_logic_vector(3199 downto 0);
    signal outputs_flat : std_logic_vector(255 downto 0);
    constant CLK_PERIOD : time := 10 ns;

    type expected_array is array(0 to 15) of integer;
    constant EXPECTED : expected_array := (
        -3758, 950, -101, -1906, -2877, -3016, -2842, -2849,
        -3053, 1819, 1400, 76, -4234, -2930, -3740, -594
    );
begin

    -- Aplanar TEST_INPUT a std_logic_vector
    gen_in: for i in 0 to 199 generate
        inputs_flat(i*16+15 downto i*16) <= std_logic_vector(TEST_INPUT(i));
    end generate;

    uut: entity work.mlp_top
        port map (
            clk => clk, reset => reset, start => start, done => done,
            inputs_flat => inputs_flat,
            outputs_flat => outputs_flat
        );

    clk <= not clk after CLK_PERIOD / 2;

    process
        variable errores : integer := 0;
        variable max_val : integer := -99999;
        variable max_idx : integer := 0;
        variable out_val : integer;
    begin
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD;

        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait until done = '1';
        wait for CLK_PERIOD;

        for n in 0 to 15 loop
            out_val := to_integer(signed(outputs_flat(n*16+15 downto n*16)));
            if out_val /= EXPECTED(n) then
                report "ERROR salida " & integer'image(n) &
                       ": obtenido " & integer'image(out_val) &
                       ", esperado " & integer'image(EXPECTED(n))
                       severity error;
                errores := errores + 1;
            end if;
            if out_val > max_val then
                max_val := out_val;
                max_idx := n;
            end if;
        end loop;

        if errores = 0 then
            report "FORWARD COMPLETO TEST OK - Clase predicha: " & integer'image(max_idx) severity note;
        else
            report "FALLOS: " & integer'image(errores) & " salidas" severity error;
        end if;

        wait;
    end process;
end sim;