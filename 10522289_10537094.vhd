----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03.03.2020 17:02:27
-- Design Name:
-- Module Name: project_reti_logiche - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
  port (
    i_clk : in std_logic;
    i_start : in std_logic;
    i_rst : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
  );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (IDLE,ADDRESS_MODIFIER,WAIT_CLK,READ_RAM,COMPARE,WZ_NUM,ENCODING,ENCODE_FAIL,SAVE_ADDRESS,WRITE_OUT,DONE);
signal  pre_state,curr_state,next_state : state_type := IDLE;
signal  curr_input,next_output : std_logic_vector (7 downto 0);
signal  curr_addr,next_addr : std_logic_vector (15 downto 0);
signal  curr_wz,next_wz : std_logic_vector (7 downto 0);

begin

  project_start:process(i_clk, i_rst, i_data, i_start)

  begin

    if i_rst = '1' then curr_state <= IDLE;
    elsif rising_edge(i_clk) then
      pre_state <= curr_state;
      curr_state <= next_state;
      curr_addr <= next_addr;
      curr_wz <= next_wz;

      case( curr_state ) is

        when IDLE =>

          -- if start = 1 start the fsm and o_done = 0

          if (i_start = '1') then
            o_done <= '0';
            next_state <= ADDRESS_MODIFIER;

          end if;

          next_addr <= "0000000000001000"            -- address starts with walue 8 ( address to encode )


        when ADDRESS_MODIFIER =>

          if (curr_addr = "0000000000000000" ) then

            next_state <= ENCODE_FAIL;

          elsif (pre_state /= IDLE ) then

            next_addr <= ( curr_addr - 1 );
            next_state <= WAIT_CLK;

          else
            next_state <= WAIT_CLK;

          end if;

        when WAIT_CLK =>

          if (pre_state = ADDRESS_MODIFIER) then

            next_state <= READ_RAM;

          elsif (pre_state = SAVE_ADDRESS) then

            next_state <= WRITE_OUT;

          end if;

        when others =>

      end case;

      end if;
    end process;
end Behavioral;
