
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity average_calculator is
        Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            init: IN STD_LOGIC;
            input_tvalid : in STD_LOGIC;
            input_tdata : in STD_LOGIC_VECTOR (31 downto 0);
            output_tready : in STD_LOGIC;
            input_tready : out STD_LOGIC;
            output_tvalid : out STD_LOGIC;
            output_tdata : out STD_LOGIC_VECTOR (31 downto 0)
        );
end average_calculator;

architecture Behavioral of average_calculator is

    component sliding_window_sum is
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
    end component sliding_window_sum;
    
    COMPONENT fp_divider
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
        
        signal sum_in_tdata, sum_out_tdata, avg_in_tdata : STD_LOGIC_VECTOR (31 downto 0);
        signal sum_in_tready, sum_out_tready, avg_in_tready : STD_LOGIC;
        signal sum_in_tvalid, sum_out_tvalid, avg_in_tvalid : STD_LOGIC;

begin

    sum_unit: sliding_window_sum
        Generic map (
            WINDOW_SIZE => 6
        )
        Port map (
            aclk => aclk,
            aresetn => aresetn,
            init => init,
            new_value_tvalid => input_tvalid,
            new_value_tready => input_tready,
            new_value_tdata => input_tdata,
            output_tvalid => sum_in_tvalid,
            output_tready => sum_in_tready,
            output_tdata => sum_in_tdata
        );

     fifo_in: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => sum_in_tvalid,
            s_axis_tready => sum_in_tready,
            s_axis_tdata => sum_in_tdata,
            m_axis_tvalid => sum_out_tvalid,
            m_axis_tready => sum_out_tready,
            m_axis_tdata => sum_out_tdata
       );
       
      div: fp_divider port map(
            aclk => aclk,
            s_axis_a_tvalid => sum_out_tvalid,
            s_axis_a_tready => sum_out_tready,
            s_axis_a_tdata => sum_out_tdata,
            s_axis_b_tvalid => '1',   -- it's always valid, as it's hardcoded.
            s_axis_b_tready => open,  -- since the constant value doesn't change, you don't need to monitor readiness
            s_axis_b_tdata => "01000000101000000000000000000000", -- divide by 5
            m_axis_result_tvalid => avg_in_tvalid,
            m_axis_result_tready => avg_in_tready,
            m_axis_result_tdata => avg_in_tdata
          );
    
      fifo_out: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => avg_in_tvalid,
            s_axis_tready => avg_in_tready,
            s_axis_tdata => avg_in_tdata,
            m_axis_tvalid => output_tvalid,
            m_axis_tready => output_tready,
            m_axis_tdata => output_tdata
       );

    

end Behavioral;
