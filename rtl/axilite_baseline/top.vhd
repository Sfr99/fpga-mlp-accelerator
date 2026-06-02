library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.weights_pkg.ALL;
use work.test_pkg.ALL;

entity top is
    Port (
        clk     : in std_logic;
        reset   : in std_logic;
        start   : in std_logic;
        done    : out std_logic;
        inputs  : in peso_array(0 to 199);
        outputs : out peso_array(0 to 15)
    );
end top;

architecture Behavioral of top is
    signal capa_0_outputs : peso_array(0 to 31);
    signal capa_1_outputs : peso_array(0 to 15);
    signal capa_2_outputs : peso_array(0 to 15);
    signal done_capa_0, done_capa_1, done_capa_2 : std_logic;
begin
    -- capa 0
    capa_0: entity work.capa
        generic map (
            NUM_ENTRADAS => 200,
            NUM_NEURONAS => 32,
            NUM_CICLOS => 34,
            ULTIMA_CAPA => false
        )
        port map (
            clk => clk, reset => reset, start => start, done => done_capa_0,
            inputs => inputs,
            weights => PESOS_0,
            bias => BIAS_0,
            outputs => capa_0_outputs
        );
    
    -- capa 1
    capa_1: entity work.capa
        generic map (
            NUM_ENTRADAS => 32,
            NUM_NEURONAS => 16,
            NUM_CICLOS => 6,
            ULTIMA_CAPA => false
        )
        port map (
            clk => clk, reset => reset, start => done_capa_0, done => done_capa_1,
            inputs => capa_0_outputs,
            weights => PESOS_1,
            bias => BIAS_1,
            outputs => capa_1_outputs
        );

    -- capa 2
    capa_2: entity work.capa
        generic map (
            NUM_ENTRADAS => 16,
            NUM_NEURONAS => 16,
            NUM_CICLOS => 3,
            ULTIMA_CAPA => true
        )
        port map (
            clk => clk, reset => reset, start => done_capa_1, done => done_capa_2,
            inputs => capa_1_outputs,
            weights => PESOS_2,
            bias => BIAS_2,
            outputs => capa_2_outputs
        );
    
    outputs <= capa_2_outputs;
    done <= done_capa_2;
end Behavioral;