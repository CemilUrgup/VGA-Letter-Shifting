----------------------------- VGA.vhd --------------------------------
--                         Bertan Taþkýn
--                           4.10.2017
--                          Versiyon 2.0
--
-- VGA kontrolcüsü. Zamanlama parametreleri generic kýsmýndan ayarlanabilir.
-- BufferAddress sinyali o anki pixelin buffer'daki adresini belirtir.
-- BufferAddress belirtildikten 1 cycle sonra BufferData'dan veriler okunur.
--
--
-- Version Notes
--
-- Versiyon 1.0 (23.4.2017): Ýlk sürüm.
--
-- Versiyon 2.0 (4.10.2017): HSync ve VSync'deki zamanlama hatalarý
--  düzeltildi.
--      Zamanlama parametreleri generic kýsmýna taþýndý.
--    DE(Data Enabe) çýkýþý eklendi.
--    BufferAddress(eski X, Y) ile BufferData(eski R, G, B) arasýna
--    1 cycle eklendi.
--    Kod daha sade bir þekilde tekrar yazýldý.
--
 
--Kütüphaneler
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 
 
entity VGA is
    generic(HorizontalVisibleArea : natural := 1440; --Zamanlama Parametreleri
        HorizontalFrontPorch : natural := 80;
        HorizontalSyncPulse : natural := 152;
       HorizontalBackPorch : natural := 232;
        VerticalVisibleArea : natural := 900;
        VerticalFrontPorch : natural := 1;
        VerticalSyncPulse : natural := 3;
        VerticalBackPorch : natural := 28;  
        HorizontalSyncPolarity : std_logic := '1';   --Sync Polariteleri
        VerticalSyncPolarity : std_logic := '1';
        RGBLength : integer := 4);                                                                                    
    port(PixelClk, Enable : in std_logic;             --Pixel Clock ve Enable Giriþi
        red_0: out std_logic := '0';
        red_1: out std_logic := '0';
        red_2: out std_logic := '0';
        red_3: out std_logic := '0';
        blue_0: out std_logic := '0';
        blue_1: out std_logic := '0';
        blue_2: out std_logic := '0';
        blue_3: out std_logic := '0';
        green_0: out std_logic := '0';
        green_1: out std_logic := '0';
        green_2: out std_logic := '0';
        green_3  : out std_logic;        --RGB Çýkýþlarý
        HSync, VSync : out std_logic := '0'                               --HSync ve VSync Çýkýþý
--        DE : out std_logic;                                            --Data Enable Çýkýþý
--        BufferAddress : out std_logic_vector(31 downto 0);             --Buffer Address Çýkýþý
--        BufferData : in std_logic_vector(RGBLength * 3 - 1 downto 0)
        ); --Buffer Data Giriþi
end VGA;
 
architecture Behavioral of VGA is
     
    --Toplam yatay pixel
    constant HorizontalWholeLine : integer := HorizontalVisibleArea + HorizontalFrontPorch + HorizontalSyncPulse + HorizontalBackPorch;
    --Toplam dikey pixel
    constant VerticalWholeLine : integer := VerticalVisibleArea + VerticalFrontPorch + VerticalSyncPulse + VerticalBackPorch;
    
    signal HCount : natural range 0 to HorizontalWholeLine - 1 := 0;
    signal VCount : natural range 0 to VerticalWholeLine - 1 := 0;
    signal HPulse, VPulse : std_logic := '0';
    signal HVisible, VVisible : std_logic :='0';
    signal BufferData: std_logic_vector(RGBLength * 3 - 1 downto 0) := "111100000000";
    signal counter: integer := 0;
    signal Red, Green, Blue: unsigned (RGBLength - 1 downto 0);
    signal color_counter: integer := 0;
    signal x: integer := 570;
    signal y: integer := 600;
    signal z: integer := 870;
    type direction_type_h is (right, left);
    type direction_type_v is (up, down);
    signal direction_h: direction_type_h := right;
    signal direction_v: direction_type_v := up;
    signal slow_clk: std_logic;
    signal clock_counter: integer := 0;
    signal i: integer := 0;
    signal a: integer := 300;
    signal b: integer := 330;
    signal c: integer := 570;
    signal d: integer := 600;
     
