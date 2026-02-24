module PdfHelper
  class HighlightCallback
    PADDING = 1
    def initialize(options)
      @color, @document = options.values_at(:color, :document)
    end
    def render_behind(fragment)
      original_color = @document.fill_color
      @document.fill_color = @color
      @document.fill_rectangle([ fragment.left-PADDING, fragment.top+PADDING], fragment.width + (PADDING * 2), fragment.height + PADDING)
      @document.fill_color = original_color
    end
  end
end