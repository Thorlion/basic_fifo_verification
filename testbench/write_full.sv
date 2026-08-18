class write_full extends base_test;
    function new (virtual inf_fifo vif);
        super.new(vif);
    endfunction

    function void build;
        super.build();

        send(WRITE, 4, RANDOM);

        send(IDLE, 1);
        send(WRITE, 4, RANDOM);
        
        send(IDLE, 1);
        send(READ, 4);
    endfunction

    task run;
        $display("[TEST] Starting writing after full test...");
        super.run();
    endtask
endclass