class driver_fifo;
    virtual inf_fifo.driver vif;
    mailbox #(trans_fifo) mbx;

    function new(virtual inf_fifo.driver vif, mailbox #(trans_fifo) mbx);
        this.mbx = mbx;
        this.vif = vif;
    endfunction

    task run();
        trans_fifo tx;
        // Initial values
        vif.driver_cb.FClrN <= 1'b1;  
        vif.driver_cb.FInN <= 1'b1;   
        vif.driver_cb.FOutN <= 1'b1; 
        
        forever begin
            mbx.get(tx);    
            @(vif.driver_cb);
            vif.driver_cb.FClrN <= tx.FClrN;  
            vif.driver_cb.FInN <= tx.FInN;   
            vif.driver_cb.FOutN <= tx.FOutN; 
            vif.driver_cb.Data_In <= tx.Data_In;
        end
    endtask 
    
endclass