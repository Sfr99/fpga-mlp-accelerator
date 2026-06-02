library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mlp_accel_stream  is
		generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end mlp_accel_stream;

architecture arch_imp of mlp_accel_stream  is

-- component declaration
	component mlp_accel_stream_slave_lite_v1_0_S00_AXI  is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
			--user ports
			 -- Timer
            number_cycles           : in STD_LOGIC_VECTOR(32-1 downto 0);
            word0           : in STD_LOGIC_VECTOR(32-1 downto 0);
            word7           : in STD_LOGIC_VECTOR(32-1 downto 0);
            -- end user ports
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
		);
	end component;

	component mlp_accel_stream_slave_stream_v1_0_S00_AXIS  is
		generic (
		  C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
            S_AXIS_ACLK	    : in std_logic;
            S_AXIS_ARESETN	: in std_logic;
            S_AXIS_TREADY	: out std_logic;
            S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
            S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
            S_AXIS_TLAST	: in std_logic;
            S_AXIS_TVALID	: in std_logic;
            -- Added ports
            data_stream_in	 : OUT STD_LOGIC_VECTOR(C_S_AXIS_TDATA_WIDTH-1 downto 0);
            new_data : OUT STD_LOGIC
		);
	end component;

	component mlp_accel_stream_master_stream_v1_0_M00_AXIS   is
		generic (
            C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
            C_M_START_COUNT	: integer	:= 32
		);
		port (
            M_AXIS_ACLK	: in std_logic;
            M_AXIS_ARESETN	: in std_logic;
            M_AXIS_TVALID	: out std_logic;
            M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
            M_AXIS_TLAST	: out std_logic;
            M_AXIS_TREADY	: in std_logic;
            -- Added ports
            --datos a enviar
            data_stream_out : in std_logic_vector(31 downto 0);        
            -- send data indica que hay que enviar los datos
            send_data        : in STD_LOGIC;
            word_count: out std_logic_vector(3 downto 0) 
		);
	end component;
	
	
    component counter
        generic (bits: positive);
        port (clk, rst: in STD_LOGIC;
              rst2 : in STD_LOGIC;
              inc : in STD_LOGIC;
              count : out STD_LOGIC_VECTOR(bits-1 downto 0)
        );
    end component;
    
    component mlp_top is
        Port (
            clk          : in std_logic;
            reset        : in std_logic;
            start        : in std_logic;
            done         : out std_logic;
            inputs_flat  : in std_logic_vector(3199 downto 0);
            outputs_flat : out std_logic_vector(255 downto 0)
        );
    end component;
    signal clk, rst: std_logic;
    -- Time measurement
    signal number_cycles: STD_LOGIC_VECTOR(32-1 downto 0);
    -- datos de entrada y salida del stream
    signal data_stream_in, data_stream_out: std_logic_vector(31 downto 0);
    signal new_data: std_logic;
    
   
    -- contador de palabras recibidas (ahora se contar hasta 100, 7 bits = hasta 127)
    signal rst_received, inc_received: STD_LOGIC;
    signal number_of_received_words: std_logic_vector(6 downto 0);
    
    -- buffer de entrada del acelerador (200 valores de 16 bits)
    signal inputs_flat : std_logic_vector(3199 downto 0);
    
    -- salida del acelerador
    signal outputs_flat : std_logic_vector(255 downto 0);
    signal accel_done : std_logic;
    signal accel_start : std_logic;
    
    -- envio
    signal send_data: std_logic;
    signal word_count: std_logic_vector(3 downto 0);
    
    signal accel_done_prev : std_logic;
    signal accel_done_pulse : std_logic;
