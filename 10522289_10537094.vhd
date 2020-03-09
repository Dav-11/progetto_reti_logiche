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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;

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

type state_type is (IDLE, ADDRESS_MODIFIER, WAIT_CLK, READ_RAM, COMPARE, WZ_NUM, ENCODING, ENCODE_FAIL, SAVE_ADDRESS, DONE);
signal  pre_state, curr_state, next_state : state_type := IDLE;
signal  curr_input, next_output : std_logic_vector (7 downto 0);
signal  curr_addr : std_logic_vector (15 downto 0);
signal  next_addr : std_logic_vector (15 downto 0) := "0000000000001000";
signal  curr_wz : std_logic_vector (7 downto 0);

begin

  project_start:process(i_clk, i_rst, i_data, i_start)
  
  variable difference : integer range -127 to 127 := 0;
  variable one_hot : std_logic_vector (3 downto 0) := "1111";
  variable enc : std_logic_vector (2 downto 0) := "111";

  begin

    if i_rst = '1' then curr_state <= IDLE;
    elsif rising_edge(i_clk) then
      pre_state <= curr_state;
      curr_state <= next_state;
      curr_addr <= next_addr;

      case( curr_state ) is

        when IDLE =>

          -- if start = 1 start the fsm and o_done = 0

          if (i_start = '1') then
            o_done <= '0';
            next_state <= ADDRESS_MODIFIER;

          end if;

          next_addr <= "0000000000001000";            -- address starts with walue 8 ( address to encode )
          o_we <= '0';
          o_en <= '0';

    -- ADDR_MOD
        when ADDRESS_MODIFIER =>
        
          o_en <= '1';

          if (curr_addr = "0000000000000000" ) then
            next_state <= ENCODE_FAIL;

          elsif (pre_state /= IDLE ) then

            next_addr <= ( curr_addr - "0000000000000001" );
            next_state <= WAIT_CLK;

          else
            next_state <= WAIT_CLK;

          end if;

    -- WAIT_CLK
        when WAIT_CLK =>
        
          o_en <= '0';

          if (pre_state = ADDRESS_MODIFIER) then

            next_state <= READ_RAM;

          elsif (pre_state = SAVE_ADDRESS) then

            next_state <= DONE;
            o_done <= '1';

          elsif (pre_state = ENCODE_FAIL) then

            next_state <= DONE;
            o_done <= '1';
            
          end if;
          
    -- READ_RAM
         when READ_RAM =>
         
            if (conv_integer(curr_addr) = 8) then
            
                curr_input <= i_data;
                next_state <= ADDRESS_MODIFIER;
                
            else
            
                curr_wz <= i_data;
                next_state <= COMPARE;
                    
            end if;
         
    -- COMPARE
         when COMPARE =>
         
         difference := (conv_integer(curr_input) - conv_integer(curr_wz));
         
            case (difference) is
            
                when 0  =>
                    
                    one_hot := "0001";
                    next_state <= WZ_NUM;
                when 1  =>
                
                    one_hot := "0010";
                    next_state <= WZ_NUM;
                when 2  =>
                
                    one_hot := "0100";
                    next_state <= WZ_NUM;
                when 3  =>
                
                    one_hot := "1000";
                    next_state <= WZ_NUM;
                when others =>
                
                    next_state <= ADDRESS_MODIFIER;
                    
            end case;
        
     -- WZ_NUM    
         when WZ_NUM =>
         
            case (conv_integer(curr_addr)) is
            
                when 0 =>
                    
                    enc := "000";
                    
                when 1 =>
                
                    enc := "001";
                    
                when 2 =>
                                    
                    enc := "010";
                    
                when 3 =>
                                    
                    enc := "011";
                    
                when 4 =>
                                    
                    enc := "100";
                    
                when 5 =>
                                    
                    enc := "101";
                    
                when 6 =>
                                    
                    enc := "110";
                    
                when 7 =>
                                    
                    enc := "111";
                    
                end case;
                
                next_state <= ENCODING;
         
     -- ENCODING    
         when ENCODING =>
         
            next_output <= '1' & enc & one_hot;
            
            next_state <= SAVE_ADDRESS;
         
     -- SAVE_ADDRESS    
         when SAVE_ADDRESS =>
            
            o_en <= '1';
            o_we <= '1';
                     
            o_address <= "0000000000001001";
            o_data <= next_output;
            
            next_state <= WAIT_CLK;
         
     -- ENCODE FAIL
         when ENCODE_FAIL =>
         
            o_en <= '1';
            o_we <= '1';
            
            o_address <= "0000000000001001"; 
            o_data <= curr_input;
            
            next_state <= WAIT_CLK;
            
     -- DONE
         when DONE =>
            if ( i_start = '0') then
                o_done <= '0';
                next_state <= IDLE;
            end if;
            
         when others =>

      end case;

      end if;
    end process;
end Behavioral;
