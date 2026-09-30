----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2019 06:42:35 AM
-- Design Name: 
-- Module Name: MedianFilter - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MedianFilter is
    Generic (
        NUM_VALS : integer:= 8;
        SIZE : integer:= 4
    );
  Port (
    clk: in std_logic;
    input_data: in std_logic_vector(NUM_VALS*SIZE-1 downto 0);
    output_data: out std_logic_vector(NUM_VALS*SIZE-1 downto 0);
    mid: out std_logic_vector(SIZE-1 downto 0)
   );
end MedianFilter;

architecture Behavioral of MedianFilter is

    signal sorted_bus : std_logic_vector(NUM_VALS*SIZE-1 downto 0);
    signal temp2 : std_logic_vector(SIZE-1 downto 0);
    type t_Memory is array (0 to NUM_VALS-1) of std_logic_vector(SIZE-1 downto 0);
 
begin
    
    output_data <= sorted_bus;
    mid <= temp2;
    
sorting : process(clk, input_data) is
    variable r_Mem : t_Memory;
    variable temp : std_logic_vector(SIZE-1 downto 0);
    variable j : integer;
begin
    
    for i in 0 to NUM_VALS-1 loop
        r_Mem(i) := input_data(((i+1)*SIZE)-1 downto i*SIZE); 
    end loop;
    
    for i in 1 to NUM_VALS-1 loop
        temp := r_Mem(i);
        j := i - 1;
        while j>=0 and r_Mem(j) > temp loop
                r_Mem(j+1) := r_Mem(j);
                j := j -1;
        end loop;
        r_Mem(j+1):= temp;
    end loop;
    
    for i in 0 to NUM_VALS-1 loop
        sorted_bus(((i+1)*SIZE)-1 downto i*SIZE) <= r_Mem(i);
    end loop; 
    temp2 <= r_Mem(4);
    
end process;

end Behavioral;