begin
    -- Instantiation of Axi Bus Interface S00_AXI
    Prueba_S00_AXI_inst : mlp_accel_stream_slave_lite_v1_0_S00_AXI
        generic map (
            C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
        )
        port map (
            S_AXI_ACLK	=> s00_axi_aclk,
            S_AXI_ARESETN	=> s00_axi_aresetn,
            S_AXI_AWADDR	=> s00_axi_awaddr,
            S_AXI_AWPROT	=> s00_axi_awprot,
            S_AXI_AWVALID	=> s00_axi_awvalid,
            S_AXI_AWREADY	=> s00_axi_awready,
            S_AXI_WDATA	=> s00_axi_wdata,
            S_AXI_WSTRB	=> s00_axi_wstrb,
            S_AXI_WVALID	=> s00_axi_wvalid,
            S_AXI_WREADY	=> s00_axi_wready,
            S_AXI_BRESP	=> s00_axi_bresp,
            S_AXI_BVALID	=> s00_axi_bvalid,
            S_AXI_BREADY	=> s00_axi_bready,
            S_AXI_ARADDR	=> s00_axi_araddr,
            S_AXI_ARPROT	=> s00_axi_arprot,
            S_AXI_ARVALID	=> s00_axi_arvalid,
            S_AXI_ARREADY	=> s00_axi_arready,
            S_AXI_RDATA	=> s00_axi_rdata,
            S_AXI_RRESP	=> s00_axi_rresp,
            S_AXI_RVALID	=> s00_axi_rvalid,
            S_AXI_RREADY	=> s00_axi_rready,
			-- Added ports
			word0                => inputs_flat(31 downto 0),
            word7                => outputs_flat(31 downto 0),
			number_cycles        => number_cycles
	     );
    
    -- Instantiation of Axi Bus Interface S00_AXIS
    Prueba_S00_AXIS_inst : mlp_accel_stream_slave_stream_v1_0_S00_AXIS
        generic map (
            C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
        )
        port map (
            S_AXIS_ACLK	=> s00_axis_aclk,
            S_AXIS_ARESETN	=> s00_axis_aresetn,
            S_AXIS_TREADY	=> s00_axis_tready,
            S_AXIS_TDATA	=> s00_axis_tdata,
            S_AXIS_TSTRB	=> s00_axis_tstrb,
            S_AXIS_TLAST	=> s00_axis_tlast,
            S_AXIS_TVALID	=> s00_axis_tvalid,
            -- Added ports
            data_stream_in      => data_stream_in,
            new_data  => new_data
        );
    
    -- Instantiation of Axi Bus Interface M00_AXIS
    Prueba_M00_AXIS_inst : mlp_accel_stream_master_stream_v1_0_M00_AXIS
        generic map (
            C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
            C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
        )
        port map (
            M_AXIS_ACLK	    => m00_axis_aclk,
            M_AXIS_ARESETN	=> m00_axis_aresetn,
            M_AXIS_TVALID	=> m00_axis_tvalid,
            M_AXIS_TDATA	=> m00_axis_tdata,
            M_AXIS_TSTRB	=> m00_axis_tstrb,
            M_AXIS_TLAST	=> m00_axis_tlast,
            M_AXIS_TREADY	=> m00_axis_tready,
            -- Added ports
            data_stream_out         => data_stream_out,
            send_data       => send_data,
            word_count      => word_count 
        );

	-- Add user logic here

       
    rst <= NOT(s00_axi_aresetn);
    
    timer: counter generic map(32)
        port map(s00_axi_aclk, rst, '0', '1', number_cycles);
    
    received_words: counter generic map(7)
        port map(s00_axi_aclk, rst, rst_received, inc_received, number_of_received_words);
    inc_received <= new_data;
    

    process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            if rst = '1' then
                inputs_flat <= (others => '0');
            elsif new_data = '1' then
                inputs_flat(to_integer(unsigned(number_of_received_words)) * 32 + 31 
                          downto to_integer(unsigned(number_of_received_words)) * 32) 
                          <= data_stream_in;
            end if;
        end if;
    end process;
    
    rst_received <= '1' when number_of_received_words = "1100100" else '0';  
    accel_start  <= rst_received;
    
    mlp_inst: mlp_top
        port map (
            clk          => s00_axi_aclk,
            reset        => rst,
            start        => accel_start,
            done         => accel_done,
            inputs_flat  => inputs_flat,
            outputs_flat => outputs_flat
        );
    
    process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            if rst = '1' then
                accel_done_prev <= '0';
            else
                accel_done_prev <= accel_done;
            end if;
        end if;
    end process;
    
    accel_done_pulse <= accel_done and not accel_done_prev;
    send_data <= accel_done_pulse;
    
    data_stream_out <= outputs_flat(31  downto 0)   when word_count = "0000" else
                       outputs_flat(63  downto 32)  when word_count = "0001" else
                       outputs_flat(95  downto 64)  when word_count = "0010" else
                       outputs_flat(127 downto 96)  when word_count = "0011" else
                       outputs_flat(159 downto 128) when word_count = "0100" else
                       outputs_flat(191 downto 160) when word_count = "0101" else
                       outputs_flat(223 downto 192) when word_count = "0110" else
                       outputs_flat(255 downto 224) when word_count = "0111" else
                       x"0000ffff";

end arch_imp;