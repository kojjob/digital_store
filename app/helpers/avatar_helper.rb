module AvatarHelper
  def avatar_svg(initials, size = 40, bg_color = "#e0f2fe", text_color = "#0284c7")
    content_tag(:div, class: "flex items-center justify-center rounded-full",
                style: "width: #{size}px; height: #{size}px; background-color: #{bg_color}; color: #{text_color};") do
      content_tag(:span, initials, class: "font-medium text-sm")
    end
  end

  def avatar_for_user(user, size = 40)
    if user.name.present?
      initials = user.name.split.map(&:first).join("")[0..1].upcase
    else
      initials = user.email.split("@").first[0..1].upcase
    end

    # Generate a consistent color based on the user's id
    bg_colors = [ "#e0f2fe", "#fef3c7", "#e0e7ff", "#dcfce7", "#fee2e2", "#f3e8ff" ]
    text_colors = [ "#0284c7", "#d97706", "#4f46e5", "#16a34a", "#ef4444", "#9333ea" ]

    color_index = user.id.to_i % bg_colors.length
    bg_color = bg_colors[color_index]
    text_color = text_colors[color_index]

    avatar_svg(initials, size, bg_color, text_color)
  end
end
