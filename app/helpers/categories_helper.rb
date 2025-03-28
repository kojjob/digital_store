module CategoriesHelper
  def subcategory_color(name)
    case name.downcase
    when /book|ebook|reading|literature|novel/
      "blue"
    when /code|programming|development|tech/
      "indigo"
    when /design|graphic|creative|art/
      "purple"
    when /business|finance|money|management/
      "green"
    when /health|fitness|wellness|medical/
      "emerald"
    when /food|recipe|cooking|kitchen/
      "amber"
    when /travel|journey|adventure|vacation/
      "sky"
    when /music|audio|sound|podcast/
      "pink"
    when /video|movie|film|cinema/
      "red"
    else
      # Generate a consistent color based on the name's first letter
      colors = %w[blue indigo purple green emerald teal cyan sky pink red orange amber]
      first_letter = name.downcase[0]
      index = first_letter.ord % colors.length
      colors[index]
    end
  end

  # Helper to render category icons dynamically
  def render_category_icon(category_name)
    icon_path = case category_name.downcase
    when /book|ebook|reading/
                  "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
    when /code|programming|software|development/
                  "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
    when /design|template|ui|ux/
                  "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
    when /image|photo|picture|graphic/
                  "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
    when /audio|sound|music|podcast/
                  "M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z"
    when /video|film|movie/
                  "M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
    when /icon|symbol|logo/
                  "M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
    when /font|text|typography/
                  "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
    else
                  # Default icon
                  "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
    end

    content_tag(:svg,
      content_tag(:path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: icon_path),
      class: "w-6 h-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor"
    )
  end
end
