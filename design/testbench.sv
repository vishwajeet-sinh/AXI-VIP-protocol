program axi_tb();
    axi_env env;
    axi_slave_bfm bfm_s;
    //module initial happens active region
    initial begin  //reactive region of scheduling scemantics
        env = new();
        bfm_s = new();
        fork
            env.run();
            bfm_s.run();
        join
    end
endprogram