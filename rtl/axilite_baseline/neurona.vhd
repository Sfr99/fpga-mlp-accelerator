library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neurona is
    generic (
        NUM_CICLOS : integer := 34
    );
    Port (  clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            weight_0 : in signed(15 downto 0);
            weight_1 : in signed(15 downto 0);
            weight_2 : in signed(15 downto 0);
            weight_3 : in signed(15 downto 0);
            weight_4 : in signed(15 downto 0);
            weight_5 : in signed(15 downto 0);
            input_0 : in signed(15 downto 0);
            input_1 : in signed(15 downto 0);
            input_2 : in signed(15 downto 0);
            input_3 : in signed(15 downto 0);
            input_4 : in signed(15 downto 0);
            input_5 : in signed(15 downto 0);
            bias : in signed(15 downto 0);
            output : out signed(15 downto 0);
            done : out std_logic);
end neurona;

architecture Behavioral of neurona is
begin
    process(clk, reset)
        variable sum_0, sum_1, sum_2, sum_3, sum_4 : signed(31 downto 0);
        variable mul_0, mul_1, mul_2, mul_3, mul_4, mul_5 : signed(31 downto 0);
        variable acum  : signed(47 downto 0);
        variable cycle_counter : integer := NUM_CICLOS + 1;
    begin
        if reset = '1' then
            output <= (others => '0');
            done <= '0';
            cycle_counter := NUM_CICLOS + 1;
        elsif rising_edge(clk) then
            if start = '1' then
              done <= '0';
              cycle_counter := 0;
              acum := shift_left(resize(bias, 48), 8); 
            elsif cycle_counter < NUM_CICLOS then
                mul_0 := input_0 * weight_0;
                mul_1 := input_1 * weight_1;
                mul_2 := input_2 * weight_2;
                mul_3 := input_3 * weight_3;
                mul_4 := input_4 * weight_4;
                mul_5 := input_5 * weight_5;
                sum_0 := mul_0 + mul_1;
                sum_1 := mul_2 + mul_3;
                sum_2 := mul_4 + mul_5;
                sum_3 := sum_0 + sum_1;
                sum_4 := sum_2 + sum_3; 
                acum := acum + resize(sum_4, 48); 

                cycle_counter := cycle_counter + 1;
            elsif cycle_counter = NUM_CICLOS then
                output <= acum(23 downto 8); 
                done <= '1';
                cycle_counter := cycle_counter + 1;
            else
                done <= '0';
            end if;
        end if;
    end process;
end Behavioral;
