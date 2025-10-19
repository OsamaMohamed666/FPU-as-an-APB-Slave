class fpu_monitor_out extends uvm_monitor;
  `uvm_component_utils(fpu_monitor_out);

  fpu_seq_item m_seq_item;

  virtual fpu_if vif;

  //TLM HANDLE
  uvm_analysis_port #(fpu_seq_item) item_collect_port_out;

  //CONSTRUCTOR
  function new (string name = "fpu_monitor_out", uvm_component parent);
    super.new(name,parent);

    //analysis port
    item_collect_port_out = new ("item_collect_port_out",this);
  endfunction

  //BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_if)::get(this,"","vif",vif))
      `uvm_fatal (get_name(),"ERROR IN BUILDING FPU MONITOR INPUT")
  endfunction

  //RUN PHASE
  virtual task run_phase (uvm_phase phase);
    forever begin
      m_seq_item = fpu_seq_item::type_id::create("m_seq_item");

      @(posedge vif.clk iff vif.rstn)
      if(vif.OP_select == 3'b010)
        @(posedge vif.clk);

      m_seq_item.INF_flag = vif.INF_flag;
      m_seq_item.NAN_flag = vif.NAN_flag;
      m_seq_item.zero_flag = vif.zero_flag;
      m_seq_item.Result = vif.Result;

      if(fpu_package::detect_new_fpu_operation) begin
        item_collect_port_out.write(m_seq_item);
      end
    end

  endtask


endclass
