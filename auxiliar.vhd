library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity auxiliar is
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
end auxiliar;

architecture Structural of auxiliar is

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

  COMPONENT fp_multiplier
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

signal t1_tdata, t2_tdata, t3_tdata, t4_tdata, t5_tdata : STD_LOGIC_VECTOR (31 downto 0);
signal t1_tready, t2_tready, t3_tready, t4_tready, t5_tready: STD_LOGIC;
signal t1_tvalid, t2_tvalid, t3_tvalid, t4_tvalid, t5_tvalid : STD_LOGIC;

begin
    

    fifo1 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => input1_tvalid,
        s_axis_tready => input1_tready,
        s_axis_tdata => input1_tdata,
        m_axis_tvalid => t1_tvalid,
        m_axis_tready => t1_tready,
        m_axis_tdata => t1_tdata
    );
    
    fifo2 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => input2_tvalid,
        s_axis_tready => input2_tready,
        s_axis_tdata => input2_tdata,
        m_axis_tvalid => t2_tvalid,
        m_axis_tready => t2_tready,
        m_axis_tdata => t2_tdata
    );
    
      sub : fp_subtractor port map (
        aclk => aclk,
        s_axis_a_tvalid => t1_tvalid,
        s_axis_a_tready => t1_tready,
        s_axis_a_tdata => t1_tdata,
        s_axis_b_tvalid => t2_tvalid,
        s_axis_b_tready => t2_tready,
        s_axis_b_tdata => t2_tdata,
        m_axis_result_tvalid => t3_tvalid,
        m_axis_result_tready => t3_tready,
        m_axis_result_tdata => t3_tdata
    );
    
     fifo3 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => t3_tvalid,
        s_axis_tready => t3_tready,
        s_axis_tdata => t3_tdata,
        m_axis_tvalid => t4_tvalid,
        m_axis_tready => t4_tready,
        m_axis_tdata => t4_tdata
    );
    
       mul: fp_multiplier port map(
            aclk => aclk,
            s_axis_a_tvalid => t4_tvalid,
            s_axis_a_tready => t4_tready,
            s_axis_a_tdata => t4_tdata,
            s_axis_b_tvalid => t4_tvalid,   
            s_axis_b_tready => t4_tready,  
            s_axis_b_tdata => t4_tdata,
            m_axis_result_tvalid => t5_tvalid,
            m_axis_result_tready => t5_tready,
            m_axis_result_tdata => t5_tdata
    );
     fifo4 : fifo32x64 port map (
        s_axis_aresetn => aresetn,
        s_axis_aclk => aclk,
        s_axis_tvalid => t5_tvalid,
        s_axis_tready => t5_tready,
        s_axis_tdata => t5_tdata,
        m_axis_tvalid => output_tvalid,
        m_axis_tready => output_tready,
        m_axis_tdata => output_tdata
    );
  
    
   
end Structural;
