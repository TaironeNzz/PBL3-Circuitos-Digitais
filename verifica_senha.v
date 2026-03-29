module verifica_senha(
	input [3:0] senha,
	input [1:0] estado,
	input confirmar, reset, clk,
	output reg senha_valida,
	output reg ledsenha
);
	//Registrar a senha atual
	reg [3:0] senha_atual;
	
	//fio para verificar se quer alterar a senha
	reg alterar;

	//Lógica para mudar senha
	always @(negedge clk or posedge reset) begin
		ledsenha <= alterar;
		if (reset) begin
			if (estado == 2'b01) begin
				senha_atual <= 4'b0000;
				alterar <= 1'b0;
			end
		end
		else if (confirmar) begin
			if (estado == 2'b01) begin
				alterar <= 1'b1;
				if (alterar == 1'b1) begin
					senha_atual <= senha;
					alterar <= 1'b0;
				end
			end else begin
				alterar <= 1'b0;
			end
		end
	end
	
	//Lógica para verificar senha
	always @(posedge confirmar or posedge reset) begin
		if (reset) begin
			senha_valida <= 1'b0;
		end
		else if (confirmar) begin
			if (estado == 2'b00) begin
				if (senha == senha_atual) begin
					senha_valida <= 1'b1;
				end else begin
					senha_valida <= 1'b0;
				end
			
			end
		end
	end
endmodule
