`timescale 1ns/1ps

module dram_controller_init_tb;

reg clk;
reg reset;

wire [15:0] data;
wire [7:0] data_to_iface;

wire handshake;
wire ready;
wire [5:0] current_state;

wire CS;
wire RAS;
wire CAS;
wire WE;
wire [12:0] A;

dram_controller dut(
    .clk(clk),
    .reset(reset),
    .add(26'b0),
    .data(data),
    .data_from_iface(8'b0),
    .data_to_iface(data_to_iface),
    .req(1'b0),
    .wEn(1'b0),
    .handshake(handshake),
    .ready(ready),
    .current_state(current_state),

    .CS(CS),
    .RAS(RAS),
    .CAS(CAS),
    .WE(WE),

    .BA(),
    .A(A),
    .DQM(),
    .CKE()
);

assign data = 16'hZZZZ;

always #10 clk = ~clk;

integer refresh_count;

initial begin
	 $display("==== INICIO dram_controller_init_tb ====\n");
    clk = 0;
    reset = 0;
    refresh_count = 0;

    $display("=== TESTE DE INICIALIZACAO DA SDRAM ===\n");

    #20;
    reset = 1;

    // acelera a simulação
    //force dut.wait_compare = 16'd1;

    wait(current_state == dut.READY);
	 
	 
	 repeat(4) @(posedge clk);	 
	 

    $display("Refreshes executados = %0d", refresh_count);
	 
    #50;
	 
	 $display("\n==== FIM dram_controller_init_tb ====");
    $finish;
end

//--------------------------------------------------
// Decodificador de comandos SDRAM
//--------------------------------------------------

function [127:0] command_name;
input cs;
input ras;
input cas;
input we;
begin

    if(cs==0 && ras==1 && cas==1 && we==1)
        command_name = "NOP";

    else if(cs==0 && ras==0 && cas==1 && we==0)
        command_name = "PRECHARGE";

    else if(cs==0 && ras==0 && cas==0 && we==1)
        command_name = "AUTO_REFRESH";

    else if(cs==0 && ras==0 && cas==0 && we==0)
        command_name = "LOAD_MODE_REG";

    else if(cs==0 && ras==0 && cas==1 && we==1)
        command_name = "ACTIVATE";

    else
        command_name = "OTHER";
end
endfunction

//--------------------------------------------------
// Nome dos estados INIT
//--------------------------------------------------

function [127:0] state_name;
input [5:0] s;
begin
    case(s)

        6'd0:  state_name = "INIT";
        6'd1:  state_name = "INIT1";
        6'd2:  state_name = "INIT2";
        6'd3:  state_name = "INIT3";
        6'd4:  state_name = "INIT4";
        6'd5:  state_name = "INIT5";
        6'd6:  state_name = "INIT6";
        6'd7:  state_name = "INIT7";
        6'd8:  state_name = "INIT8";
        6'd9:  state_name = "INIT9";
        6'd10: state_name = "INIT10";
        6'd11: state_name = "INIT11";
        6'd12: state_name = "INIT12";
        6'd13: state_name = "INIT13";
        6'd14: state_name = "INIT14";
        6'd15: state_name = "INIT15";
        6'd16: state_name = "INIT16";
        6'd17: state_name = "INIT17";
        6'd18: state_name = "INIT18";
        6'd19: state_name = "INIT19";
        6'd20: state_name = "INIT20";
        6'd21: state_name = "INIT21";
        6'd62: state_name = "READY";

        default:
            state_name = "OTHER";

    endcase
end
endfunction

//--------------------------------------------------
// Contagem de refreshes
//--------------------------------------------------

always @(posedge clk) begin

    if(CS==0 && RAS==0 && CAS==0 && WE==1) begin
        refresh_count = refresh_count + 1;

        $display(
            "T=%0t | REFRESH #%0d",
            $time,
            refresh_count
        );
    end

end

//--------------------------------------------------
// Log detalhado
//--------------------------------------------------

initial begin
    $monitor(
        "T=%0t | %-10s | CMD=%s | ready=%b | refresh_cnt=%0d",
        $time,
        state_name(current_state),
        command_name(CS,RAS,CAS,WE),
        ready,
        refresh_count
    );
end

endmodule