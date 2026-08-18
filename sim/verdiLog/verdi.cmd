simSetSimulator "-vcssv" -exec "simv" -args "+TESTNAME=base_test"
debImport "-dbdir" "simv.daidir"
debLoadSimResult /home/intern/CDC-VP/intern_dv/fifo/sim/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "70" "27" "1850" "1016"
verdiWindowResize -win $_Verdi_1 "70" "27" "1850" "1016"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo"
verdiSetActWin -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo/dut"
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_top_fifo/dut/Data_In\[31:0\]} \
{/tb_top_fifo/dut/FClrN} \
{/tb_top_fifo/dut/FInN} \
{/tb_top_fifo/dut/FOutN} \
{/tb_top_fifo/dut/F_Data\[31:0\]} \
{/tb_top_fifo/dut/F_EmptyN} \
{/tb_top_fifo/dut/F_FirstN} \
{/tb_top_fifo/dut/F_FullN} \
{/tb_top_fifo/dut/F_LastN} \
{/tb_top_fifo/dut/F_SLastN} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 )} 
wvSetPosition -win $_nWave2 {("G1" 10)}
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo/dut"
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo/dut"
wvGetSignalSetScope -win $_nWave2 "/tb_top_fifo"
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_top_fifo/dut/Data_In\[31:0\]} \
{/tb_top_fifo/dut/FClrN} \
{/tb_top_fifo/dut/FInN} \
{/tb_top_fifo/dut/FOutN} \
{/tb_top_fifo/dut/F_Data\[31:0\]} \
{/tb_top_fifo/dut/F_EmptyN} \
{/tb_top_fifo/dut/F_FirstN} \
{/tb_top_fifo/dut/F_FullN} \
{/tb_top_fifo/dut/F_LastN} \
{/tb_top_fifo/dut/F_SLastN} \
{/tb_top_fifo/Rst_N} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvSetPosition -win $_nWave2 {("G1" 11)}
wvGetSignalClose -win $_nWave2
wvSetCursor -win $_nWave2 110477.854393 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 110020.018782 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 109038.942472 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 109627.588258 -snap {("G1" 3)}
