class ral_reg_bank_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ral_reg_bank_scoreboard)

  //Error counter and correct counter
  int err_cnt, crr_cnt;

  //TLM HANDLE
  uvm_analysis_imp #(ral_reg_bank_seq_item,ral_reg_bank_scoreboard) item_collect_export;

  //CONSTRUCTOR
  function new(string name = "ral_reg_bank_scoreboard", uvm_component parent);
    super.new(name,parent);
    item_collect_export = new ("item_collect_export", this);
  endfunction

  //WRITE FUNCTION
  function void write(ral_reg_bank_seq_item req);
  case (req.register_addr)
    3'b000: begin
              if(req.write_enable && !req.read_enable)
                compare(req, req.OP1, "FPU_OP1");
            end
    3'b001: begin
              if(req.write_enable && !req.read_enable)
                compare(req, req.OP2, "FPU_OP2");
            end
    3'b010: begin
              if(req.write_enable && !req.read_enable) begin
                //masking the data to get only the 3 LSBs for the OP select
                req.actual_mem_data = req.actual_mem_data & 32'h0000_0007;
                compare(req, req.OP_select, "FPU_OP_SELECT");
              end
            end
    3'b011: begin
              if(req.read_enable && !req.write_enable)
                compare(req, req.PRDATA, "APB_PRDATA");
            end
    3'b100: begin
              if(req.read_enable && !req.write_enable)
                compare(req, req.PRDATA, "APB_PRDATA");
            end
    default: `uvm_error("INVALID ADDRESS", $sformatf("Address 0x%8h is invalid", req.register_addr))
  endcase
  endfunction

  //==================================================================================
  // Function: Compare
  //==================================================================================
  function void compare(input ral_reg_bank_seq_item my_seq, input logic [31:0] expected_mem_data,
                        string block);
    if (my_seq.actual_mem_data != expected_mem_data) begin
      err_cnt++;
      `uvm_fatal(block, $sformatf(
                  "Mismatch in MEMORY DATA: in MEMORY 0x%8h, RESULT 0x%8h",
                  my_seq.actual_mem_data,
                  expected_mem_data
                  ));
    end else begin
      crr_cnt++;
    end
  endfunction

  //FUNCTION: REPORT PHASE
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("RAL_REG_BANK_SCOREBOARD", $sformatf("\n\nRAL REGISTER BANK SCOREBOARD SUMMARY:\n%s", `DASH_LINE), UVM_NONE)
    `uvm_info("RAL_REG_BANK_SCOREBOARD", $sformatf("Successful Cases = %0d", crr_cnt), UVM_NONE)
    `uvm_info("RAL_REG_BANK_SCOREBOARD", $sformatf("Failed Cases = %0d", err_cnt), UVM_NONE)
    `uvm_info("RAL_REG_BANK_SCOREBOARD", $sformatf("DONE\n%s", `DASH_LINE), UVM_NONE)
  endfunction


endclass
