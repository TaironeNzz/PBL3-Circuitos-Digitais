module principal(
	input [3:0] senha,
	input confirmar,chave_modo,chave_mestra,reset,fechar, clk,
	output ledsenha,
	output [6:0] modosenha1,modosenha2,
	output [6:0] display_cofre1,display_cofre2,
	output [6:0] display_erro1,display_erro2
);
	//Negação dos botões porque eles são forçados a 1
	wire notreset,notconfirmar;
	not not1(notreset,reset);
	not not2(notconfirmar,confirmar);
	//Debounce para o botão de confirmar
	reg confirmar_d;
   wire confirmar_pulse;
   always @(posedge clk or posedge notreset)
       if (notreset)
			confirmar_d <= 1'b0;
       else
			confirmar_d <= notconfirmar;
   assign confirmar_pulse = notconfirmar & ~confirmar_d;
	
	//Fios para os módulos instanciados
	wire [1:0] estado;
	wire senha_valida;
	//modo de entrada de senha (local ou remoto)
	estado_de_senha senhaa(.ch1(chave_modo),.display1(modosenha1),
	.display2(modosenha2));
	//Módulo para verificar senha ou alterar
	verifica_senha verificacao(.senha(senha),.estado(estado),.confirmar(confirmar_pulse),
	.reset(notreset),.clk(clk),.ledsenha(ledsenha),.senha_valida(senha_valida));
	//Módulo para mudar os estados do cofre
	estado_do_cofre estadocofree(.senha_valida(senha_valida),.confirmar(confirmar_pulse),.chave_mestra(chave_mestra),
	.modo(chave_modo),.fechar(fechar),.reset(notreset),.clk(clk),.estadocofre1(display_cofre1),.estadocofre2(display_cofre2),
	.situacaoerro1(display_erro1),.situacaoerro2(display_erro2),.saida_estado(estado));
	
endmodule
