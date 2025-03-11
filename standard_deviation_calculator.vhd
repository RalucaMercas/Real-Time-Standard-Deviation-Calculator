library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity standard_deviation_calculator is
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
end standard_deviation_calculator;

architecture Behavioral of standard_deviation_calculator is

       component variance is
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
        end component;
        
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
        
       COMPONENT fp_square_root
          PORT (
            aclk : IN STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tready : OUT STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tready : IN STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
        END COMPONENT;
        
        signal variance_in_tdata, variance_out_tdata, st_dev_tdata : STD_LOGIC_VECTOR (31 downto 0);
        signal variance_in_tready, variance_out_tready, st_dev_tready : STD_LOGIC;
        signal variance_in_tvalid, variance_out_tvalid, st_dev_tvalid : STD_LOGIC;

begin
    
      variance_comp: variance port map(
            aclk => aclk, 
            aresetn => aresetn, 
            init => init, 
            input_tvalid => input_tvalid,
            input_tdata => input_tdata,
            output_tready => variance_in_tready,
            input_tready => input_tready,
            output_tvalid => variance_in_tvalid,
            output_tdata => variance_in_tdata
        );

          input_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => variance_in_tvalid,
            s_axis_tready => variance_in_tready,
            s_axis_tdata => variance_in_tdata,
            m_axis_tvalid => variance_out_tvalid,
            m_axis_tready => variance_out_tready,
            m_axis_tdata => variance_out_tdata
       );
       
       sqrt_comp: fp_square_root port map(
            aclk => aclk,
            s_axis_a_tvalid => variance_out_tvalid,
            s_axis_a_tready => variance_out_tready,
            s_axis_a_tdata => variance_out_tdata,
            m_axis_result_tvalid => st_dev_tvalid,
            m_axis_result_tready => st_dev_tready,
            m_axis_result_tdata => st_dev_tdata
          );
          
       output_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => st_dev_tvalid,
            s_axis_tready => st_dev_tready,
            s_axis_tdata => st_dev_tdata,
            m_axis_tvalid => output_tvalid,
            m_axis_tready => output_tready,
            m_axis_tdata => output_tdata
       );
       
end Behavioral;
