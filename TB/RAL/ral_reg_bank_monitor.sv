class ral_reg_bank_monitor extends uvm_monitor;
  //REGISTERATION
  `uvm_component_utils(ral_reg_bank_monitor)

  //SEQ ITEM HANDLE
  ral_reg_bank_seq_item m_seq_item;

  //RAL HANDLE
  ral_reg_bank_block m_ral_block;
  uvm_status_e status;

  //VIRTUAL INTERFACE HANDLE
  virtual ral_reg_bank_if vif;

  //TLM HANDLE
  uvm_analysis_port #(ral_reg_bank_seq_item) item_collect_port;

  //CONSTRUCTOR
  function new(string name = "ral_reg_bank_monitor", uvm_component parent);
    super.new(name, parent);
    item_collect_port = new ("item_collect_port", this);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ral_reg_bank_if)::get(this,"","reg_bank_vif",vif)) begin
        `uvm_fatal(get_name(), "FAILED TO GET RAL_REG_BANK_IF FROM CONFIG DB")
    end

    if(!uvm_config_db#(ral_reg_bank_block)::get(this, "", "ral_reg_bank_block", m_ral_block)) begin
      `uvm_fatal(get_name(), "RAL_REG_BANK_BLOCK not found in config_db")
    end
  endfunction

  //RUN PHASE
  virtual task run_phase(uvm_phase phase);
  forever begin
    m_seq_item = ral_reg_bank_seq_item::type_id::create("m_seq_item");
    @(posedge vif.clk iff (vif.rstn && vif.enable_register));
    m_seq_item.rstn = vif.rstn;
    m_seq_item.register_addr = vif.register_addr;
    m_seq_item.PWDATA = vif.PWDATA;
    m_seq_item.write_enable = vif.write_enable;
    m_seq_item.read_enable = vif.read_enable;
    m_seq_item.PRDATA = vif.PRDATA;
    m_seq_item.OP1 = vif.OP1;
    m_seq_item.OP2 = vif.OP2;
    m_seq_item.OP_select = vif.OP_select;
    m_ral_block.fpu_regs[m_seq_item.register_addr].read(status,m_seq_item.actual_mem_data,UVM_BACKDOOR);
    item_collect_port.write(m_seq_item);

  end
  endtask

endclass
