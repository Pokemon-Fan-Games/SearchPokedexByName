# This class represents a window for text entry with a keyboard per key.
#
# It extends the `Window_TextEntry` class and adds functionality for handling keyboard input.
#
# @author DPertierra
# @version 1.0.0
#
class WindowTextEntryKeyboardPerKey < Window_TextEntry
  # ...

  ##
  # Initializes the window with the given text, position, width, height, heading, and options.
  #
  # @param text [String] The initial text to display in the window.
  # @param x [Integer] The x-coordinate of the window's position.
  # @param y [Integer] The y-coordinate of the window's position.
  # @param width [Integer] The width of the window.
  # @param height [Integer] The height of the window.
  # @param heading [String, nil] The heading to display above the text entry area.
  # @param usedarkercolor [Boolean] Whether to use a darker color for the window.
  # @param on_input [Proc, nil] The callback to invoke when a key is pressed.
  #
  def initialize(text, x, y, width, height, heading = nil, usedarkercolor = false, on_input = nil)
    super(text, x, y, width, height, heading, usedarkercolor)
    @on_input = on_input
  end

  ##
  # Deletes the last character in the text entry area.
  #
  # @return [void]
  #
  def delete
    return false unless @helper.delete

    @cursor_timer_start = System.uptime
    @cursor_shown = true
    @on_input&.call(@helper.text)
    refresh

    true
  end

  def insert(ch)
    return false unless @helper.insert(ch)

    @cursor_timer_start = System.uptime
    @cursor_shown = true
    refresh
    @on_input&.call(@helper.text, ch)

    true
  end

  def move_left
    return unless @helper.cursor.positive?

    @helper.cursor -= 1
    @cursor_timer_start = System.uptime
    @cursor_shown = true
    refresh
  end

  def move_right
    return unless @helper.cursor < text.scan(/./m).length

    @helper.cursor += 1
    @cursor_timer_start = System.uptime
    @cursor_shown = true
    refresh
  end

  def handle_input
    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      move_left
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      move_right
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      delete if @helper.cursor.positive?
    elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
      # return
    else
      Input.gets.each_char { |c| insert(c) }
    end
  end

  def update
    cursor_to_show = ((System.uptime - @cursor_timer_start) / 0.35).to_i.even?
    if cursor_to_show != @cursor_shown
      @cursor_shown = cursor_to_show
      refresh
    end

    return unless active

    handle_input
  end
end

def pb_free_text_with_on_input(msg_window, current_text, password_box, max_length, width = 240, on_input = nil)
  window = WindowTextEntryKeyboardPerKey.new(current_text, 0, 0, width, 64, nil, false, on_input)
  configure_window(window, msg_window, password_box, max_length, current_text)

  Input.text_input = true
  loop do
    break if handle_input(window, msg_window, current_text)
  end
  Input.text_input = false
  window.dispose
  Input.update
  window.text
end

def handle_input(window, msg_window, current_text = '')
  Graphics.update
  Input.update
  if Input.triggerex?(:ESCAPE)
    window.text = current_text
    return true
  elsif Input.triggerex?(:RETURN)
    return true
  end

  window.update
  msg_window&.update
  yield if block_given?
end

def configure_window(window, msg_window, password_box, max_length, current_text)
  window.maxlength = max_length
  window.visible = true
  window.z = 99_999
  pbPositionNearMsgWindow(window, msg_window, :right)
  window.text = current_text
  window.password_char = '*' if password_box
end

def pb_message_free_text_with_on_input(message, currenttext, passwordbox, maxlength, width = 240, on_input = nil, &block)
  msgwindow = pbCreateMessageWindow
  retval = pbMessageDisplay(msgwindow, message, true,
                            proc { |msgwndw|
                              next pb_free_text_with_on_input(msgwndw, currenttext, passwordbox, maxlength, width, on_input, &block)
                            }, &block)
  pbDisposeMessageWindow(msgwindow)
  retval
end


