-- extended implementation shown here: https://github.com/Hammerspoon/hammerspoon/issues/2196
local eventtap = require("hs.eventtap")
local eventTypes = eventtap.event.types
local timer = require("hs.timer")

local AutoCopy = {}
AutoCopy.__index = AutoCopy
AutoCopy.board = "__autocopy"

local dragCount = 0
local clickStack = {}

local function paste()
	currentCopy = hs.pasteboard.readString(AutoCopy.board)
	if currentCopy then
		hs.eventtap.keyStrokes(currentCopy)
	end
end

local function initCopyEvent();
	local currentCopy = hs.pasteboard.readString()
	if currentCopy then
		hs.pasteboard.setContents(currentCopy, AutoCopy.board)
	end
	return {
		eventtap.event.newKeyEvent({ "cmd" }, "c", true),
		eventtap.event.newKeyEvent({ "cmd" }, "c", false),
	}
end

local function initPasteEvent();
	return {
		eventtap.event.newKeyEvent({ "cmd" }, "v", true),
		eventtap.event.newKeyEvent({ "cmd" }, "v", false),
	}
end

local function initCutEvent();
	return {
		eventtap.event.newKeyEvent({ "cmd" }, "x", true),
		eventtap.event.newKeyEvent({ "cmd" }, "x", false),
	}
end

local function trackClick()
	clickStack[2] = clickStack[1]
	clickStack[1] = timer.secondsSinceEpoch()

	return false
end

local function incrementDragCount()
	dragCount = dragCount + 1

	return false
end

local function wasDoubleClick()
	if not clickStack[2] then
		return false
	end

	return clickStack[1] - clickStack[2] <= eventtap.doubleClickInterval()
end

local function wasDragging()
	return dragCount > 10
end

local function handleMouseUp(event)
	local additionalEvents = {}

	-- any time the mouse was dragged while holding the mouse button
	-- or a double click was initiated we want to fire an event
	if wasDragging() or wasDoubleClick() then
		local flags = event:getFlags()
		-- we give an escape hatch to fire a paste event if command is held, otherwise we copy
		if flags:contain({"cmd"}) then
			additionalEvents = initPasteEvent()
		elseif flags:contain({"alt"}) then
			additionalEvents = initCutEvent()
		else
			additionalEvents = initCopyEvent()
		end
	end
	dragCount = 0

	return false, additionalEvents
end

local shiftSelectInProgress = false

-- handleFlagsChanged runs any time a modifier key is pressed or released
-- We use this to fire events based on the current state and previous state
local function handleFlagsChanged(event)
	-- 56 = left_shift, 60 = right_shift
	-- shift key is the primary driver of our actions
	-- if a shift key isn't being pressed or released, we don't care about this event
	if not (event:getKeyCode() == 60 or event:getKeyCode() == 56) then return false end

	-- if the shift key is not currently being held,
	-- and shiftSelectInProgress is true
	-- then we know we have just finished selecting text via the keyboard
	if not event:getFlags():contain({"shift"}) and shiftSelectInProgress then 
		shiftSelectInProgress = false

		local flags = event:getFlags()
		-- if the user is currently holding the command key,
		-- then we do a paste instead of a copy
		if flags:contain({"cmd"}) then
			return false, initPasteEvent()
		elseif flags:contain({"alt"}) then
			return false, initCutEvent()
		else
			return false, initCopyEvent()
		end
	end

	return false
end

-- handleKeyDown is solely responsible for setting the shift select flag
-- so that when  handleKeyUp runs it knows if we were doing a shift select
local function handleKeyDown(event)
	if shiftSelectInProgress then return false end

	-- if we're not holding shift then we don't care about the event
	if not event:getFlags():contain({"shift"}) then return false end

	-- 123 <= arrow keys <= 126
	-- shift select only happens if we are using arrow keys
	if event:getKeyCode() < 123 or event:getKeyCode() > 126 then return false end
	
	shiftSelectInProgress = true

	return false
end

AutoCopy._mouseDownEvent = eventtap.new({ eventTypes.leftMouseDown }, trackClick)
AutoCopy._mouseDragEvent = eventtap.new({ eventTypes.leftMouseDragged }, incrementDragCount)
AutoCopy._mouseUpEvent = eventtap.new({ eventTypes.leftMouseUp }, handleMouseUp)
AutoCopy._flagsChangedEvent = eventtap.new({ eventTypes.flagsChanged }, handleFlagsChanged)
AutoCopy._keyDownEvent = eventtap.new({ eventTypes.keyDown }, handleKeyDown)

function AutoCopy:start()
  AutoCopy._mouseDownEvent:start()
  AutoCopy._mouseDragEvent:start()
  AutoCopy._mouseUpEvent:start()
  AutoCopy._keyDownEvent:start()
  AutoCopy._flagsChangedEvent:start()
  AutoCopy.__listener = hs.hotkey.bind(
	{'cmd', 'control'},
	'v',
	paste
)
end

function AutoCopy:stop()
  AutoCopy._mouseDownEvent:stop()
  AutoCopy._mouseDragEvent:stop()
  AutoCopy._mouseUpEvent:stop()
  AutoCopy._keyDownEvent:stop()
  AutoCopy._flagsChangedEvent:stop()

  if AutoCopy.__listener then
	AutoCopy.__listener:delete()
	AutoCopy.__listener = nil
  end
end

return AutoCopy
