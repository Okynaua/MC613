module bin11_to_bcd (
    input  [10:0] bin,   // 0..2047
    output reg [15:0] bcd    // milhar | centena | dezena | unidade
);

    always @(*) begin
        // Variáveis internas para processamento (equivalente ao variable do VHDL)
        integer i;
        reg [15:0] acc;
        
        acc = 16'b0;

        for (i = 10; i >= 0; i = i - 1) begin
            
            // Lógica de "ajuste" (Add 3 se o dígito for > 4)
            if (acc[3:0]   > 4) acc[3:0]   = acc[3:0]   + 3;
            if (acc[7:4]   > 4) acc[7:4]   = acc[7:4]   + 3;
            if (acc[11:8]  > 4) acc[11:8]  = acc[11:8]  + 3;
            if (acc[15:12] > 4) acc[15:12] = acc[15:12] + 3;

            // Shift à esquerda concatenando o bit atual de bin
            acc = {acc[14:0], bin[i]};
        end
        
        bcd = acc;
    end

endmodule