library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neurona is
    generic (
        NUM_CICLOS : integer := 100;
        NUM_MUL    : integer := 2
    );
    Port (  clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            weights : in signed(NUM_MUL*16 - 1 downto 0);
            inputs  : in signed(NUM_MUL*16 - 1 downto 0);
            bias : in signed(15 downto 0);
            output : out signed(15 downto 0);
            done : out std_logic);
end neurona;

architecture Behavioral of neurona is
begin
    process(clk)
        variable acum : signed(47 downto 0);
        variable suma_ciclo : signed(34 downto 0);
        variable mul_k : signed(31 downto 0);
        variable cycle_counter : integer := NUM_CICLOS + 1;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                output <= (others => '0');
                done <= '0';
                cycle_counter := NUM_CICLOS + 1;
            elsif start = '1' then
                done <= '0';
                cycle_counter := 0;
                acum := shift_left(resize(bias, 48), 8);
            elsif cycle_counter < NUM_CICLOS then
                suma_ciclo := (others => '0');
                for k in 0 to NUM_MUL - 1 loop
                    mul_k := inputs((k+1)*16 - 1 downto k*16) * weights((k+1)*16 - 1 downto k*16);
                    suma_ciclo := suma_ciclo + resize(mul_k, 35);
                end loop;
                acum := acum + resize(suma_ciclo, 48);
                cycle_counter := cycle_counter + 1;
            elsif cycle_counter = NUM_CICLOS then
                output <= acum(23 downto 8);
                done <= '1';
            end if;
        end if;
    end process;
end Behavioral;