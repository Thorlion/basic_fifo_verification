class read_empty extends base_test;
    function new (virtual inf_fifo vif);
        super.new(vif);
    endfunction

    function void build;
        super.build();

        send(READ, 6);
        send(IDLE, 1);
    endfunction

    task run;
        $display("[TEST] Starting reading after empty test...");
        super.run();
    endtask
endclass