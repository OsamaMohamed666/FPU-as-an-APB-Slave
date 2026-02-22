class fpu_apb_driver extends uvm_driver #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_component_utils(fpu_apb_driver)

  //INTERFACE INSTANTIATION
  virtual fpu_apb_if.driver_mp  vif;

  //SEQUENCE ITEM
  fpu_apb_seq_item req;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fpu_apb_if)::get(this,"","vif",vif)) begin
      `uvm_fatal(get_name(), "FAILED TO GET FPU_APB_IF FROM CONFIG DB ")
    end
  endfunction

  //RUN PHASE
  virtual task run_phase(uvm_phase phase);
    req = fpu_apb_seq_item::type_id::create("req");
    //Reseting
    reset();
    forever begin
      seq_item_port.get_next_item(req);
        setup();
        access();
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

  //TASK: SETUP
  task setup;
    @(vif.cb iff vif.RSTN);
    vif.cb.PSEL     <= req.PSEL;
    vif.cb.PENABLE  <= 1'b0;
    vif.cb.PADDR    <= req.PADDR;
    vif.cb.PWDATA   <= req.PWDATA;
    vif.cb.PWRITE   <= req.PWRITE;
  endtask

  //TASK: ACCESS
  task access;
    @(vif.cb iff vif.RSTN);
    vif.cb.PENABLE <= 1'b1;

    wait(vif.cb.PREADY);
    //Checking if the operation is multplication (takes 2 cycles).
    if(req.PWDATA == 2'b10 && vif.cb.PADDR == fpu_apb_package::OPERATION_SELECT_ADDR)
      @(vif.cb);
  endtask


    // Sequence in which the addresses are accessed: OP1 -> OP2 -> OPERATION SELECT -> FLAGS -> RESULT
    //task addr_sequence;
      // //Writing op1 data
      // setup(fpu_apb_package::OP1_ADDR, 1'b1);
      // access();
      // //Writing op2 data
      // setup(fpu_apb_package::OP2_ADDR, 1'b1);
      // access();
      // //Writing op_select data
      // setup(fpu_apb_package::OPERATION_SELECT_ADDR, 1'b1);
      // access();

      // //Checking if the operation is multplication (takes 2 cycles).
      // if(req.PWDATA == 2'b10)
      //   @(vif.cb);

      // //Reading flags data
      // setup(fpu_apb_package::FLAGS_ADDR, 1'b0);
      // access();
      // //Reading output result data
      // setup(fpu_apb_package::RESULT_ADDR, 1'b0);
      // access();
    //endtask
endclass