begin
 
    --BufferAddress'in hesaplanmasý
--    BufferAddress <= std_logic_vector(to_unsigned(VCount * HorizontalVisibleArea + HCount, 32));
     
process(PixelClk, slow_clk)
begin
    
if rising_edge(PixelClk) then

    if clock_counter < 79999 then
        clock_counter <= clock_counter + 1;
    else
        clock_counter <= 0;
        slow_clk <= not slow_clk;
    end if;
        
end if;

if rising_edge(slow_clk) then

    case  i is
    when 0 | 1 | 2 | 3 | 4 =>
        
        case direction_h is
        when right =>
        if z < 1440 and (z /= 870) then
            x <= x+1;
            y <= y+1;
            z <= z+1;
            direction_h <= right;
        elsif z = 870 then
            x <= x+1;
            y <= y+1;
            z <= z+1;
            i <= i + 1;
            direction_h <= right;            
        else
            direction_h <= left;
        end if;
        when left =>
        if z > 300 and (z /= 870) then
            x <= x-1;
            y <= y-1;
            z <= z-1;
            direction_h <= left;
        elsif (z = 870) then
            x <= x-1;
            y <= y-1;
            z <= z-1;
            i <= i + 1;
        direction_h <= left;
        else
            direction_h <= right;

        end if;
        end case;
    when 5 | 6 | 7 | 8 | 9 =>
    
        case direction_v is
    when down =>
    if d < 900 and (d /=600) then
        a <= a+1;
        b <= b+1;
        c <= c+1;
        d <= d+1;
        direction_v <= down;
    elsif d = 600 then
        a <= a+1;
        b <= b+1;
        c <= c+1;
        d <= d+1;
        direction_v <= down;
        i <= i + 1;
    else
        direction_v <= up;
    end if;
    when up =>
    if d > 300 and (d /=600) then
        a <= a-1;
        b <= b-1;
        c <= c-1;
        d <= d-1;
        direction_v <= up;
    elsif d = 600 then
        a <= a-1;
        b <= b-1;
        c <= c-1;
        d <= d-1;
        direction_v <= up;
        i <= i + 1;
    else
        direction_v <= down;

    end if;
    end case;
    
    when others =>
        i <= 0;
        
    end case;
    

    
