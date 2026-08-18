class multiple_rnw extends base_test;
    function new (virtual inf_fifo vif);
        super.new(vif);
    endfunction

    function void build;
        super.build();

        send(WRITE, 4, RANDOM);
        send(IDLE, 1);
        send(READ, 4);
        send(IDLE, 1);
    endfunction

    task run;
        $display("[TEST] Starting multiple read and write test...");
        super.run();
    endtask
endclass