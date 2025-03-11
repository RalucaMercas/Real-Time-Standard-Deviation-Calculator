library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity variance is
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
end variance;

architecture Behavioral of variance is
    
        component square_sum_comp is
            Generic (
                WINDOW_SIZE : integer := 5
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
        

        signal square_in_tdata, square_out_tdata, out_tdata : STD_LOGIC_VECTOR (31 downto 0);
        signal square_in_tready, square_out_tready, out_tready : STD_LOGIC;
        signal square_in_tvalid, square_out_tvalid, out_tvalid : STD_LOGIC;
        
begin

    sq: square_sum_comp
        Generic map (
            WINDOW_SIZE => 5
        )
        Port map (
            aclk => aclk,
            aresetn => aresetn,
            init => init,
            new_value_tvalid => input_tvalid,
            new_value_tready => input_tready,
            new_value_tdata => input_tdata,
            output_tvalid => square_in_tvalid,
            output_tready => square_in_tready,
            output_tdata => square_in_tdata
        );
    

       input_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => square_in_tvalid,
            s_axis_tready => square_in_tready,
            s_axis_tdata => square_in_tdata,
            m_axis_tvalid => square_out_tvalid,
            m_axis_tready => square_out_tready,
            m_axis_tdata => square_out_tdata
       );
       
         div: fp_divider port map(
            aclk => aclk,
            s_axis_a_tvalid => square_out_tvalid,
            s_axis_a_tready => square_out_tready,
            s_axis_a_tdata => square_out_tdata,
            s_axis_b_tvalid => '1',  
            s_axis_b_tready => open,  
            s_axis_b_tdata => "01000000101000000000000000000000",  --5
            m_axis_result_tvalid => out_tvalid,
            m_axis_result_tready => out_tready,
            m_axis_result_tdata => out_tdata
          );
       
       output_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => out_tvalid,
            s_axis_tready => out_tready,
            s_axis_tdata => out_tdata,
            m_axis_tvalid => output_tvalid,
            m_axis_tready => output_tready,
            m_axis_tdata => output_tdata
       );
       
end Behavioral;
