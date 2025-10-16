//DECLARING IMPLEMENTATION ANAYLSIS PORT
`uvm_analysis_imp_decl(_MON_IN)
`uvm_analysis_imp_decl(_MON_OUT)

class fpu_scoreboard extends uvm_scoreboard;
  //FACTORY REGISTERATION
  `uvm_component_utils(fpu_scoreboard)

// SEQ ITEMS QUEUES
  fpu_seq_item m_seq_item_in_q[$],
              m_seq_item_out_q[$];

  //ANALYSIS PORTS (IMPELEMENTATION) HANDELS
  uvm_analysis_imp_MON_IN #(fpu_seq_item,fpu_scoreboard) item_collect_export_in;
  uvm_analysis_imp_MON_OUT #(fpu_seq_item,fpu_scoreboard) item_collect_export_out;

  //CONSTRUCTOR
  function new (string name = "fpu_scoreboard", uvm_component parent);
    super.new(name,parent);
    item_collect_export_in = new ("item_collect_export_in",this);
    item_collect_export_out = new ("item_collect_export_out",this);
  endfunction

  //FUNCTION: BUILD
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //WRITE IN
  function void write_MON_IN (fpu_seq_item req);
    m_seq_item_in_q.push_back(req);
  endfunction

  //WRITE OUT
  function void write_MON_OUT (fpu_seq_item req);
    m_seq_item_out_q.push_back(req);
  endfunction


  //Seq item for scoreboard to get from queues
  fpu_seq_item sb_item_in, sb_item_out;

  //Floating point single precision operands and result
  shortreal op1_fp, op2_fp,
            exp_result_fp;

  int exp_result, actual_result;

  //Expected flags
  bit actual_NAN,actual_INF,actual_zero;

  //Actual flags
  bit exp_NAN,exp_INF,exp_zero;

  //Error counter and correct counter
  int err_cnt, crr_cnt;

  //TASK: RUN PHASE
  virtual task run_phase (uvm_phase phase);
    forever begin
      //GETTING INPUT
      // -------------
      wait (m_seq_item_in_q.size > 0);
      sb_item_in = m_seq_item_in_q.pop_front();

      //Changing input bits to single precision floating point of addition and subtraction
      op1_fp = $bitstoshortreal(sb_item_in.OP1);
      op2_fp = $bitstoshortreal(sb_item_in.OP2);

      //Case to get right operation
      case(sb_item_in.OP_select)
      3'b000 : exp_result_fp = op1_fp+op2_fp;
      3'b001 : exp_result_fp = op1_fp-op2_fp;
      3'b010 :  exp_result_fp = op1_fp * op2_fp;
      default : exp_result_fp = 32'b0;
      endcase

      //Return result into bits representation again
      exp_result = $shortrealtobits(exp_result_fp);
      exp_zero = !(|exp_result);
      exp_INF = &exp_result[30:23] && !(|exp_result[22:0]);
      exp_NAN = &exp_result[30:23] &&  (|exp_result[22:0]);

      //GETTING OUTPUT
      // -------------
      wait (m_seq_item_out_q.size > 0);
      sb_item_out = m_seq_item_out_q.pop_front();
      actual_result = sb_item_out.Result;
      actual_INF = sb_item_out.INF_flag;
      actual_NAN = sb_item_out.NAN_flag;
      actual_zero = sb_item_out.zero_flag;

      //COMPARING RESULTS
      // -------------
      if ((exp_result == actual_result) && (exp_INF == actual_INF) && (exp_NAN == actual_NAN)
          && (exp_zero == actual_zero)) begin
        crr_cnt++;
        `uvm_info(get_type_name(), "SUCCESSFUL FPU OPERATION",UVM_MEDIUM)
      end

      else if (chk_rounding_err(exp_result,actual_result) && (exp_INF == actual_INF)
              && (exp_NAN == actual_NAN)) begin
        crr_cnt++;
        `uvm_info(get_type_name(), $sformatf("SUCCESSFUL FPU OPERATION WITH TOLERANCE: OPERATION (%0d) EXPECTED RESULT = %0h ,actual RESULT = %0h",
                                  sb_item_in.OP_select, exp_result, actual_result), UVM_MEDIUM)
        `uvm_info(get_type_name(),$sformatf("OP1 = %0h, OP2 = %0h, OP_SELECT = %0h",
                                  sb_item_in.OP1,sb_item_in.OP2, sb_item_in.OP_select),UVM_MEDIUM)
      end

      // DIFFERENCE IN MANTISSA BETWEEN EXPECTED AND ACTUAL BUT THE RESULT IS NOT A NUMBER
      else if (exp_NAN && actual_NAN) begin
        crr_cnt++;
        `uvm_info(get_type_name(), $sformatf("SUCCESSFUL NOT A NUMBER DETECTION WITH DIFFERENCE IN MANTISSAS: OPERATION (%0d) EXPECTED RESULT = %h ,actual RESULT = %h",
                                  sb_item_in.OP_select, exp_result, actual_result), UVM_MEDIUM)
      end

      else begin
      err_cnt++;
        `uvm_info(get_type_name(),$sformatf("OP1 = %h, OP2 = %h, OP_SELECT = %0d",
                                sb_item_in.OP1,sb_item_in.OP2, sb_item_in.OP_select),UVM_NONE)
        `uvm_fatal (get_type_name(), $sformatf("ERROR IN FPU OPERATION (%0d) EXPECTED RESULT = %h ,actual RESULT = %h",
                                sb_item_in.OP_select, exp_result, actual_result))
      end
    end
  endtask

  function bit chk_rounding_err(int exp, int out);
    // tolrance of difference 1
    //int diff = $abs(exp - out); // for VCS users
    int diff = abs_val(exp - out); // for Questa users
    bit is_one = (diff == 1);

    if(is_one && (exp[31] == out[31]))
      return (1);

      return (0);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("REPORT PHASE: FPU OPERATION",$sformatf("Successful checks:%0d",crr_cnt), UVM_NONE);
    `uvm_info("REPORT PHASE: FPU OPERATION",$sformatf("Unsuccessful checks:%0d",err_cnt),UVM_NONE);
  endfunction

  function abs_val (int a);
    if(a<0)
      return -a;
    else
      return a;
  endfunction

endclass
