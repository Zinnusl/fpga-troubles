use std::time::Duration;
use rust_hdl::prelude::*;

const CLOCK_SPEED_HZ : u64 = 27_000_000;

#[derive(LogicBlock)]  // <- This turns the struct into something you can simulate/synthesize
struct Counter {
    pub clock: Signal<In, Clock>, // <- input signal, type is clock
    pulser: Pulser,               // <- sub-circuit, a widget that generates pulses
    pub led: Signal<Out, Bits<6>>,
    num: Signal<Local, Bits<6>>,
}

impl Default for Counter {
   fn default() -> Self {
       Self {
         clock: Default::default(),
         pulser: Pulser::new(CLOCK_SPEED_HZ, 1.0, Duration::from_millis(100)),
         led: Default::default(),
         num: Default::default(),
       }
    }
}

impl Logic for Counter {
    #[hdl_gen] // <- this turns the update function into an HDL Kernel that can be turned into Verilog
    fn update(&mut self) {
       // v-- write to the .next member     v-- read from .val() method
       self.pulser.clock.next = self.clock.val();
       self.pulser.enable.next = true.into();
       self.num.next = bits::<6>(self.pulser.pulse.val().into());
       self.led.next = self.num.val() + 1;
       self.num.next = self.led.val() + 1;
    }
}


fn main() {
    // v--- construct the circuit
    let mut uut = Counter::default();
    // sim.run_to_file(Box::new(uut), 5 * SIMULATION_TIME_ONE_SECOND, "/tmp/blinky.vcd").unwrap();
    // vcd_to_svg("/tmp/blinky.vcd","/tmp/blinky_all.svg",&["uut.clock", "uut.led"], 0, 4_000_000_000_000).unwrap();
    // vcd_to_svg("/tmp/blinky.vcd","/tmp/blinky_pulse.svg",&["uut.clock", "uut.led"], 900_000_000_000, 1_500_000_000_000).unwrap();

    // ----------
    // generate verilog

    uut.connect_all();
    let vlog = generate_verilog(&uut);
    // let constraints = generate_constraints(&uut);

    std::fs::write("output.v", vlog).unwrap();
    // std::fs::write("output.cst", constraints).unwrap();
}
