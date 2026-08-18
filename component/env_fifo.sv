import fifo_pkg::*;
class env_fifo;
    gen_fifo gen;
    driver_fifo drv;
    scb_fifo #(.DISPLAY_ALL(1'b0)) scb; // Set to 1 to display success transactions
    monitor_fifo mon;

    mailbox  #(trans_fifo) gen2drv_mbx;
    mailbox  #(trans_fifo) mon2scb_mbx;
    mailbox  #(int) count_mbx; // mailbox to capture number of transactions from generator

    virtual inf_fifo vif;

    function new (virtual inf_fifo vif);
        this.vif = vif;
    endfunction

    function void build;
        count_mbx = new();

        gen2drv_mbx = new();
        gen = new(gen2drv_mbx, count_mbx);
        drv = new(vif, gen2drv_mbx);
        
        mon2scb_mbx = new();
        scb = new(mon2scb_mbx);
        mon = new(vif, mon2scb_mbx, count_mbx);      
    endfunction

    task run();
        fork 
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none
    endtask

endclass
