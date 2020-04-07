--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local keyboard = {}

-- Legends:
-- %: Keybinding is only registered when the chat window is *not* open
-- ^: CTRL
-- !: Alt
-- ~: Shift
-- For example: "%~1" means "Shift+1" when chat window is not active.

keyboard.hotbar_table = 
{
  {'%1', '%2', '%3', '!q', '%5', '%6', '%7', '%8', '%9', '%O'},          -- Row #1
  {'!1', '%e', '!e', '%q', '!w', '%t', '!u', '^O', '!m', '^m'},          -- Row #2
  {'^1', '^2', '^3', '^4', '^5', '^6', '^7', '^8', '^9', '^0'},          -- Row #3
  {'%~1', '%~2', '%~3', '%~4', '%~q', '%~e', '%~r', '%~t', '%~c', '%~f'}, -- Row #4
  {'!y', '!2', '!3', '!4', '!5', '!6', '!7', '!8', '!9', '!0'} -- Row #5
}

-- Anything below is currently not used, considering removing everything in the future.
keyboard.less_great = -1
keyboard.esc = 1
keyboard.key_1 = 2
keyboard.key_2 = 3
keyboard.key_3 = 4
keyboard.key_4 = 5
keyboard.key_5 = 6
keyboard.key_6 = 7
keyboard.key_7 = 8
keyboard.key_8 = 9
keyboard.key_9 = 10
keyboard.key_0 = 11
keyboard.underscore = 12

keyboard.q = 16
keyboard.w = 17
keyboard.e = 18
keyboard.r = 19

keyboard.o = 24

keyboard.c = 46

keyboard.enter = 28
keyboard.ctrl = 29

keyboard.shift = 42
keyboard.backslash = 43
keyboard.comma = 51
keyboard.period = 52
keyboard.alt = 56

keyboard.up = 200
keyboard.down = 208
keyboard.left = 203
keyboard.right = 205
-- End of unused content



return keyboard
