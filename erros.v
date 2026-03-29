module erros (
	input confirmar, reset, modo, clk,
	input senha_valida,
	input chave_mestra,
	input [1:0] estado,
	output reg [1:0] erros
);
	//Fios para os estados de erros
	reg [1:0] prox_erro,atual_erro;
	
	//Parâmetros para os estados de erros
	localparam NONE   = 2'b00;
   localparam ERRO1  = 2'b01;
   localparam ERRO2  = 2'b10;
	localparam BLOQUEADO = 2'b11;
	
	//Lógica para transição de estado do erro
	always @(*) begin
		prox_erro = atual_erro;
		//verifica se está em abertura local
		if (modo) begin
			if (estado == 2'b01) begin
				prox_erro = NONE;
			end else begin
				case (atual_erro)
					NONE: begin
						if (!senha_valida) begin
							prox_erro = ERRO1;
						end else begin
							prox_erro = NONE;
						end
					end
					
					ERRO1: begin
						if (!senha_valida) begin
							prox_erro = ERRO2;
						end else begin
							prox_erro = NONE;
						end
					end
					
					ERRO2: begin
						if (!senha_valida) begin
							prox_erro = BLOQUEADO;
						end else begin
							prox_erro = NONE;
						end
					end
					
					BLOQUEADO: begin
						if (chave_mestra) begin
							prox_erro = NONE;
						end
					end
				endcase
			end
		//Caso não, vai para abertura remota
		end else begin
			if (chave_mestra) begin
				prox_erro = NONE;
			end else begin
				prox_erro = atual_erro;
			end
		end
	end
	
	//Circuito sequencial para armazenar o próximo estado de erro ou resetar
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			atual_erro <= NONE;
			erros <= NONE;
		end else if (confirmar) begin
			atual_erro <= prox_erro;
			erros <= prox_erro;
		end
	end
	
endmodule