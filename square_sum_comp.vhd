library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity square_sum_comp is
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
--            ;
--            w0_valid: out std_logic;
--            w1_valid: out std_logic;
--            w2_valid: out std_logic;
--            w3_valid: out std_logic;
--            w4_valid: out std_logic;
--            val0: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            val1: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            val2: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            val3 : out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            val4: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            out0: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            out1: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            out2: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            out3 : out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            out4: out STD_LOGIC_VECTOR(31 DOWNTO 0);
--            temp_avg: out STD_LOGIC_VECTOR(31 DOWNTO 0)
            
        );
end square_sum_comp;

architecture Behavioral of square_sum_comp is

    signal ptr : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    
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
      
      COMPONENT average_calculator is
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
     end COMPONENT;
     
    COMPONENT auxiliar is
    Port ( aclk : in STD_LOGIC;
           aresetn : in STD_LOGIC;
           input1_tvalid : in STD_LOGIC;
           input1_tready : out STD_LOGIC;
           input1_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           input2_tvalid : in STD_LOGIC;
           input2_tready : out STD_LOGIC;
           input2_tdata : in STD_LOGIC_VECTOR (31 downto 0);
           output_tvalid : out STD_LOGIC;
           output_tready : in STD_LOGIC;
           output_tdata : out STD_LOGIC_VECTOR (31 downto 0));
    end COMPONENT;
    
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
     
    signal avg_tvalid, avg_tready : STD_LOGIC := '0';
    signal avg_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
      
    signal temp_avg_tvalid, temp_avg_tready : STD_LOGIC := '0';
    signal temp_avg_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
        
    signal value0, value1, value2, value3, value4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    
    signal w0_tvalid, w0_tready, out0_tvalid, out0_tready, x0_tvalid, x0_tready : STD_LOGIC := '0';
    signal w0_tdata, out0_tdata, x0_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
          
    signal w1_tvalid, w1_tready, out1_tvalid, out1_tready, x1_tvalid, x1_tready: STD_LOGIC := '0';
    signal w1_tdata, out1_tdata, x1_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    
    signal w2_tvalid, w2_tready, out2_tvalid, out2_tready, x2_tvalid, x2_tready  : STD_LOGIC := '0';
    signal w2_tdata, out2_tdata, x2_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');    
 
    signal w3_tvalid, w3_tready, out3_tvalid, out3_tready, x3_tvalid, x3_tready  : STD_LOGIC := '0';
    signal w3_tdata, out3_tdata, x3_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');   
    
    signal w4_tvalid, w4_tready, out4_tvalid, out4_tready, x4_tvalid, x4_tready  : STD_LOGIC := '0';
    signal w4_tdata, out4_tdata, x4_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');       
    
    signal x5_tvalid, x5_tready, x6_tvalid, x6_tready, x7_tvalid, x7_tready  : STD_LOGIC := '0';
    signal x5_tdata, x6_tdata, x7_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');       

    signal x8_tvalid, x8_tready, x9_tvalid, x9_tready, x10_tvalid, x10_tready, x11_tvalid, x11_tready  : STD_LOGIC := '0';
    signal x8_tdata, x9_tdata, x10_tdata, x11_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');       



