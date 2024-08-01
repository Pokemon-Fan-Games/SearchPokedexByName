class Window_TextEntry_Keyboard_Per_Key < Window_TextEntry
  def initialize(text, x, y, width, height, heading = nil, usedarkercolor = false, on_input = nil)
    super(text, x, y, width, height, heading, usedarkercolor)
    @on_input = on_input
  end

  def delete
    if @helper.delete
      @cursor_timer_start = System.uptime
      @cursor_shown = true
      self.refresh
      @on_input.call(@helper.text) if @on_input
      return true
    end
    return false
  end

  def insert(ch)
    if @helper.insert(ch)
      @cursor_timer_start = System.uptime
      @cursor_shown = true
      self.refresh
      @on_input.call(@helper.text, ch) if @on_input
      return true
    end
    return false
  end
  def update
    cursor_to_show = ((System.uptime - @cursor_timer_start) / 0.35).to_i.even?
    if cursor_to_show != @cursor_shown
      @cursor_shown = cursor_to_show
      refresh
    end
    return if !self.active
    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @helper.cursor > 0
        @helper.cursor -= 1
        @cursor_timer_start = System.uptime
        @cursor_shown = true
        self.refresh
      end
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor += 1
        @cursor_timer_start = System.uptime
        @cursor_shown = true
        self.refresh
      end
      return
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      self.delete if @helper.cursor > 0
      return
    elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
      return
    end
    Input.gets.each_char { |c| insert(c) }
  end
end

def pbFreeTextWithOnInput(msgwindow, currenttext, passwordbox, maxlength, width = 240, on_input = nil)
  window = Window_TextEntry_Keyboard_Per_Key.new(currenttext, 0, 0, width, 64, heading = nil, usedarkercolor = false, on_input)
  ret = ""
  window.maxlength = maxlength
  window.visible = true
  window.z = 99999
  pbPositionNearMsgWindow(window, msgwindow, :right)
  window.text = currenttext
  window.passwordChar = "*" if passwordbox
  Input.text_input = true
  loop do
    Graphics.update
    Input.update
    if Input.triggerex?(:ESCAPE)
      ret = currenttext
      break
    elsif Input.triggerex?(:RETURN)
      ret = window.text
      break
    end
    window.update
    msgwindow&.update
    yield if block_given?
  end
  Input.text_input = false
  window.dispose
  Input.update
  return ret
end

def pbMessageFreeTextWithOnInput(message, currenttext, passwordbox, maxlength, width = 240, on_input = nil, &block)
  msgwindow = pbCreateMessageWindow
  retval = pbMessageDisplay(msgwindow, message, true,
                            proc { |msgwndw|
                              next pbFreeTextWithOnInput(msgwndw, currenttext, passwordbox, maxlength, width, on_input, &block)
                            }, &block)
  pbDisposeMessageWindow(msgwindow)
  return retval
end

