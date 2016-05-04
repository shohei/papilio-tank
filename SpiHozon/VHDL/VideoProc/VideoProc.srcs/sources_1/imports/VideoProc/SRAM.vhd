-- Designed by Toshio Iwata at DIGITALFILTER.COM 2013/03/19

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.std_logic_arith.all;

entity SRAM is
   Port (
          CLK : In std_logic;
          CS_N : In std_logic;
          WR_N : In std_logic;
          WRADDR : In std_logic_vector(9 downto 0);
          RDADDR : In std_logic_vector(9 downto 0);
          WRDATA : In std_logic_vector(15 downto 0);
          RDDATA : Out std_logic_vector(15 downto 0) );
end SRAM;

architecture RTL of SRAM is

  subtype RAMWORD is std_logic_vector(15 downto 0);
  type RAMARRAY is array (0 to 2**10 - 1) of RAMWORD;
  signal RAMDATA : RAMARRAY;
  signal wraddr_int : integer range 0 to 2**10 - 1;
  signal rdaddr_int : integer range 0 to 2**10 - 1;
  signal wraddr_sig : unsigned(9 downto 0);
  signal rdaddr_sig : unsigned(9 downto 0);

begin 

-------------------------------------------------------------------
gen_addr_sig : process( WRADDR, RDADDR )
begin 
  for i in 9 downto 0 loop
    wraddr_sig(i) <= WRADDR(i);
    rdaddr_sig(i) <= RDADDR(i);
  end loop;
end process gen_addr_sig;
 
--------------------------------------------------------------
  wraddr_int <= conv_integer(wraddr_sig);
  rdaddr_int <= conv_integer(rdaddr_sig);

--------------------------------------------------------------
wr_data : process(CLK)
begin 
  if(CLK'event and CLK = '1') then
    if(CS_N = '0' and WR_N = '0') then
      RAMDATA(wraddr_int) <= WRDATA;
    end if;
  end if;
end process wr_data;

--------------------------------------------------------------
rd_data : process(CLK) 
begin 
  if(CLK'event and CLK = '1') then
    if(CS_N = '0' and WR_N = '1') then
      RDDATA <= RAMDATA(rdaddr_int);
    else
      RDDATA <= (others => '0');
    end if;
  end if;
end process rd_data;

end; 
