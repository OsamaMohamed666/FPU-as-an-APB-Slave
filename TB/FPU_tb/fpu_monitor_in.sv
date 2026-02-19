class fpu_monitor_in extends uvm_monitor;
  `uvm_component_utils(fpu_monitor_in);

  fpu_seq_item m_seq_item,
                m_seq_item_prev;

  virtual fpu_if vif;

  //TLM HANDLE
  uvm_analysis_port #(fpu_seq_item) item_collect_port_in;

  //CONSTRUCTOR
  function new (string name = "fpu_monitor_in", uvm_component parent);
    super.new(name,parent);

    //Analysis port
    item_collect_port_in = new ("item_collect_port_in",this);
  endfunction

  //BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_if)::get(this,"","fpu_vif",vif))
      `uvm_fatal (get_name(),"ERROR IN BUILDING FPU MONITOR INPUT")

    // Create a seq_item to compare it to the new seq item to detect if there is a new fpu operation
    m_seq_item_prev = fpu_seq_item::type_id::create("m_seq_item_prev",this);
  endfunction

  //RUN PHASE
  virtual task run_phase (uvm_phase phase);
    forever begin
      m_seq_item = fpu_seq_item::type_id::create("m_seq_item");

      @(posedge vif.clk iff vif.rstn);
      m_seq_item.rstn = vif.rstn;
      m_seq_item.OP1 = vif.OP1;
      m_seq_item.OP2 = vif.OP2;
      m_seq_item.OP_select = vif.OP_select;
      // If operation is multiplication, wait one more cycle as multiplication takes 2 cycles
      if(vif.OP_select == 3'b010)
        @(posedge vif.clk);

      if(compare_inputs(m_seq_item,m_seq_item_prev))
        fpu_apb_package::detect_new_fpu_operation = 0;
      else begin
        fpu_apb_package::detect_new_fpu_operation = 1;
        item_collect_port_in.write(m_seq_item);
      end

      m_seq_item_prev = fpu_seq_item::type_id::create("m_seq_item_prev",this);
      m_seq_item_prev = new m_seq_item;
    end

  endtask

  //FUNCTION: COMPARING INPUTS OF SEQ ITEM
  function bit compare_inputs(fpu_seq_item seq_item, fpu_seq_item seq_item_prev);
    if (
        seq_item.OP1 == seq_item_prev.OP1 &&
        seq_item.OP2 == seq_item_prev.OP2 &&
        seq_item.OP_select == seq_item_prev.OP_select) begin
      return 1;
    end
    return 0;
  endfunction

endclass
