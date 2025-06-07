-- A-151 Quad Sequential Switch (software clone) extended to six channels
-- Routes one signal input to six outputs, advancing on each clock trigger.
-- Clock TR input  resets to 1 on TR input .
-- ‘Steps’ parameter selects 2, 3, 4, 5 or 6-step rotation, like the V2 hardware switch.

local currentStep = 1        -- 1-based index of the active output

return
{
  name   = "A-151 Switch extended",
  author = "Neal’s ChatGPT helper Modified by F.Martinez", 

  ---------------------------------------------------------------------------
  -- 1.  Initialise I/O mapping and parameters
  ---------------------------------------------------------------------------
  init = function(self)

    return {
      -- Inputs: 1 = Signal, 2 = Clock trigger, 3 = Reset trigger
      inputs      = { kCV, kTrigger, kTrigger },
      inputNames  = { "Signal", "Clock", "Reset" },

      -- Six stepped CV outputs
      outputs     = { kStepped, kStepped, kStepped, kStepped, kStepped, kStepped },
      outputNames = { "Out 1", "Out 2", "Out 3", "Out 4", "Out 5", "Out 6" },

      -- Hardware V2 toggle clone: choose 2, 3, 4, 5 or 6 steps (default 6)
      parameters  = {
        { "Steps", { "2", "3", "4", "5", "6" }, 5 },
      },
    }
  end,

  ---------------------------------------------------------------------------
  -- 2.  Handle clock & reset triggers (event-driven, no CPU wasted in step)
  ---------------------------------------------------------------------------
  trigger = function(self, input)

    local maxSteps = self.parameters[1] + 1   -- 1→2 steps, 2→3, 3→4, 4→5, 5→6
    if input == 2 then                        -- CLOCK
      currentStep = (currentStep % maxSteps) + 1
    elseif input == 3 then                    -- RESET
      currentStep = 1
    end
  end,

  ---------------------------------------------------------------------------
  -- 3.  Per-millisecond audio/CV processing
  ---------------------------------------------------------------------------
  step = function(self, dt, inputs)
    local sig  = inputs[1]          -- incoming audio/CV
    local outs = { 0, 0, 0, 0, 0, 0 }     -- default all low / “disconnected”
    outs[currentStep] = sig         -- route signal to the active output
    return outs
  end,

  ---------------------------------------------------------------------------
  -- 4.  Simple visual feedback: show active step and total steps
  ---------------------------------------------------------------------------
  draw = function(self)
    -- suppress standard parameter header, draw our own
    local maxSteps = self.parameters[1] + 1
    drawText( 10, 12, string.format("A-151 extended  %d/%d", currentStep, maxSteps) )
    -- crude little “LEDs”
    for i = 1, 6 do
      local x = 30 + (i-1)*20
      local y = 30
      local col = (i == currentStep) and 15 or 2
      drawRectangle( x-5, y-5, x+5, y+5, col )
    end
    return true  -- don’t draw the default parameter line
  end,
}