end if;
    
    if rising_edge(PixelClk) then
    
        if VCount < a then
        
            BufferData <= "000000001111";
        
        elsif VCount < b then
        
            if HCount < x then
                BufferData <= "000000001111";
            elsif (HCount > x-1) and (HCount < z) then
                BufferData <= "111100000000";
            elsif (HCount > z-1)  and (HCount < 1903) then
                BufferData <= "000000001111";
                end if;
                
        elsif VCount < c then
        
            if HCount < x then
            BufferData <= "000000001111";
            elsif (HCount > x-1) and (HCount < y) then
                BufferData <= "111100000000";
            elsif (HCount > y-1)  and (HCount < 1903) then
                BufferData <= "000000001111";
            end if;
            
        elsif VCount < d then
        
            if HCount < x then
            BufferData <= "000000001111";
            elsif (HCount > x-1) and (HCount < z) then
                BufferData <= "111100000000";
            elsif (HCount > z-1)  and (HCount < 1903) then
                BufferData <= "000000001111";
            end if;
        
        else
        
            BufferData <= "000000001111";
               
        end if;
    
    end if;
    
        if rising_edge(PixelClk) then
        
        if Enable = '1' then
             
            --HCount arttýrýlýr
            if HCount < HorizontalWholeLine - 1 then
                HCount <= HCount + 1;
            else
                --HCount sona ulaþtýðýnda resetlenir ve VCount arttýrýlýr
                HCount <= 0;
                if VCount < VerticalWholeLine - 1 then
                    VCount <= VCount + 1;
                else
                    VCount <= 0;
                end if;
            end if; 
             
            --HCount visible area içindeyse HVisible setlenir
            if HCount < HorizontalVisibleArea then
                HPulse <= '0';
                HVisible <= '1';
            elsif HCount < HorizontalVisibleArea + 
                                HorizontalFrontPorch then
                HPulse <= '0';
                HVisible <= '0';
            --HCount pulse alaný içindeyse HPulse setlenir.
            elsif HCount < HorizontalVisibleArea +
                                HorizontalFrontPorch +
                                HorizontalSyncPulse then
                HPulse <= '1';
                HVisible <= '0'; 
            elsif HCount < HorizontalWholeLine then
                HPulse <= '0';
                HVisible <= '0';
            end if;
             
            --VCount visible area içindeyse VVisible setlenir
            if VCount < VerticalVisibleArea then
                VPulse <= '0';
                VVisible <= '1';
            elsif VCount < VerticalVisibleArea + 
                                VerticalFrontPorch then
                VPulse <= '0';
                VVisible <= '0';
            --VCount pulse alaný içindeyse VPulse setlenir.
            elsif VCount < VerticalVisibleArea +
                                VerticalFrontPorch +
                                VerticalSyncPulse then
                VPulse <= '1';   
                VVisible <= '0';
            elsif VCount < VerticalWholeLine then
                VPulse <= '0';   
                VVisible <= '0';
            end if; 
             
            --Horizontal pulse üretimi
            if HPulse = '1' then
                HSync <= HorizontalSyncPolarity;
            else
                HSync <= not HorizontalSyncPolarity;
            end if;
             
            --Vertical pulse üretimi
            if VPulse = '1' then
                VSync <= VerticalSyncPolarity;
            else
                VSync <= not VerticalSyncPolarity;
            end if;
                     
            --Her iki yönde de visible alan içindeyse RGB sinyalleri gönderilir ve
            --Data Enable setlenir
            if HVisible = '1' and VVisible = '1' then      
                Red <= unsigned(BufferData(RGBLength * 3 - 1 downto RGBLength * 2));
                Green <= unsigned(BufferData(RGBLength * 2 - 1 downto RGBLength));
                Blue <= unsigned(BufferData(RGBLength - 1 downto 0));
                red_0 <= Red(0);
                red_1 <= Red(1);
                red_2 <= Red(2);
                red_3 <= Red(3);
                blue_0 <= Blue(0);
                blue_1 <= Blue(1);
                blue_2 <= Blue(2);
                blue_3 <= Blue(3);
                green_0 <= Green(0);
                green_1 <= Green(1);
                green_2 <= Green(2);
                green_3 <= Green(3);
--                DE <= '1';
            --Her iki yönde en az biri visible alan dýþýndaysa RGB ve Data Enable
            --resetlenir
            else           
                Red <= to_unsigned(0, RGBLength);
                Green <= to_unsigned(0, RGBLength);
                Blue <= to_unsigned(0, RGBLength);
                red_0 <= Red(0);
                red_1 <= Red(1);
                red_2 <= Red(2);
                red_3 <= Red(3);
                blue_0 <= Blue(0);
                blue_1 <= Blue(1);
                blue_2 <= Blue(2);
                blue_3 <= Blue(3);
                green_0 <= Green(0);
                green_1 <= Green(1);
                green_2 <= Green(2);
                green_3 <= Green(3);
--                DE <= '0';               
            end if;
            
            else
            
            color_counter <= 0;
            HCount <= 0;
            VCount <= 0;
            BufferData <= "000000000000";
                         
            end if;
                         
        end if;

    end process;
 
end Behavioral;
