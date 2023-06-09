`include "define.v"

module eximm(                                                         //one of choice to op_b
    //from id
    input   wire            [31:0]  id_inst_i,
    //to id
    output  reg             [31:0]  eximm_eximm_o
);

    wire [6:0]  opcode = id_inst_i[6:0];
    wire [2:0]  func3  = id_inst_i[14:12];

    always @(*) begin
        case(opcode)
            
            `Itype_J,`Itype_L,`Itype_A:begin
                eximm_eximm_o = { {20{id_inst_i[31]}} , id_inst_i[31:20]};
            end

            `Itype_C:begin

                case(func3)
                    `I_CSRRW,`I_CSRRS,`I_CSRRC:begin
                        eximm_eximm_o = 32'b0;
                    end

                    `I_CSRRWI,`I_CSRRSI,`I_CSRRCI:begin
                        eximm_eximm_o = {{27{1'b0}}, id_inst_i[19:15]};
                    end

                    default:
                        eximm_eximm_o = 32'b0;

                endcase
                
            end

            `Utype_A,`Utype_L:begin
                eximm_eximm_o = {id_inst_i[31:12] , {12{1'b0}} };
            end

            `Jtype_J:begin
                eximm_eximm_o = { {11{id_inst_i[31]}}, id_inst_i[31], 
                                    id_inst_i[19:12], id_inst_i[20], id_inst_i[30:21], {1'b0} };    
            end

            `Btype:begin
                eximm_eximm_o = { {19{id_inst_i[31]}}, id_inst_i[31], id_inst_i[7],
                                    id_inst_i[30:25], id_inst_i[11:8], {1'b0} };
            end

            `Stype:begin
                eximm_eximm_o = { {20{id_inst_i[31]}} , id_inst_i[31:25], id_inst_i[11:7] };
            end
            
            default:eximm_eximm_o = 32'h0;
        endcase
    end


endmodule