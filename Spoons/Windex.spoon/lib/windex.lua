local Windex = {}

function concat_array(target, source)
  for _, item in ipairs(source) do
    table.insert(target, item)
  end
end

function within(limit, a, b)
  return math.abs(a - b) < limit
end

function Windex:new(reverse)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen()
  local viewport = screen:frame()

  self_obj = {
    window = win,
    frame = frame,
    viewport = viewport,
    reverse = reverse,
    steps = {
      right = {
        { 2, 2 },
        { 3, 3 },
        { 4, 4 },
        { 4, 3 },
        { 4, 2, 3 },
        { 3, 2, 2 },
      },
      left = {
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 4, 2 },
        { 4, 1, 3 },
        { 3, 1, 2 },
      },
      center = {
        { 1, 1 },
        { 2, 1.5 },
        { 3, 2 },
      }
    }
  }

  if viewport.w > 1800 then
    concat_array(self_obj.steps.right, {
      { 6, 6 },
      { 6, 5 },
      { 6, 4 },
      { 6, 4, 2 },
    })
    
    concat_array(self_obj.steps.left, {
      { 6, 1 },
      { 6, 2 },
      { 6, 3 },
      { 6, 2, 2 },
    })

    concat_array(self_obj.steps.center, {
      { 6, 2, 4 }
    })
  end

  self.__index = self
  return setmetatable(self_obj, self)
end

function Windex:get_rect_x(num_rects, target_rect, spans)
  local target_width_multiplier = target_rect - 1
  local target_w = self.viewport.w / num_rects
  local target_x = self.viewport.x + target_w * target_width_multiplier
  if spans then
    target_w = target_w * spans
  end
  return {x = target_x, w = target_w}
end

function Windex:is_rect_x(num_rects, target_rect, spans)
  local target_x = self:get_rect_x(num_rects, target_rect, spans)
  return within(10, self.frame.x, target_x.x) and within(10, self.frame.w, target_x.w)
end

function Windex:set_rect_x(num_rects, target_rect, spans)
  local target_x = self:get_rect_x(num_rects, target_rect, spans)
  self.frame.w = target_x.w
  self.frame.x = target_x.x
end

function Windex:get_rect_y(y_direction)
  if y_direction == 'up' then
    return { y = self.viewport.y, h = self.viewport.h / 2 }
  elseif y_direction == 'down' then
    return { y = self.viewport.y + self.viewport.h / 2, h = self.viewport.h / 2 }
  end

  return { y = self.viewport.y, h = self.viewport.h }
end

function Windex:is_rect_y(y_direction)
  local target_y = self:get_rect_y(y_direction)
  -- frame height can be slightly off from the set height, so build in a slight buffer
  return within(10, self.frame.y, target_y.y) and within(10, self.frame.h, target_y.h)
end

function Windex:set_rect_y(y_direction)
  local target_y = self:get_rect_y(y_direction)
  self.frame.y = target_y.y
  self.frame.h = target_y.h
end

function Windex:run_steps(x_direction, y_direction, reverse)
  local x_target = self.steps[x_direction][1]
  for i, step in ipairs(self.steps[x_direction]) do
    if self:is_rect_x(step[1], step[2], step[3]) then
      if self:is_rect_y(y_direction) then
        -- x and y match, so we're in a sanctioned position and just need to change x to the next step
        if self.reverse then
          x_target = i == 1 and self.steps[x_direction][#self.steps[x_direction]] or self.steps[x_direction][i - 1]
        else
          x_target = i == #self.steps[x_direction] and self.steps[x_direction][1] or self.steps[x_direction][i + 1]
        end
        break
      else 
        -- x matches but y doesn't, so we're likely toggling between corner/side
        -- so we don't want to change the x
        self:set_rect_y(y_direction)
        return
      end
    end
  end
  
  self:set_rect_y(y_direction)
  self:set_rect_x(x_target[1], x_target[2], x_target[3])
end

function Windex:shuffle_xy(x_direction, y_direction)
  self:run_steps(x_direction, y_direction)
  self.window:setFrame(self.frame)
end

function Windex:shuffle_x(direction_x)
  self:shuffle_xy(direction_x, 'full')
end

function Windex:up(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('center', 'up') end
end

function Windex:down(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('center', 'down') end
end

function Windex:center(should_reverse)
  return function() Windex:new(should_reverse):shuffle_x('center') end
end

function Windex:right(should_reverse)
  return function() Windex:new(should_reverse):shuffle_x('right') end
end

function Windex:upper_right(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('right', 'up') end
end

function Windex:lower_right(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('right', 'down') end
end

function Windex:left(should_reverse)
  return function() Windex:new(should_reverse):shuffle_x('left') end
end

function Windex:upper_left(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('left', 'up') end
end

function Windex:lower_left(should_reverse)
  return function() Windex:new(should_reverse):shuffle_xy('left', 'down') end
end

return Windex
