module ApplicationHelper
  # Generate a SVG avatar with initials
  def avatar_svg(initials, size = 40, bg_color = "#e0e7ff", text_color = "#4f46e5")
    content_tag(:svg,
      content_tag(:text, initials,
        x: "50%",
        y: "50%",
        dy: "0.35em",
        "text-anchor": "middle",
        "dominant-baseline": "middle",
        fill: text_color,
        style: "font-weight: bold; font-size: #{size * 0.4}px;"),
      width: size,
      height: size,
      viewBox: "0 0 #{size} #{size}",
      style: "background-color: #{bg_color}; border-radius: 50%;",
      xmlns: "http://www.w3.org/2000/svg"
    ).html_safe
  end

  # Generate a placeholder image with specified dimensions and text
  def placeholder_image(width, height, text = nil, bg_color = "#e0e7ff", text_color = "#4f46e5")
    text_content = text || "#{width}×#{height}"

    content_tag(:svg,
      content_tag(:text, text_content,
        x: "50%",
        y: "50%",
        "text-anchor": "middle",
        "dominant-baseline": "middle",
        fill: text_color,
        style: "font-weight: bold; font-size: #{[ width, height ].min * 0.1}px;"),
      width: width,
      height: height,
      viewBox: "0 0 #{width} #{height}",
      style: "background-color: #{bg_color};",
      xmlns: "http://www.w3.org/2000/svg"
    ).html_safe
  end

  # Check if current user can edit a seller
  def can_edit_seller?(seller)
    user_signed_in? && (current_user == seller.user || (current_user.respond_to?(:admin?) && current_user.admin?))
  end
end
