class fpu_apb_monitor_out extends uvm_monitor;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_monitor_out)

  // INTERFACE HADLE
  virtual fpu_apb_if vif;

  //SEQ ITEM HANDLE
  fpu_seq_item m_fpu_seq_item;

  //TLM
  uvm_analysis_port #(fpu_seq_item) item_collect_port_out;

  // DATA STORAGE OF OUTPUTS AND A VALIDATION FOR IT
  int result_reg;
  bit[3:0] flags_reg;
  bit result_valid,flags_valid;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_monitor_out", uvm_component parent);
    super.new(name, parent);

    //Anaylsis port
    item_collect_port_out = new ("item_collect_port_out", this);

    //Valid signals
    result_valid =0;
    flags_reg =0;
  endfunction

  //FUNCTION: BUILD
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual fpu_apb_if)::get(this,"","vif",vif)) begin
      `uvm_fatal(get_name(),"FAILED TO GET FPU_APB_IF FROM CONFIG DB")
    end
  endfunction

  //TASK: RUN
  task run_phase(uvm_phase phase);
    forever begin
      //Reset condition: clear all collected item;
      if (!vif.RSTN) begin
        result_valid =0;
        flags_valid  =0;
      end
      // Works only on read mode, so pwrite signal must be low
      @(negedge vif.CLK iff (vif.RSTN && vif.PSEL && vif.PENABLE && !vif.PWRITE))
      //Get Flags
      if(vif.PADDR == fpu_apb_package::FLAGS_ADDR) begin
        flags_reg = vif.PRDATA[3:0];
        flags_valid = 1;
      end

      //Get Result
      if(vif.PADDR == fpu_apb_package::RESULT_ADDR) begin
        result_reg = vif.PRDATA;
        result_valid = 1;
      end

      //Writing in AP
      if(result_valid && flags_valid) begin
        m_fpu_seq_item = fpu_seq_item::type_id::create("m_fpu_seq_item");
        m_fpu_seq_item.data_valid = flags_reg[0];
        m_fpu_seq_item.zero_flag  = flags_reg[1];
        m_fpu_seq_item.INF_flag   = flags_reg[2];
        m_fpu_seq_item.NAN_flag   = flags_reg[3];
        m_fpu_seq_item.Result     = result_reg;
        item_collect_port_out.write(m_fpu_seq_item);

        //Clearing valid signals
        result_valid =0;
        flags_reg =0;
      end

    end
  endtask

endclass
