-- Maxwell-Boltzman Distribution Plotter
require("gnuplot")
t = torch

-- These first 3 functions are helper functions for various things
-- I'll try to explain how they work

-- This creates a function that can be curried from a given prototype
function curry(func, num_args)
  num_args = num_args or debug.getinfo(func, "u").nparams
  if num_args < 2 then return func end -- If we're given a function of one variable there's no point currying it
  -- This helped function returns a function with a table of variables already called, and the function to be called.
  local function helper(argtrace, n)
    if n < 1 then
      return func(unpack(flatten(argtrace))) -- If all the parameters have been given, just call the function by flattening and unpacking it's table of precalled parameters
    else
      return function (...) -- If not all the parameters have been given store some of them in a table and give back a new function taking any amount of arguments
        return helper({argtrace, ...}, n - select("#", ...)) -- select("#", ...) is the  number of parameters just given)
      end
    end
  end
  return helper({}, num_args)
end
-- Takes a table of tables of tables and flattens them into one table
-- e.g. {{{1, 2}, {3, 4}}, {5}} becomes {1, 2, 3, 4, 5} -- It's required by the currying function
function flatten(t)
  local ret = {}
  for _, v in ipairs(t) do
    if type(v) == 'table' then
      for _, fv in ipairs(flatten(v)) do
        ret[#ret + 1] = fv
      end
    else
      ret[#ret + 1] = v
    end
  end
  return ret
end

-- Recursive map function
function map(fn, unmappedtable, mappedtable)
    mappedtable = mappedtable or {}
    if #unmappedtable == 0 then
        return mappedtable -- There's nothing in the table to map, so we're done
    else
        -- Add to the mappedtable a new element with the function fn applied to it, in the process removing an element from the old table
        table.insert(mappedtable, fn(table.remove(unmappedtable, 1)))
        return map(fn, unmappedtable, mappedtable) -- Maps the rest of the table to the function
    end
end

function PlotDistribution(startV, endV, nSamples, startT, endT, stepT)
    -- Let:
    -- This is our maxwell-boltzmann function. It's been curried as it's defined so we can partially call it later
    local MaxBoltz = curry(function(T, v)
        m = 4.7e-26
        k = 1.38e-23
        A = math.sqrt(2/math.pi)
        B = (m/(k*T))^(3.0/2.0)
        C = v^2
        D = math.exp(-(m*v^2)/(2*k*T))
        return A*B*C*D
    end)
    -- Gets the max y value and returns the corresponding x value
    local function getXAtYMax(x, y)
        _, i = t.max(t.Tensor(y), 1)
        return x[i[1]]
    end
    -- A recursive function that runs through all the possible T values and prints the max values of each distribution
    local function ApproxMaxForTRange(startT, endT, deltaT)
        local function printMaxVForPlot(currentT)
            if currentT == endT then
                return -- Stops the recursive function from continuing infinitely
            else
                print(string.format("Approx max value for M-B-D of %iK is %im/s", currentT, 
                     getXAtYMax(t.totable(t.linspace(startV, endV, nSamples)),
                     map(MaxBoltz(currentT), t.totable(t.linspace(startV, endV, nSamples))))))
                printMaxVForPlot(currentT+deltaT) -- Repeat for the next temperature
            end
        end
        printMaxVForPlot(startT) -- Starts the recursive function
    end
    -- This draws multiple plots for each T value over the given linspace range
    local function PlotMBOverRange(startT, endT, deltaT)
        -- This function generates a table of tables each containing data about each plot for various temperatures
        local function buildplots(currentT, currentplots)
            if currentT == endT then
                return currentplots -- Stop the recursion
            else
                -- Each iteration a new table is created with all the data for a specific plot. This table is added to the currentplots table
                -- and the recursive loop repeats for the next T value
                table.insert(currentplots, 
                    {string.format("%iK", currentT),
                     t.linspace(startV, endV, nSamples),
                     t.Tensor(map(MaxBoltz(currentT), -- Note the MaxBoltz function is being called only partially here, returning a function of one variable to be mapped against a linspace
                     t.totable(t.linspace(startV, endV, nSamples))))})
                return buildplots(currentT+deltaT, currentplots) -- Continue the recursion
            end
        end
        gnuplot.plot(unpack(buildplots(startT, {}))) -- buildplots returns a table of tables each containing all the information for each plot. This table is unpacked and given the the plot function to be drawn
    end
    -- Lab part i) ii) and iii) compress into these three lines
    print(string.format("Maxwell-Boltzman evaluated at 300K and 300m/s is: %e", MaxBoltz(300, 300)))
    PlotMBOverRange(startT, endT, stepT)
    ApproxMaxForTRange(startT, endT, stepT)
end

PlotDistribution(1, 1500, 1500, 50, 1000, 25)
