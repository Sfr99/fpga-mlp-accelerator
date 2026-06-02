library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.weights_pkg.ALL;

entity capa is
    generic (
        NUM_ENTRADAS : integer := 200;
        NUM_NEURONAS : integer := 32;
        NUM_CICLOS : integer := 34;
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
    signal i0, i1, i2, i3, i4, i5 : signed(15 downto 0);
    
    type peso_6 is array(0 to NUM_NEURONAS-1) of signed(15 downto 0);
    signal w0, w1, w2, w3, w4, w5 : peso_6;
    
    signal start_neuronas : std_logic;
    signal done_neuronas : std_logic_vector(NUM_NEURONAS-1 downto 0);
    signal counter : integer range 0 to NUM_CICLOS := NUM_CICLOS;
    
    signal salida_raw : peso_array(0 to NUM_NEURONAS-1);

begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= NUM_CICLOS;
            start_neuronas <= '0';
        elsif rising_edge(clk) then
            if start = '1' then        
                counter <= 0;
                start_neuronas <= '1';
            elsif counter < NUM_CICLOS then
                start_neuronas <= '0';                
                if counter * 6 + 5 < NUM_ENTRADAS then
                    i0 <= inputs(counter * 6 + 0);
                    i1 <= inputs(counter * 6 + 1);
                    i2 <= inputs(counter * 6 + 2);
                    i3 <= inputs(counter * 6 + 3);
                    i4 <= inputs(counter * 6 + 4);
                    i5 <= inputs(counter * 6 + 5);
                else
                    i0 <= inputs(counter * 6 + 0);
                    i1 <= inputs(counter * 6 + 1);
                    i2 <= (others => '0');
                    i3 <= (others => '0');
                    i4 <= (others => '0');
                    i5 <= (others => '0');
                end if;

                for n in 0 to NUM_NEURONAS - 1 loop
                    if counter * 6 + 5 < NUM_ENTRADAS then
                        w0(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 0);
                        w1(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 1);
                        w2(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 2);
                        w3(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 3);
                        w4(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 4);
                        w5(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 5);
                    else
                        w0(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 0);
                        w1(n) <= weights(n * NUM_ENTRADAS + counter * 6 + 1);
                        w2(n) <= (others => '0');
                        w3(n) <= (others => '0');
                        w4(n) <= (others => '0');
                        w5(n) <= (others => '0');
                    end if;
                end loop;
                
                counter <= counter + 1;
            end if;
        end if;
    end process;

    gen_neuronas: for n in 0 to NUM_NEURONAS-1 generate
        neurona_n: entity work.neurona
            generic map (NUM_CICLOS => NUM_CICLOS)
            port map (
                clk => clk, reset => reset,
                start => start_neuronas,
                weight_0 => w0(n), weight_1 => w1(n), weight_2 => w2(n), weight_3 => w3(n), weight_4 => w4(n), weight_5 => w5(n),
                input_0 => i0, input_1 => i1, input_2 => i2, input_3 => i3, input_4 => i4, input_5 => i5,
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