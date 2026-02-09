class fpu_apb_driver extends uvm_driver #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_component_utils(fpu_apb_driver)

  //INTERFACE INSTANTIATION
  virtual fpu_apb_if.driver_mp  vif;

  //SEQUENCE ITEM
  fpu_apb_seq_item req,rsp;

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
    rsp = fpu_apb_seq_item::type_id::create("rsp");
    //Reseting
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      addr_sequences();
      //Setting the response info
      rsp.set_id_info(req);   // copies sequence_id & transaction_id
      if(vif.cb.PADDR == fpu_apb_package::OP2_ADDR) begin
        rsp.op_select_phase = 1;
        rsp.op2_exponent = req.PWDATA[30:23];
        `uvm_info(get_type_name(), $sformatf("OPERATION SELECT PHASE ACTIVATED! PADDR: %h", vif.cb.PADDR), UVM_HIGH);
      end

      else begin
        rsp.op_select_phase = 0;
        `uvm_info(get_type_name(), $sformatf("OPERATION SELECT PHASE DEACTIVATED! PADDR: %h", vif.cb.PADDR), UVM_HIGH);
      end

        seq_item_port.item_done(rsp);
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
  task setup (int c, bit a);
    @(vif.cb iff vif.RSTN);
    vif.cb.PSEL     <= req.PSEL;
    vif.cb.PENABLE  <= 1'b0;
    vif.cb.PADDR    <= c;
    vif.cb.PWDATA   <= req.PWDATA;
    vif.cb.PWRITE   <= a;

    if(c == fpu_apb_package::OP1_ADDR) begin
      rsp.op1_exponent = req.PWDATA[30:23];
    end
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

  // The sequence of addresses of OP1 to .... RESULT
  static bit[3:0] n;
  task addr_sequences;
    bit wr_en; // high > write, low > read
    addr_e addr;
    int enum_total_num;
    enum_total_num = addr.num();
    addr = addr.first();
    addr = addr.next(n);

    if((addr == fpu_apb_package::FLAGS_ADDR) || (addr == fpu_apb_package::RESULT_ADDR))
      wr_en = 0;
    else
      wr_en = 1;

    setup(addr,wr_en);
    access();

    if(n == (enum_total_num - 1))
      n=0;
    else
      n++;
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
