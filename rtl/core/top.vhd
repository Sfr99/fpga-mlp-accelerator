library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.weights_pkg.ALL;

entity mlp_top is
    Port (
        clk          : in std_logic;
        reset        : in std_logic;
        start        : in std_logic;
        done         : out std_logic;
        inputs_flat  : in std_logic_vector(3199 downto 0);
        outputs_flat : out std_logic_vector(255 downto 0)
    );
end mlp_top;

architecture Behavioral of mlp_top is
    signal inputs_arr  : peso_array(0 to 199);
    signal outputs_arr : peso_array(0 to 15);

    signal capa_0_outputs : peso_array(0 to 31);
    signal capa_1_outputs : peso_array(0 to 15);
    signal capa_2_outputs : peso_array(0 to 15);
    signal done_capa_0, done_capa_1, done_capa_2 : std_logic;
begin

    gen_in: for i in 0 to 199 generate
        inputs_arr(i) <= signed(inputs_flat(i*16+15 downto i*16));
    end generate;

    gen_out: for i in 0 to 15 generate
        outputs_flat(i*16+15 downto i*16) <= std_logic_vector(outputs_arr(i));
    end generate;

    capa_0: entity work.capa
        generic map (NUM_ENTRADAS => 200, NUM_NEURONAS => 32, NUM_CICLOS => 40, NUM_MUL => 5, ULTIMA_CAPA => false)
        port map (
            clk => clk, reset => reset, start => start, done => done_capa_0,
            inputs => inputs_arr, weights => PESOS_0, bias => BIAS_0, outputs => capa_0_outputs
        );

    capa_1: entity work.capa
        generic map (NUM_ENTRADAS => 32, NUM_NEURONAS => 16, NUM_CICLOS => 16, NUM_MUL => 2, ULTIMA_CAPA => false)
        port map (
            clk => clk, reset => reset, start => done_capa_0, done => done_capa_1,
            inputs => capa_0_outputs, weights => PESOS_1, bias => BIAS_1, outputs => capa_1_outputs
        );

    capa_2: entity work.capa
        generic map (NUM_ENTRADAS => 16, NUM_NEURONAS => 16, NUM_CICLOS => 8, NUM_MUL => 2, ULTIMA_CAPA => true)
        port map (
            clk => clk, reset => reset, start => done_capa_1, done => done_capa_2,
            inputs => capa_1_outputs, weights => PESOS_2, bias => BIAS_2, outputs => capa_2_outputs
        );

    outputs_arr <= capa_2_outputs;
    done <= done_capa_2;
end Behavioral;