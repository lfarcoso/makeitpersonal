module SongPresenter
  include ActionView::Helpers::UrlHelper

  SIDENOTE_REGEX = /\[\[(.*?)\]\]/m

  def embed
    url = youtube_url
    return unless url.present?
    return unless url.match(/youtube.com\/watch\?v=/)
    query = URI.parse(url).query
    id = CGI.parse(query)["v"].first
    "<iframe class='youtube-embed' height='230' width='230' src='http://www.youtube.com/embed/#{id}?rel=0&autohide=1&fs=0&modestbranding=1&theme=light' frameborder='0' ></iframe>".html_safe
  end

  def name
    "#{artist.titleize_with_caps} &mdash; #{title.titleize_with_caps}".html_safe
  end

  def list_of_lovers
    links = []
    lovers.each do |lover|
      links << link_to(lover.username, Rails.application.routes.url_helpers.user_path(lover))
    end
    links.join(", ").html_safe
  end

  def sidenotes
    renderer = Redcarpet::Render::HTML.new(filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer, :autolink => true, :space_after_headers => true)
    notes = lyrics.scan(SIDENOTE_REGEX).flatten || []
    notes.each_with_index.map do |note, i|
      span = "<span class='sidenote'>[#{i + 1}]</span>"
      markdown.render("#{span} #{note}").html_safe
    end
  end

  def body
    body = lyrics.gsub(/\*(.*?)\*/m, '<em>\1</em>') # emph
    body.scan(SIDENOTE_REGEX).count.times do |i|
      body.sub!(SIDENOTE_REGEX, "<span class='sidenote'>[#{i + 1}]</span>")
    end
    body.replace_newlines
  end
end
