class fpu_apb_driver extends uvm_driver #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_component_utils(fpu_apb_driver)

  //INTERFACE INSTANTIATION
  virtual fpu_apb_if.driver_mp  vif;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_apb_if)::get(this,"","vif",vif)) begin
      `uvm_fatal(get_name(), "FAILED TO GET FPU_APB_IF FROM DB")
    end
  endfunction

  //RUN PHASE
  virtual task run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      driver();
      seq_item_port.item_done();
    end
  endtask

  //TASK: RESET
  task reset;
    vif.RSTN       <= 0;
    vif.cb.PADDR   <= 0;
    vif.cb.PWDATA  <= 0;
    vif.cb.PWRITE  <= 0;
    vif.cb.PSEL    <= 0;
    vif.cb.PENABLE <= 0;
    repeat (2) @(vif.cb);

    vif.RSTN    <= 1;
  endtask

  //TASK: DRIVER
  task driver;
    @(vif.cb iff vif.RSTN);
    vif.cb.PADDR    <= req.PADDR;
    vif.cb.PWDATA   <= req.PWDATA;
    vif.cb.PWRITE   <= req.PWRITE;
    vif.cb.PSEL     <= req.PSEL;
    vif.cb.PENABLE  <= req.PENABLE;
  endtask

endclass
