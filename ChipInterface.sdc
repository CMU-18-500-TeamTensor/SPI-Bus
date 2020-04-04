create_clock -period  8.000 -waveform { 0.000 4.000 } [ get_ports {GPIO_018} ]
derive_pll_clocks 
derive_clock_uncertainty