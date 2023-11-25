# frozen_string_literal: true

# foo[label: hoge] (in section x.y.z) --> foo<label id="ref-hoge"/>
# refer to [ref: hoge]  --> refer to <a href="ref-hoge">x.y.z</a>
# [fnref: n] --> [<a href="#fn[n]">n</a>]

lambda { |content|
  return content unless content.match(/\[fnref\s*:\s*\d+\]|\[(ref|label)\s*:\s*[^\]\s]+\]/)

  cont0 = ''
  cont = ''
  codeflag = false
  @secnum = 0
  @num = 0

  @is_sectionized = !content.match(/<!--+\s*sectionize on\s*--+>/).nil?

  def sec_incr(line)
    return unless @is_sectionized && line.match(/^#\s*[^!#].*$/)

    @secnum += 1
    @num = 0
  end

  def render
    if @is_sectionized
      format('%<sec>d.%<sub>d', { sec: @secnum, sub: @num })
    else
      @num.to_s
    end
  end

  ref_val = {}

  # phase 1: look labels
  content.each_line do |txt|
    if (codeflag = (!txt.match(/^\s*```(?!`)/).nil?) ^ codeflag)
      cont0 += txt
      next
    end

    sec_incr txt

    convd = true

    while convd
      convd = false
      next unless (label = txt.match(/\[label\s*:\s*([a-zA-Z][^\]]*)\s*\]/))

      esc = label[1]
      txt.sub!(/\[label\s*:\s*[a-zA-Z][^\]]*\]/, "<label id=\"#{esc}\"/>")
      @num += 1
      ref_val[esc] = render
      convd = true
    end

    cont0 += txt
  end

  convd = false

  # phase 2: look and replace ref
  cont0.each_line do |txt|
    if (codeflag = (!txt.match(/^\s*```(?!`)/).nil?) ^ codeflag)
      cont += txt
      next
    end

    convd = true

    while convd
      # [ref: LABEL]
      if (ref = txt.match(/{(?<disp>[^}]+)}\s*\[ref\s*:\s*(?<refl>[^\]]+)\s*\]/))
        esc = ref[:refl]
        disp = ref[:disp]
        txt.sub!(/{[^}]+}\s*\[ref\s*:\s*[^\]]+\s*\]/, "<a href=\"##{esc}\">#{disp}</a>")
      elsif (ref = txt.match(/\[ref\s*:\s*([^\]]+)\s*\]/))
        esc = ref[1]
        txt.sub!(/\[ref\s*:\s*[^\]]+\s*\]/, "<a href=\"##{esc}\">#{ref_val[esc]}</a>")
      # [fnref: n]
      elsif (ref = txt.match(/\[fnref\s*:\s*(\d+)\]/))
        nth = ref[1]
        txt.sub!(ref.to_s, "<span class=\"cite\">[<fnref>[^#{nth}]</fnref>]</span>")
      else
        convd = false
      end
    end

    cont += txt
  end

  cont
}
