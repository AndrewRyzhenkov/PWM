`timescale 1ns / 1ps

module tb_VGA_top;

    // Входы (Inputs)
    logic clk_100m;
    logic btn_rst_n;
    logic pulse;
    
    // Данные датчиков
    logic [7:0] temp_int;
    logic [7:0] temp_dec;
    logic [7:0] dist_int;
    logic [7:0] dist_dec;
    logic [7:0] hum_int;
    
    // Выходы (Outputs)
    logic vga_hsync;
    logic vga_vsync;
    logic vga_r;
    logic vga_g;
    logic vga_b;

    integer f;

    // Подключение тестируемого модуля (DUT)
    VGA_top uut (
        .clk_100m(clk_100m),
        .btn_rst_n(btn_rst_n),
        .pulse(pulse),
        .temp_int(temp_int),
        .temp_dec(temp_dec),
        .dist_int(dist_int),
        .dist_dec(dist_dec),
        .hum_int(hum_int),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

    // 1. Генерация клока 100 МГц (Период 10нс)
    initial begin
        clk_100m = 0;
        forever #5 clk_100m = ~clk_100m;
    end

    // 2. Основной сценарий теста
    initial begin
        // Инициализация файла
        f = $fopen("vga_dump.csv", "w");
        $fwrite(f, "Time,Hsync,Vsync,R,G,B,Switch\n");

        // Инициализация сигналов
        btn_rst_n = 0;
        pulse = 0; // Начало: Режим Температуры
        
        // Задаем тестовые данные
        temp_int = 8'd24;   // 24 градуса
        temp_dec = 8'd2;    // .2
        dist_int = 8'd222;  // 222 метра
        dist_dec = 8'd1;    // .1
        hum_int  = 8'd75;   // 75%

        // Сброс (ждем 100 нс)
        #100;
        btn_rst_n = 1;
        $display("Reset released. Starting simulation in TEMP mode (switch=0).");

        // === ЭТАП 1: Работаем 50 мкс в режиме Температуры ===
        // 50 us = 50,000 ns
        #50000000;
        
        // === ЭТАП 2: Переключаем режим ===
        pulse = 1; // Режим Расстояния
        #100
        pulse = 0;
        $display("Time: %0t - Switching to DISTANCE mode (switch=1).", $time);
        
        // === ЭТАП 3: Работаем еще 50 мкс в режиме Расстояния ===
        #50000000;

        // Завершение
        $fclose(f);
        $display("Simulation finished.");
        $finish;
    end

    // 3. Логгирование в CSV
    always @(vga_hsync or vga_vsync or vga_r or vga_g or vga_b) begin
        if (btn_rst_n) begin
            $fwrite(f, "%0t,%b,%b,%h,%h,%h,%b\n", $time, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, pulse);
        end
    end

endmodule