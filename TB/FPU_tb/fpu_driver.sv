class fpu_driver extends uvm_driver #(fpu_seq_item);
  `uvm_component_utils(fpu_driver)


  //INTERFACE
  virtual fpu_if.driver_mp vif;

  //CONSTRUCTOR
  function new (string name = "fpu_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_if)::get(this,"","vif",vif)) begin
      `uvm_fatal(get_name(), "Failed to get configuration for fpu_if");
    end
  endfunction

  //RUN PHASE
  virtual task  run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask

  //TASK: DRIVING
  task drive();
    @(vif.cb iff vif.rstn);
   // vif.cb.rstn <= req.rstn;
    vif.cb.OP1 <= req.OP1;
    vif.cb.OP2 <= req.OP2;
    vif.cb.OP_select <= req.OP_select;
    if(req.OP_select == 3'b010) //Multiplication
      // wait one more cycle as multiplication takes 2 cycles
      @(vif.cb);
  endtask

  //TASK: RESETTING
  task reset();
    vif.rstn <= 1'b0;
    vif.cb.OP1  <= '0;
    vif.cb.OP2  <= '0;
    vif.cb.OP_select <= '0;
    repeat(2) @(vif.cb);
    vif.rstn <= 1'b1;
  endtask

endclass