begin
    
     avg: average_calculator port map(
            aclk => aclk, 
            aresetn => aresetn, 
            init => init, 
            input_tvalid => new_value_tvalid,
            input_tdata => new_value_tdata,
            output_tready => avg_tready,
            input_tready => new_value_tready,
            output_tvalid => avg_tvalid,
            output_tdata => avg_tdata
     );
        
    fifo_avg : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => avg_tvalid,
        s_axis_tready => avg_tready,
        s_axis_tdata => avg_tdata,
        m_axis_tvalid => temp_avg_tvalid,
        m_axis_tready => temp_avg_tready,
        m_axis_tdata => temp_avg_tdata
    ); 
    
    fifo_0 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => value0,
        m_axis_tvalid => w0_tvalid,
        m_axis_tready => temp_avg_tvalid,
        m_axis_tdata => w0_tdata
    ); 
    
    fifo_1 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => value1,
        m_axis_tvalid => w1_tvalid,
        m_axis_tready => temp_avg_tvalid,
        m_axis_tdata => w1_tdata
    ); 
    
    fifo_2 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => value2,
        m_axis_tvalid => w2_tvalid,
        m_axis_tready => temp_avg_tvalid,
        m_axis_tdata => w2_tdata
    ); 
    
    fifo_3 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => value3,
        m_axis_tvalid => w3_tvalid,
        m_axis_tready => temp_avg_tvalid,
        m_axis_tdata => w3_tdata
    ); 
    
    
    fifo_4 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => new_value_tvalid,
        s_axis_tready => new_value_tready,
        s_axis_tdata => value4,
        m_axis_tvalid => w4_tvalid,
        m_axis_tready => temp_avg_tvalid,
        m_axis_tdata => w4_tdata
    ); 
    
    
    aux0: auxiliar port map ( 
        aclk => aclk,
        aresetn => aresetn, 
        input1_tvalid => temp_avg_tvalid,
        input1_tready => w0_tready,
        input1_tdata => w0_tdata, 
        input2_tvalid => temp_avg_tvalid,
        input2_tready => temp_avg_tready,
        input2_tdata => temp_avg_tdata, 
        output_tvalid => out0_tvalid,
        output_tready => temp_avg_tready,
        output_tdata => out0_tdata
    );
    
     aux1: auxiliar port map ( 
        aclk => aclk,
        aresetn => aresetn, 
        input1_tvalid => temp_avg_tvalid,
        input1_tready => w1_tready,
        input1_tdata => w1_tdata, 
        input2_tvalid => temp_avg_tvalid,
        input2_tready => temp_avg_tready,
        input2_tdata => temp_avg_tdata, 
        output_tvalid => out1_tvalid,
        output_tready => temp_avg_tready,
        output_tdata => out1_tdata
    );
    
     aux2: auxiliar port map ( 
        aclk => aclk,
        aresetn => aresetn, 
        input1_tvalid => temp_avg_tvalid,
        input1_tready => w2_tready,
        input1_tdata => w2_tdata, 
        input2_tvalid => temp_avg_tvalid,
        input2_tready => temp_avg_tready,
        input2_tdata => temp_avg_tdata, 
        output_tvalid => out2_tvalid,
        output_tready => temp_avg_tready,
        output_tdata => out2_tdata
    );
    
     aux3: auxiliar port map ( 
        aclk => aclk,
        aresetn => aresetn, 
        input1_tvalid => temp_avg_tvalid,
        input1_tready => w3_tready,
        input1_tdata => w3_tdata, 
        input2_tvalid => temp_avg_tvalid,
        input2_tready => temp_avg_tready,
        input2_tdata => temp_avg_tdata, 
        output_tvalid => out3_tvalid,
        output_tready => temp_avg_tready,
        output_tdata => out3_tdata
    );
    
     aux4: auxiliar port map ( 
        aclk => aclk,
        aresetn => aresetn, 
        input1_tvalid => temp_avg_tvalid,
        input1_tready => w4_tready,
        input1_tdata => w4_tdata, 
        input2_tvalid => temp_avg_tvalid,
        input2_tready => temp_avg_tready,
        input2_tdata => temp_avg_tdata, 
        output_tvalid => out4_tvalid,
        output_tready => temp_avg_tready,
        output_tdata => out4_tdata
    );
    
    fifo_aux_0:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => out0_tvalid,
        s_axis_tready => temp_avg_tready,
        s_axis_tdata => out0_tdata,
        m_axis_tvalid => x0_tvalid,
        m_axis_tready => x0_tready,
        m_axis_tdata => x0_tdata
    ); 
    
        fifo_aux_1:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => out1_tvalid,
        s_axis_tready => temp_avg_tready,
        s_axis_tdata => out1_tdata,
        m_axis_tvalid => x1_tvalid,
        m_axis_tready => x1_tready,
        m_axis_tdata => x1_tdata
    ); 
    
    
        fifo_aux_2:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => out2_tvalid,
        s_axis_tready => temp_avg_tready,
        s_axis_tdata => out2_tdata,
        m_axis_tvalid => x2_tvalid,
        m_axis_tready => x2_tready,
        m_axis_tdata => x2_tdata
    ); 
    
    
        fifo_aux_3:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => out3_tvalid,
        s_axis_tready => temp_avg_tready,
        s_axis_tdata => out3_tdata,
        m_axis_tvalid => x3_tvalid,
        m_axis_tready => x3_tready,
        m_axis_tdata => x3_tdata
    ); 
    
    
        fifo_aux_4:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => out4_tvalid,
        s_axis_tready => temp_avg_tready,
        s_axis_tdata => out4_tdata,
        m_axis_tvalid => x4_tvalid,
        m_axis_tready => x4_tready,
        m_axis_tdata => x4_tdata
    ); 
    
     adder_1 : fp_adder port map (
        aclk => aclk,
        s_axis_a_tvalid => x0_tvalid,
        s_axis_a_tready => x0_tready,
        s_axis_a_tdata => x0_tdata,
        s_axis_b_tvalid => x1_tvalid,
        s_axis_b_tready => x1_tready,
        s_axis_b_tdata => x1_tdata,
        m_axis_result_tvalid => x5_tvalid,
        m_axis_result_tready => x5_tready,
        m_axis_result_tdata => x5_tdata
    );

  adder_2 : fp_adder port map (
        aclk => aclk,
        s_axis_a_tvalid => x2_tvalid,
        s_axis_a_tready => x2_tready,
        s_axis_a_tdata => x2_tdata,
        s_axis_b_tvalid => x3_tvalid,
        s_axis_b_tready => x3_tready,
        s_axis_b_tdata => x3_tdata,
        m_axis_result_tvalid => x6_tvalid,
        m_axis_result_tready => x6_tready,
        m_axis_result_tdata => x6_tdata
    );
    
     fifo_aux_5:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => x5_tvalid,
        s_axis_tready => x5_tready,
        s_axis_tdata => x5_tdata,
        m_axis_tvalid => x7_tvalid,
        m_axis_tready => x7_tready,
        m_axis_tdata => x7_tdata
    ); 
    
    fifo_aux_6:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => x6_tvalid,
        s_axis_tready => x6_tready,
        s_axis_tdata => x6_tdata,
        m_axis_tvalid => x8_tvalid,
        m_axis_tready => x8_tready,
        m_axis_tdata => x8_tdata
    ); 
    
     adder_3 : fp_adder port map (
        aclk => aclk,
        s_axis_a_tvalid => x7_tvalid,
        s_axis_a_tready => x7_tready,
        s_axis_a_tdata => x7_tdata,
        s_axis_b_tvalid => x8_tvalid,
        s_axis_b_tready => x8_tready,
        s_axis_b_tdata => x8_tdata,
        m_axis_result_tvalid => x9_tvalid,
        m_axis_result_tready => x9_tready,
        m_axis_result_tdata => x9_tdata
    );
    
     fifo_aux_7:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => x9_tvalid,
        s_axis_tready => x9_tready,
        s_axis_tdata => x9_tdata,
        m_axis_tvalid => x10_tvalid,
        m_axis_tready => x10_tready,
        m_axis_tdata => x10_tdata
    ); 
    
       adder_4 : fp_adder port map (
        aclk => aclk,
        s_axis_a_tvalid => x10_tvalid,
        s_axis_a_tready => x10_tready,
        s_axis_a_tdata => x10_tdata,
        s_axis_b_tvalid => x4_tvalid,
        s_axis_b_tready => x4_tready,
        s_axis_b_tdata => x4_tdata,
        m_axis_result_tvalid => x11_tvalid,
        m_axis_result_tready => x11_tready,
        m_axis_result_tdata => x11_tdata
    );
    
      fifo_aux_8:  fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => x11_tvalid,
        s_axis_tready => x11_tready,
        s_axis_tdata => x11_tdata,
        m_axis_tvalid => output_tvalid,
        m_axis_tready => output_tready,
        m_axis_tdata => output_tdata
    ); 


