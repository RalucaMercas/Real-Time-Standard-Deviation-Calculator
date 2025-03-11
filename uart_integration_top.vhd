library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_integration_top is
    Port (
        clk       : in  STD_LOGIC;  
        rst_n     : in  STD_LOGIC; 
        rxd       : in  STD_LOGIC;  
        txd       : out STD_LOGIC;  
        init_btn : in STD_LOGIC 
    );
end uart_integration_top;

architecture Behavioral of uart_integration_top is

    signal rx_data          : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_valid         : STD_LOGIC;
    signal tx_data          : STD_LOGIC_VECTOR(7 downto 0);
    signal tx_valid         : STD_LOGIC;
    signal tx_ready         : STD_LOGIC;

    signal temperature_tdata   : STD_LOGIC_VECTOR(31 downto 0);
    signal humidity_tdata      : STD_LOGIC_VECTOR(31 downto 0);
    signal temperature_tvalid  : STD_LOGIC;
    signal humidity_tvalid     : STD_LOGIC;
    signal temperature_tready  : STD_LOGIC;
    signal humidity_tready     : STD_LOGIC;

    signal st_dev_temperature_tdata : STD_LOGIC_VECTOR(31 downto 0);
    signal st_dev_humidity_tdata    : STD_LOGIC_VECTOR(31 downto 0);
    signal st_dev_temperature_tvalid : STD_LOGIC;
    signal st_dev_humidity_tvalid    : STD_LOGIC;
    
    signal init_debounced : STD_LOGIC;


begin

    debounce_inst: entity work.MPG
        port map (
            clk => clk,
            btn => init_btn,
            en  => init_debounced 
        );

    uart_inst: entity work.uart
        generic map (
            CLKFREQ    => 100000000,  
            BAUDRATE   => 9600,       
            DATA_WIDTH => 8,           
            PARITY     => "NONE",      
            STOP_WIDTH => 1            
        )
        port map (
            clk => clk,
            rxd => rxd,
            txd => txd,
            m_axis_tready => '1',
            m_axis_tdata  => rx_data,
            m_axis_tvalid => rx_valid,
            s_axis_tvalid => tx_valid,
            s_axis_tdata  => tx_data,
            s_axis_tready => tx_ready
        );

    calculator_inst: entity work.temp_humidity_standard_deviation_calculator
        port map (
            aclk => clk,
            aresetn => rst_n,
            init => init_debounced, 
            temperature_tready => temperature_tready,
            temperature_tvalid => temperature_tvalid,
            temperature_tdata => temperature_tdata,
            humidity_tready => humidity_tready,
            humidity_tvalid => humidity_tvalid,
            humidity_tdata => humidity_tdata,
            st_dev_temperature_tready => '1', 
            st_dev_temperature_tvalid => st_dev_temperature_tvalid,
            st_dev_temperature_tdata => st_dev_temperature_tdata,
            st_dev_humidity_tready => '1',   
            st_dev_humidity_tvalid => st_dev_humidity_tvalid,
            st_dev_humidity_tdata => st_dev_humidity_tdata
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rx_valid = '1' then
                temperature_tdata <= rx_data & temperature_tdata(31 downto 8);
                humidity_tdata <= rx_data & humidity_tdata(31 downto 8);
                temperature_tvalid <= '1';
                humidity_tvalid <= '1';
            else
                temperature_tvalid <= '0';
                humidity_tvalid <= '0';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if st_dev_temperature_tvalid = '1' then
                tx_data <= st_dev_temperature_tdata(7 downto 0); 
                tx_valid <= '1';
            elsif st_dev_humidity_tvalid = '1' then
                tx_data <= st_dev_humidity_tdata(7 downto 0); 
                tx_valid <= '1';
            else
                tx_valid <= '0';
            end if;
        end if;
    end process;

end Behavioral;
