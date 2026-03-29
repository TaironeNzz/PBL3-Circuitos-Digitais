module estado_de_senha(
	input ch1,
	output reg [6:0] display1,display2
);

	always @(*) begin
		if (ch1) begin
			//modo AL (abertura local)
			display1 = 7'b0001000;
			display2 = 7'b1000111;
		end else begin
			//modo PF (programação remota)
			display1 = 7'b0001100;
			display2 = 7'b0001110;
		end
	end

endmodule