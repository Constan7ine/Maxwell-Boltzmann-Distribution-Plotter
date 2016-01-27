A Maxwell-Boltzmann Distribution plotter made with functional Lua
------------------------------------------------------------------

**What is this?**

This is a simple little plotter that graphs the Maxwell-Boltzman distribution using Lua and [Torch](http://torch.ch/). The purpose of the exercise for me as the programmer was to graph the data using as much functional programming as possible.

Assuming you have torch installed, with gnuplot, running the file should yeild an output like this:

![Maxwell-Boltzmann Output](/MaxwellBoltzmannDistro.png)

It also calculates and prints the velocities for each plot that have the highest probability density.

**Why functional?**

I wanted to evaluate Lua's ability to use functional programming techniques without being as strict as a language such as Haskell. I've implemented and used things such as function currying, maps, and higher order functions as is demonstrated in the code. I've commented it as well as I can to explain some of the more unclear things happening in the code.

**What's a Maxwell-Boltzmann Distribution?**

It's a probability distribution, first defined under the context of describing particle speeds in idealised gases in statistical mechanics.
That is, in a system of freely moving particles, colliding briefly with each other what is the probability of finding particles at a certain speed, given a certain temperature.
