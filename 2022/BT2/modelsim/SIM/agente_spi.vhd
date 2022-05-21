--Autor DTE
--v2: LX0809 G4 Lukas
--Cambios realizados:
	--Ahora el dato que se envia viene de otro simulador. De esta forma se consigue un test mas completo

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity agente_spi is
port(--pos_X:   in std_logic_vector(1 downto 0);
     --pos_Y:   in std_logic_vector(1 downto 0);
	 reg_miso_slave: in std_logic_vector(31 downto 0);	--Registro donde meter el dato a enviar desde orquestador
	 load_reg_slave: in std_logic;	--Señal de carga de registro en buffer de desplazamiento
     nCS:     in     std_logic;                      -- chip select
     SPC:     in     std_logic;                      -- clock SPI (5 MHz) 
     SDI:     in     std_logic;                      -- Slave Data input  (connected to Master SDO)
     SDO:     buffer std_logic);                     -- Slave Data Output (connected to Slave SDI)
     
end entity;

architecture sim of agente_spi is
  type t_estado is(reposo, byte_1st_Rd, byte_1st_Wr, enviar_lecturas, registrar_comando);
  signal estado: t_estado;

  signal reg_comandos: std_logic_vector(7 downto 0) := X"00";
  signal reg_lecturas: std_logic_vector(31 downto 0); --:= X"4000_80ff"; --offset 1, -2
  signal cnt_rd_muestras: natural := 0;

--  function calcular_reg_lectura(signal pos_X: in std_logic_vector(1 downto 0);
--                                signal pos_Y: in std_logic_vector(1 downto 0)) return std_logic_vector is
--
--    constant horizontal:    std_logic_vector(9 downto 0) := "0001011101";                   -- (93) mod < 150
--    constant inclinado_neg: std_logic_vector(9 downto 0) := "1100101000";                   -- (-216) mod < -150
--    constant inclinado_pos: std_logic_vector(9 downto 0) := "0011101000";                   -- (232) mod > 150
--
--    variable dato_X: std_logic_vector(15 downto 0);
--    variable dato_Y: std_logic_vector(15 downto 0);
--   
--    variable cadena: std_logic_vector(31 downto 0);
--  begin
--    case pos_X is 
--      when "00"   => dato_X := horizontal(1 downto 0)    & "000000" & horizontal(9 downto 2);
--      when "10"   => dato_X := inclinado_neg(1 downto 0) & "000000" & inclinado_neg(9 downto 2);
--      when others => dato_X := inclinado_pos(1 downto 0) & "000000" & inclinado_pos(9 downto 2);
--
--    end case;
--
--    case pos_Y is 
--      when "00"   => dato_Y := horizontal(1 downto 0)    & "000000" & horizontal(9 downto 2);
--      when "10"   => dato_Y := inclinado_neg(1 downto 0) & "000000" & inclinado_neg(9 downto 2);
--      when others => dato_Y := inclinado_pos(1 downto 0) & "000000" & inclinado_pos(9 downto 2);
--
--    end case;
--
--    cadena := (dato_X & dato_Y);
--    return cadena;
--    
--  end function;

begin

process(nCS, SPC)
  variable cnt_bits: natural := 0;
  
begin
  if nCS = '1' then                     -- Esclavo en reposo
    cnt_bits := 0;
    estado <= reposo;

  elsif SPC'event and SPC = '1' then    -- flanco de subida del reloj SPI
    cnt_bits := cnt_bits + 1;
    if cnt_bits = 1 then
      if SDI = '1' then
        estado <= byte_1st_Rd;
        cnt_rd_muestras <= cnt_rd_muestras + 1;

      else
        estado <= byte_1st_Wr;

      end if;

    elsif cnt_bits = 8 then 
      if estado = byte_1st_Rd then
        estado <= enviar_lecturas;

      else
        estado <= registrar_comando;

      end if;
    end if;
  end if;
end process;
--------------------------------------------------------------------
process(SPC, load_reg_slave)
begin
	if(SPC'event and nCS = '0') then
		if estado = registrar_comando and SPC = '1' then
			reg_comandos <= reg_comandos(6 downto 0) & SDI;
		elsif estado = enviar_lecturas and SPC = '0' then
			SDO <= reg_lecturas(31) after 25 ns;
			reg_lecturas <= reg_lecturas(30 downto 0)&reg_lecturas(31);
		end if;
	elsif(nCS'event and nCS = '1') then
		SDO <= '1';
	elsif(load_reg_slave'event and load_reg_slave = '1' and nCS = '1') then
		reg_lecturas <= reg_miso_slave;
	end if;
end process;
--------------------------------------------------------------------

--process
--begin
--  
--  if nCS = '0' then
--    wait until nCS'event or SPC'event;
--      if SPC'event then
--        if estado = rsegistrar_comando and SPC = '1' then
--          reg_comandos <= reg_comandos(6 downto 0) & SDI;
--
--        elsif estado = enviar_lecturas and SPC = '0' then
--          SDO <= reg_lecturas(31) after 25 ns;
--          reg_lecturas <= reg_lecturas(30 downto 0)&reg_lecturas(31);
--
--        end if;
--      end if;
--
--  else
--    SDO <= '1';
--	if load_reg_slave'event and load_reg_slave = '1' then
--		reg_lecturas <= reg_miso_slave;
--  	end if;
--
--  end if;
--
--end process;
--


end sim;





