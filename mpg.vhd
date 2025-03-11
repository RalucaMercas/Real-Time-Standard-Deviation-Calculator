library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity MPG is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           en : out  STD_LOGIC);
end MPG;

architecture Behavioral of mpg is

    signal qCounter: std_logic_vector(15 downto 0);
    signal q1, q2, q3: std_logic;

begin

en <= q2 and (not(q3));

    process(clk)
    begin
        if rising_edge(clk) then
            qCounter <= qCounter + 1;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (qCounter(15 downto 0)) = x"ffff" then
            q1 <= btn;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            q2 <= q1;
            q3 <= q2;
        end if;
    end process;

end Behavioral;
