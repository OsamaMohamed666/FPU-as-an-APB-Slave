class fpu_apb_monitor_in extends uvm_monitor;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_monitor_in)

  //SEQ ITEMS HANDLES
  fpu_apb_seq_item m_fpu_apb_seq_item;
  fpu_seq_item     m_fpu_seq_item;

  //VIRTUAL INTERFACE HANDLE
  virtual fpu_apb_if vif;

  // DATA STORAGE OF INPUTS AND A VALIDATION FOR IT
  int op1_reg,op2_reg;
  bit [2:0] op_select_reg;

  bit op1_valid,op2_valid,op_select_valid;

  //TLM HANDLES : TWO ANALYSIS PORTS: ONE FOR THE SCOREBOARD AND ANOTHER FOR THE COVERAGE COMPONENT
    // This port will be used to send the converted fpu operations to the scoreboard.
    uvm_analysis_port #(fpu_seq_item) fpu_item_collect_port_in;

    // This port will be used to send the collected apb transactions to the coverage component.
    uvm_analysis_port #(fpu_apb_seq_item) apb_item_collect_port_in;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_monitor_in", uvm_component parent);
    super.new(name,parent);

    //Analysis ports 
    fpu_item_collect_port_in = new ("fpu_item_collect_port_in",this);
    apb_item_collect_port_in = new ("apb_item_collect_port_in",this);

    //Valid signals initialization
    op_select_valid =0;
    op1_valid =0;
    op2_valid =0;
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_apb_if)::get(this,"","vif",vif)) begin
        `uvm_fatal(get_name(), "FAILED TO GET FPU_APB_IF FROM CONFIG DB")
    end

  endfunction

  //TASK:RUN PHASE
  virtual task run_phase(uvm_phase phase);
      fork
      abstraction_level();
      functional_level();
      join
  endtask

  // THIS TASK IS RESPONSIBLE FOR COLLECTING THE APB TRANSACTIONS (APB LEVEL)
  // AND SENDING THEM TO THE COVERAGE COMPONENT THROUGH THE ANALYSIS PORT.
  task abstraction_level;
  forever begin
      m_fpu_apb_seq_item = fpu_apb_seq_item::type_id::create("m_fpu_apb_seq_item");
    @(posedge vif.CLK iff(vif.RSTN))
    m_fpu_apb_seq_item.PSEL = vif.PSEL;
    m_fpu_apb_seq_item.PWRITE = vif.PWRITE;
    m_fpu_apb_seq_item.PENABLE = vif.PENABLE;
    m_fpu_apb_seq_item.PADDR = vif.PADDR;
    m_fpu_apb_seq_item.PWDATA = vif.PWDATA;
    `uvm_info(get_name(),$sformatf("Collected APB Transaction: RSTN=%b, PSEL=%b, PWRITE=%b, PENABLE=%b, PADDR=0x%h, PWDATA=0x%h",
              m_fpu_apb_seq_item.RSTN, m_fpu_apb_seq_item.PSEL, m_fpu_apb_seq_item.PWRITE,
              m_fpu_apb_seq_item.PENABLE, m_fpu_apb_seq_item.PADDR, m_fpu_apb_seq_item.PWDATA),
              UVM_HIGH);

     //Writing the collected APB transaction to the coverage component
    apb_item_collect_port_in.write(m_fpu_apb_seq_item);
  end

  endtask

// THIS TASK IS RESPONSIBLE FOR CONVERTING THE APB LEVEL TRANSACTIONS INTO FPU OPERATIONS (FUNCTIONAL LEVEL)
// AND SENDING THEM TO THE SCOREBOARD THROUGH THE ANALYSIS PORT.
  task functional_level;
   //Reset condition: clear all collected item;
    forever begin
      if(!vif.RSTN) begin
        op1_valid =0;
        op2_valid =0;
        op_select_valid =0;
      end

      @(posedge vif.CLK iff (vif.RSTN && vif.PSEL && vif.PENABLE && vif.PWRITE ))

      //Checking for op1
      if(vif.PADDR == fpu_apb_package::OP1_ADDR) begin
        op1_reg = vif.PWDATA;
        op1_valid =1;
      end

      //Checking for op2
      if(vif.PADDR == fpu_apb_package::OP2_ADDR) begin
        op2_reg = vif.PWDATA;
        op2_valid =1;
      end

      //Checking for op_select
      if(vif.PADDR == fpu_apb_package::OPERATION_SELECT_ADDR) begin
        op_select_reg = vif.PWDATA[2:0];
        op_select_valid =1;
      end

      //Writing in AP
      if (op_select_valid && op1_valid && op2_valid) begin
        m_fpu_seq_item = fpu_seq_item::type_id::create("m_fpu_seq_item");
        m_fpu_seq_item.OP1 = op1_reg;
        m_fpu_seq_item.OP2 = op2_reg;
        m_fpu_seq_item.OP_select = op_select_reg;
          `uvm_info(get_name(),$sformatf("Converted to FPU Operation: OP1=0x%h, OP2=0x%h, OP_SELECT=%b",
                m_fpu_seq_item.OP1, m_fpu_seq_item.OP2, m_fpu_seq_item.OP_select), UVM_MEDIUM);

        fpu_item_collect_port_in.write(m_fpu_seq_item);

        // Clearing valid signals
        op1_valid =0;
        op2_valid =0;
        op_select_valid =0;
      end
    end 
  endtask

endclass
