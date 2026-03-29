module estado_do_cofre(
	input senha_valida, confirmar, chave_mestra, modo, fechar, reset, clk,
	output reg [6:0] estadocofre1,estadocofre2,
	output reg [6:0] situacaoerro1,situacaoerro2,
	output reg [1:0] saida_estado
);
	//módulo que conta a quantidade de erros
	wire [1:0] qtd_erros;
	erros error(.confirmar(confirmar),.reset(reset),.modo(modo),.clk(clk),.senha_valida(senha_valida),.chave_mestra(chave_mestra)
	,.estado(estado_atual),.erros(qtd_erros));
	
	//Parâmetros para os estados
	localparam FECHADO   = 2'b00;
   localparam ABERTO    = 2'b01;
   localparam BLOQUEADO = 2'b10;

	reg [1:0] estado_atual,prox_estado;
	reg acionar;
	//Lógica para transição de estados do cofre
	always @(*) begin
		prox_estado = estado_atual;
		acionar = 1'b0;
		//Verifica se o modo está em abertura local
		if (modo) begin
			case (estado_atual)
				FECHADO: begin
					if (qtd_erros == 2'b11) begin
						prox_estado = BLOQUEADO;
						acionar = 1'b1;
					end else if (senha_valida) begin
						prox_estado = ABERTO;
					end
				end
				
				ABERTO: begin
					if (fechar) begin
						prox_estado = FECHADO;
					end else begin
						prox_estado = ABERTO;
					end
				end
				
				BLOQUEADO: begin
					if (chave_mestra) begin
						prox_estado = ABERTO;
					end else begin
						prox_estado = BLOQUEADO;
					end
				end
			endcase
		end
		//Caso não, está em abertura remota
		else begin
			if (estado_atual == ABERTO) begin
				if (fechar) begin
					prox_estado = FECHADO;
				end
			end else begin
				if (chave_mestra) begin
					prox_estado = ABERTO;
				end
			end
		end
	end
	
	//Circuito sequencial para armazenar o próximo estado no estado atual ou resetar
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			estado_atual <= ABERTO;
			saida_estado <= ABERTO;
		end else if (confirmar || acionar) begin
			estado_atual <= prox_estado;
			saida_estado <= prox_estado;
		end
	end
	
	//Saídas para os displays de 7 segmentos
	always @(*) begin
		case (estado_atual)
			//Cofre AB (aberto)
			ABERTO: begin
				estadocofre1 = 7'b0001000;
				estadocofre2 = 7'b0000011;
			end
			//Cofre FE (fechado)
			FECHADO: begin
				estadocofre1 = 7'b0001110;
				estadocofre2 = 7'b0000110;
			end
			//Cofre EM (emergência)
			BLOQUEADO: begin
				estadocofre1 = 7'b0000110;
				estadocofre2 = 7'b0101010;
			end
			//default
			default: begin
				estadocofre1 = 7'b0111111;
				estadocofre2 = 7'b0111111;
			end
		endcase
		
		case (qtd_erros)
			//ERROS = 0
			2'b00: begin
				situacaoerro1 = 7'b0111111;
				situacaoerro2 = 7'b0111111;
			end
			//ERROS = 1
			2'b01: begin
				situacaoerro1 = 7'b0000110;
				situacaoerro2 = 7'b1111001;
			end
			//ERROS = 2
			2'b10: begin
				situacaoerro1 = 7'b0000110;
				situacaoerro2 = 7'b0100100;
			end
			//BLOQUEADO
			2'b11: begin
				situacaoerro1 = 7'b0000011;
				situacaoerro2 = 7'b1000111;
			end
			//default
			default: begin
				situacaoerro1 = 7'b0111111;
				situacaoerro2 = 7'b0111111;
			end
		endcase	
	end
	
endmodule