process(aclk, aresetn)
    begin
        if aresetn = '0' then
            ptr <= "000";
            value0 <= (others => '0');
            value1 <= (others => '0');
            value2 <= (others => '0');
            value3 <= (others => '0');
            value4 <= (others => '0');
        elsif rising_edge(aclk) then
            if new_value_tvalid = '1' then
                if ptr = "000" then 
                    value0 <= new_value_tdata; 
                elsif ptr = "001" then 
                    value1 <= new_value_tdata;
                elsif ptr = "010" then 
                    value2 <= new_value_tdata; 
                elsif ptr = "011" then 
                    value3 <= new_value_tdata; 
                elsif ptr = "100" then 
                    value4 <= new_value_tdata; 
                end if;

                if to_integer(unsigned(ptr)) = (WINDOW_SIZE - 1) then
                    ptr <= "000";
                else
                    ptr <= ptr + 1;
                end if;
            end if;
            
        end if;
    end process;
 
--    val0 <= w0_tdata;
--    val1 <= w1_tdata;
--    val2 <= w2_tdata;
--    val3 <= w3_tdata;
--    val4 <= w4_tdata;

--    out0 <= out0_tdata;
--    out1 <= out1_tdata;
--    out2 <= out2_tdata;
--    out3 <= out3_tdata;
--    out4 <= out4_tdata;
--    temp_avg <= temp_avg_tdata;
    
end Behavioral;