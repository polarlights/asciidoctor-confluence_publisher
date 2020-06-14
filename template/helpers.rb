# Add custom functions to this module that you want to use in your Haml
# templates. Within the template you can invoke them as top-level functions
# just like the built-in helper functions that Haml provides.
module Haml::Helpers

  CG_ALPHA = '[a-zA-Z]'
  CC_ALNUM = 'a-zA-Z0-9'

  # Detects strings that resemble URIs.
  #
  # Examples
  #   http://domain
  #   https://domain
  #   file:///path
  #   data:info
  #
  #   not c:/sample.adoc or c:\sample.adoc
  #
  UriRegexp = %r{^#{CG_ALPHA}[#{CC_ALNUM}.+-]+:/{0,2}}

  def has_option? name
    @attributes.has_key? %(#{name}-option)
  end

  ##
  # Returns corrected section level.
  #
  # @param sec [Asciidoctor::Section] the section node (default: self).
  # @return [Integer]
  #
  def section_level(sec = self)
    @_section_level ||= (sec.level == 0 && sec.special) ? 1 : sec.level
  end

  ##
  # Returns the captioned section's title, optionally numbered.
  #
  # @param sec [Asciidoctor::Section] the section node (default: self).
  # @return [String]
  #
  def section_title(sec = self)
    sectnumlevels = document.attr(:sectnumlevels, 3).to_i

    if sec.numbered && !sec.caption && sec.level <= sectnumlevels
      [sec.sectnum, sec.captioned_title].join(' ')
    else
      sec.captioned_title
    end
  end

  #--------------------------------------------------------
  # block_listing
  #

  def source_lang
    attr :language, nil, false
  end

  def confluence_supported_lang(lang)
    supported = ['actionscript3','applescript','bash','c#','cpp','css',
                 'coldfusion','delphi','diff','erl','groovy',
                 'xml','java','jfx','js','php','perl',
                 'text','powershell','py','ruby','sql','sass',
                 'scala','vb','yml']
    supported.include? lang
  end

  #--------------------------------------------------------
  # block_table
  #

  def autowidth?
    option? :autowidth
  end

  def spread?
    'spread' if !(option? 'autowidth') && (attr :tablepcwidth) == 100
  end

  #--------------------------------------------------------
  # block_video
  #

  # @return [Boolean] +true+ if the video should be embedded in an iframe.
  def video_iframe?
    ['vimeo', 'youtube'].include?(attr :poster)
  end

  def admonition_name
     case (attr :name)
     when 'note'
      'info'
     when 'tip'
       'tip'
     when 'caution', 'warning'
      'note'
     when 'important'
       'warning'
     end
  end

  # Public: Efficiently checks whether the specified String resembles a URI
  #
  # Uses the Asciidoctor::UriSniffRx regex to check whether the String begins
  # with a URI prefix (e.g., http://). No validation of the URI is performed.
  #
  # str - the String to check
  #
  # @return true if the String is a URI, false if it is not
  def uri_link?(str)
    str && (str.include? ':') && str =~ UriRegexp
  end

  def video_uri
    case (attr :poster, '').to_sym
    when :vimeo
      params = {
        :autoplay => (1 if option? 'autoplay'),
        :loop     => (1 if option? 'loop')
      }
      start_anchor = "#at=#{attr :start}" if attr? :start
      "//player.vimeo.com/video/#{attr :target}#{start_anchor}#{url_query params}"

    when :youtube
      video_id, list_id = (attr :target).split('/', 2)
      params = {
        :rel      => 0,
        :start    => (attr :start),
        :end      => (attr :end),
        :list     => (attr :list, list_id),
        :autoplay => (1 if option? 'autoplay'),
        :loop     => (1 if option? 'loop'),
        :controls => (0 if option? 'nocontrols')
      }
      "//www.youtube.com/embed/#{video_id}#{url_query params}"
    else
      anchor = [(attr :start), (attr :end)].join(',').chomp(',')
      anchor.prepend '#t=' unless anchor.empty?
      media_uri "#{attr :target}#{anchor}"
    end
  end

  # Formats URL query parameters.
  def url_query(params)
    str = params.map { |k, v|
      next if v.nil? || v.to_s.empty?
      [k, v] * '='
    }.compact.join('&amp;')

    str.prepend('?') unless str.empty?
  end

  # removes leading hash from anchor targets
  def anchor_name str
    if str.start_with? "#"
      str[1..str.length]
    else
      str
    end
  end

end
