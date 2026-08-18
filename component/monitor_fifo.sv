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
        int captured = 0;
        @(vif.monitor_cb);
        

        count_mbx.get(expected_count);

        forever begin
            trans_fifo tx = new();
            @(vif.monitor_cb);
                // Inputs driven by TB
                tx.FClrN   = vif.FClrN;
                tx.FInN    = vif.FInN;
                tx.FOutN   = vif.FOutN;
                tx.Data_In = vif.Data_In;

                // Outputs from DUT
                tx.F_Data   = vif.monitor_cb.F_Data;
                tx.F_EmptyN = vif.monitor_cb.F_EmptyN;
                tx.F_FirstN = vif.monitor_cb.F_FirstN;
                tx.F_SLastN = vif.monitor_cb.F_SLastN;
                tx.F_LastN  = vif.monitor_cb.F_LastN;
                tx.F_FullN  = vif.monitor_cb.F_FullN;

                mbx.put(tx);
                captured++;

            if (captured == expected_count)
                break;
        end
    endtask
endclass