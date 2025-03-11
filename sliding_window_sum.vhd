library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sliding_window_sum is
        Generic (
            WINDOW_SIZE : integer := 6
        );
        Port (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            init: IN STD_LOGIC;
            new_value_tvalid : IN STD_LOGIC;
            new_value_tready : OUT STD_LOGIC;
            new_value_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            output_tvalid : OUT STD_LOGIC;
            output_tready : IN STD_LOGIC;
            output_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
end sliding_window_sum;

architecture Behavioral of sliding_window_sum is

    type window_array_type is array (0 to WINDOW_SIZE-1) of STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal window : window_array_type := (others => x"40400000");
    signal ptr : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

    signal t1_tdata, t2_tdata, tout1_tdata : STD_LOGIC_VECTOR (31 downto 0);
    signal t1_tready, t2_tready, tout1_tready : STD_LOGIC;
    signal t1_tvalid, t2_tvalid, tout1_tvalid : STD_LOGIC;
    
    signal t3_tdata, t4_tdata, tout2_tdata : STD_LOGIC_VECTOR (31 downto 0);
    signal t3_tready, t4_tready, tout2_tready : STD_LOGIC;
    signal t3_tvalid, t4_tvalid, tout2_tvalid : STD_LOGIC;
    
    signal old_value_tvalid, old_value_tready : STD_LOGIC;
    signal old_value_tdata : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
    
    signal old_sum_tvalid, old_sum_tready : STD_LOGIC; 
    signal old_sum_tdata : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
    
    signal broadcaster_in_tvalid, broadcaster_in_tready : STD_LOGIC;
    signal broadcaster_in_tdata : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
   
    signal mux_tdata: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    signal mux_tvalid, mux_tready: STD_LOGIC := '0'; 

COMPONENT fp_adder
       PORT (
          aclk : IN STD_LOGIC;
          s_axis_a_tvalid : IN STD_LOGIC;
          s_axis_a_tready : OUT STD_LOGIC;
          s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          s_axis_b_tvalid : IN STD_LOGIC;
          s_axis_b_tready : OUT STD_LOGIC;
          s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          m_axis_result_tvalid : OUT STD_LOGIC;
          m_axis_result_tready : IN STD_LOGIC;
          m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT fifo32x64
        PORT (
          s_axis_aresetn : IN STD_LOGIC;
          s_axis_aclk : IN STD_LOGIC;
          s_axis_tvalid : IN STD_LOGIC;
          s_axis_tready : OUT STD_LOGIC;
          s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          m_axis_tvalid : OUT STD_LOGIC;
          m_axis_tready : IN STD_LOGIC;
          m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
        
      END COMPONENT;
      
      COMPONENT fp_subtractor
        PORT (
          aclk : IN STD_LOGIC;
          s_axis_a_tvalid : IN STD_LOGIC;
          s_axis_a_tready : OUT STD_LOGIC;
          s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          s_axis_b_tvalid : IN STD_LOGIC;
          s_axis_b_tready : OUT STD_LOGIC;
          s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          m_axis_result_tvalid : OUT STD_LOGIC;
          m_axis_result_tready : IN STD_LOGIC;
          m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
     END COMPONENT;

    COMPONENT axis_broadcaster
      PORT (
        aclk : IN STD_LOGIC;
        aresetn : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_tvalid : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axis_tready : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
      );
    END COMPONENT;

begin

new_valule_fifo : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => new_value_tdata,
        m_axis_tvalid => t1_tvalid,
        m_axis_tready => t1_tready,
        m_axis_tdata => t1_tdata
    ); 
    
    old_sum_fifo : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => mux_tvalid,
        s_axis_tready => broadcaster_in_tready,
        s_axis_tdata => mux_tdata,
        m_axis_tvalid => t2_tvalid,
        m_axis_tready => t2_tready,
        m_axis_tdata => t2_tdata
    ); 
    
    adder : fp_adder port map (
        aclk => aclk,
        s_axis_a_tvalid => t1_tvalid,
        s_axis_a_tready => t1_tready,
        s_axis_a_tdata => t1_tdata,
        s_axis_b_tvalid => t2_tvalid,
        s_axis_b_tready => t2_tready,
        s_axis_b_tdata => t2_tdata,
        m_axis_result_tvalid => tout1_tvalid,
        m_axis_result_tready => tout1_tready,
        m_axis_result_tdata => tout1_tdata
     );
     
     temp_sum_fifo : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => tout1_tvalid,
        s_axis_tready => tout1_tready,
        s_axis_tdata => tout1_tdata,
        m_axis_tvalid => t3_tvalid,
        m_axis_tready => t3_tready,
        m_axis_tdata => t3_tdata
    ); 
    
    subtractor : fp_subtractor port map (
        aclk => aclk,
        s_axis_a_tvalid => t3_tvalid,
        s_axis_a_tready => t3_tready,
        s_axis_a_tdata => t3_tdata,
        s_axis_b_tvalid => t4_tvalid,
        s_axis_b_tready => t4_tready,
        s_axis_b_tdata => t4_tdata,
        m_axis_result_tvalid => tout2_tvalid,
        m_axis_result_tready => tout2_tready,
        m_axis_result_tdata => tout2_tdata
    );
    
    output_fifo : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => tout2_tvalid,
        s_axis_tready => tout2_tready,
        s_axis_tdata => tout2_tdata,
        m_axis_tvalid => broadcaster_in_tvalid,
        m_axis_tready => broadcaster_in_tready,
        m_axis_tdata => broadcaster_in_tdata 
    );
    
    old_value_fifo : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => old_value_tvalid,
        s_axis_tready => old_value_tready,
        s_axis_tdata => old_value_tdata,
        m_axis_tvalid => t4_tvalid,
        m_axis_tready => t4_tready,
        m_axis_tdata => t4_tdata
    ); 
    

process(aclk, aresetn)
    begin
        old_value_tdata <= window(to_integer(unsigned(ptr)));
        if aresetn = '0' then
            window <= (others => x"00000000");
            ptr <= "000";
        elsif rising_edge(aclk) then
            old_value_tvalid <= '0';
            if t1_tvalid = '1' then
                window(to_integer(unsigned(ptr))) <= t1_tdata;
                old_value_tvalid <= '1';
                if to_integer(unsigned(ptr)) = (WINDOW_SIZE - 1) then
                    ptr <= "000";
                else
                    ptr <= ptr + 1;
                end if;
            end if;
        end if;
    end process;

    mux_tvalid <= broadcaster_in_tvalid when init = '0' else '1';
    mux_tdata <= broadcaster_in_tdata when init = '0' else x"00000000";
    output_tvalid <= broadcaster_in_tvalid;
    output_tdata <= broadcaster_in_tdata;
    
end Behavioral;
