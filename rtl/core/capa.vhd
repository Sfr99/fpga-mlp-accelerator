library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.weights_pkg.ALL;

entity capa is
    generic (
        NUM_ENTRADAS : integer := 200;
        NUM_NEURONAS : integer := 32;
        NUM_CICLOS : integer := 100;
        NUM_MUL : integer := 2;
        ULTIMA_CAPA : boolean := false
    );
    Port (  
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        inputs : in peso_array(0 to NUM_ENTRADAS -1);
        weights : in peso_array(0 to NUM_NEURONAS * NUM_ENTRADAS -1);
        bias : in peso_array(0 to NUM_NEURONAS -1);
        outputs : out peso_array(0 to NUM_NEURONAS-1);
        done : out std_logic
    );
end capa;

architecture Behavioral of capa is
    -- vector con NUM_MUL inputs concatenados (16 bits cada uno)
    signal i_vec : signed(NUM_MUL*16 - 1 downto 0);
    
    -- array de NUM_NEURONAS vectores de pesos (un vector por neurona, NUM_MUL pesos por vector)
    type peso_n is array(0 to NUM_NEURONAS-1) of signed(NUM_MUL*16 - 1 downto 0);
    signal w_arr : peso_n;
    
    signal start_neuronas : std_logic;
    signal done_neuronas : std_logic_vector(NUM_NEURONAS-1 downto 0);
    signal counter : integer range 0 to NUM_CICLOS := NUM_CICLOS;
    
    signal salida_raw : peso_array(0 to NUM_NEURONAS-1);
    signal start_prev : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= NUM_CICLOS;
                start_neuronas <= '0';
                start_prev <= '0';
            elsif start = '1' and start_prev = '0' then        
                counter <= 0;
                start_neuronas <= '1';
            elsif counter < NUM_CICLOS then
                start_neuronas <= '0';
                
                -- Empaquetar NUM_MUL inputs del ciclo en i_vec
                for k in 0 to NUM_MUL - 1 loop
                    i_vec((k+1)*16 - 1 downto k*16) <= inputs(counter * NUM_MUL + k);
                end loop;

                -- Para cada neurona, empaquetar sus NUM_MUL pesos del ciclo
                for n in 0 to NUM_NEURONAS - 1 loop
                    for k in 0 to NUM_MUL - 1 loop
                        w_arr(n)((k+1)*16 - 1 downto k*16) <= weights(n * NUM_ENTRADAS + counter * NUM_MUL + k);
                    end loop;
                end loop;
                
                counter <= counter + 1;
            end if;
            start_prev <= start;
        end if;
    end process;

    gen_neuronas: for n in 0 to NUM_NEURONAS-1 generate
        neurona_n: entity work.neurona
            generic map (NUM_CICLOS => NUM_CICLOS, NUM_MUL => NUM_MUL)
            port map (
                clk => clk, reset => reset,
                start => start_neuronas,
                weights => w_arr(n),
                inputs => i_vec,
                bias => bias(n),
                output => salida_raw(n),
                done => done_neuronas(n)
            );
    end generate;

    gen_relu: for n in 0 to NUM_NEURONAS-1 generate
        con_relu: if not ULTIMA_CAPA generate
            outputs(n) <= salida_raw(n) when salida_raw(n) > 0 else (others => '0');
        end generate;
        sin_relu: if ULTIMA_CAPA generate
            outputs(n) <= salida_raw(n);
        end generate;
    end generate;

    done <= done_neuronas(0);

end Behavioral;