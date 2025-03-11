library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity temp_humidity_standard_deviation_calculator is
     Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            init: IN STD_LOGIC;
            temperature_tready : out STD_LOGIC;
            temperature_tvalid : in STD_LOGIC;
            temperature_tdata : in STD_LOGIC_VECTOR (31 downto 0);
            humidity_tready : out STD_LOGIC;
            humidity_tvalid : in STD_LOGIC;
            humidity_tdata : in STD_LOGIC_VECTOR (31 downto 0);
            st_dev_temperature_tready : in STD_LOGIC;
            st_dev_temperature_tvalid : out STD_LOGIC;
            st_dev_temperature_tdata : out STD_LOGIC_VECTOR (31 downto 0);
            st_dev_humidity_tready : in STD_LOGIC;
            st_dev_humidity_tvalid : out STD_LOGIC;
            st_dev_humidity_tdata : out STD_LOGIC_VECTOR (31 downto 0)
        );
end temp_humidity_standard_deviation_calculator;

architecture Behavioral of temp_humidity_standard_deviation_calculator is

    component standard_deviation_calculator is
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
        
        signal tout_tdata, st_dev_tin_tdata : STD_LOGIC_VECTOR (31 downto 0);
        signal tout_tready, st_dev_tin_tready : STD_LOGIC;
        signal tout_tvalid, st_dev_tin_tvalid : STD_LOGIC;
        
        signal hout_tdata, st_dev_hin_tdata : STD_LOGIC_VECTOR (31 downto 0);
        signal hout_tready, st_dev_hin_tready : STD_LOGIC;
        signal hout_tvalid, st_dev_hin_tvalid : STD_LOGIC;

begin
     input_temp_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => temperature_tvalid,
            s_axis_tready => temperature_tready,
            s_axis_tdata => temperature_tdata,
            m_axis_tvalid => tout_tvalid,
            m_axis_tready => tout_tready,
            m_axis_tdata => tout_tdata
       );
       
      input_humid_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => humidity_tvalid,
            s_axis_tready => humidity_tready,
            s_axis_tdata => humidity_tdata,
            m_axis_tvalid => hout_tvalid,
            m_axis_tready => hout_tready,
            m_axis_tdata => hout_tdata
       );

     temp: standard_deviation_calculator port map(
            aclk => aclk, 
            aresetn => aresetn, 
            init => init, 
            input_tvalid => tout_tvalid,
            input_tdata => tout_tdata,
            output_tready => st_dev_tin_tready,
            input_tready => tout_tready,
            output_tvalid => st_dev_tin_tvalid,
            output_tdata => st_dev_tin_tdata
        );
    
     humidity: standard_deviation_calculator port map(
            aclk => aclk, 
            aresetn => aresetn, 
            init => init, 
            input_tvalid => hout_tvalid,
            input_tdata => hout_tdata,
            output_tready => st_dev_hin_tready,
            input_tready => hout_tready,
            output_tvalid => st_dev_hin_tvalid,
            output_tdata => st_dev_hin_tdata
        );
        
        output_temp_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => st_dev_tin_tvalid,
            s_axis_tready => st_dev_tin_tready,
            s_axis_tdata => st_dev_tin_tdata,
            m_axis_tvalid => st_dev_temperature_tvalid,
            m_axis_tready => st_dev_temperature_tready,
            m_axis_tdata => st_dev_temperature_tdata
       );
       
       output_humid_fifo: fifo32x64 port map(  
            s_axis_aresetn => aresetn,
            s_axis_aclk => aclk,
            s_axis_tvalid => st_dev_hin_tvalid,
            s_axis_tready => st_dev_hin_tready,
            s_axis_tdata => st_dev_hin_tdata,
            m_axis_tvalid => st_dev_humidity_tvalid,
            m_axis_tready => st_dev_humidity_tready,
            m_axis_tdata => st_dev_humidity_tdata
       );

end Behavioral;
