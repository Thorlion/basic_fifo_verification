class monitor_fifo;
    mailbox #(trans_fifo) mbx;
    virtual inf_fifo.monitor vif;
    mailbox #(int) count_mbx;
    
    function new(virtual inf_fifo.monitor vif, mailbox #(trans_fifo) mbx, mailbox #(int) count_mbx);
        this.mbx = mbx;
        this.vif = vif;
        this.count_mbx = count_mbx;
    endfunction

    task run();
        int expected_count;
        trans_fifo tx;

        // Let the driver apply its first transaction before sampling it.
        @(vif.monitor_cb);
        count_mbx.get(expected_count);

        repeat (expected_count) begin
            tx = new();
            @(vif.monitor_cb);

            // Inputs driven by the testbench
            tx.Rst_N   = vif.Rst_N;
            tx.FClrN   = vif.monitor_cb.FClrN;
            tx.FInN    = vif.monitor_cb.FInN;
            tx.FOutN   = vif.monitor_cb.FOutN;
            tx.Data_In = vif.monitor_cb.Data_In;

            // Outputs driven by the DUT
            tx.F_Data   = vif.monitor_cb.F_Data;
            tx.F_EmptyN = vif.monitor_cb.F_EmptyN;
            tx.F_FirstN = vif.monitor_cb.F_FirstN;
            tx.F_SLastN = vif.monitor_cb.F_SLastN;
            tx.F_LastN  = vif.monitor_cb.F_LastN;
            tx.F_FullN  = vif.monitor_cb.F_FullN;

            mbx.put(tx);
        end

        // Tell the scoreboard that every generated transaction was captured.
        mbx.put(null);
    endtask
endclass
