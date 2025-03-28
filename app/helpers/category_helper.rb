module CategoryHelper
  def subcategory_color(name)
    case name.downcase
    when "smartphones", "laptops", "audio", "accessories"
      "indigo"
    when "clothing", "shoes", "bags", "jewelry"
      "pink"
    when "furniture", "decor", "kitchen", "bedding"
      "blue"
    when "skincare", "makeup", "fragrance", "haircare"
      "purple"
    when "fiction", "non-fiction", "children", "textbooks"
      "yellow"
    when "fresh", "packaged", "beverages", "snacks"
      "green"
    else
      "gray"
    end
  end
end
