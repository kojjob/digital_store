class PagesController < ApplicationController
  def contact
  end
  
  def help
    @popular_articles = [
      { id: 1, title: "Getting started with DigitalStore", category: "general", slug: "getting-started" },
      { id: 2, title: "How to download your purchased items", category: "purchases", slug: "download-items" },
      { id: 3, title: "Payment methods and security", category: "payments", slug: "payment-security" },
      { id: 4, title: "Refund policy and process", category: "refunds", slug: "refund-policy" },
      { id: 5, title: "License types explained", category: "licensing", slug: "license-types" },
      { id: 6, title: "Account management and security", category: "account", slug: "account-security" }
    ]
    
    @help_categories = [
      { id: 1, name: "Getting Started", slug: "getting-started", icon: "template", color: "blue", description: "New to DigitalStore? Learn the basics to get up and running quickly." },
      { id: 2, name: "Account & Profile", slug: "account", icon: "user", color: "amber", description: "Manage your account settings, security, and profile information." },
      { id: 3, name: "Purchases & Downloads", slug: "purchases", icon: "cart", color: "green", description: "Information about buying products and accessing your downloads." },
      { id: 4, name: "Payments & Billing", slug: "payments", icon: "lightning", color: "peach", description: "Payment methods, invoices, refunds, and billing questions." },
      { id: 5, name: "Product Licensing", slug: "licensing", icon: "book", color: "blue", description: "Understanding licenses, usage rights, and legal information." },
      { id: 6, name: "Technical Support", slug: "technical", icon: "code", color: "green", description: "Troubleshooting, compatibility, and technical assistance." }
    ]
    
    @faqs = [
      { id: 1, question: "How do I reset my password?", answer: "To reset your password, click on the 'Forgot Password' link on the login page. Enter your email address and follow the instructions sent to your email." },
      { id: 2, question: "What payment methods do you accept?", answer: "We accept major credit cards (Visa, Mastercard, American Express), PayPal, and mobile money payments including M-Pesa, MTN Mobile Money, and AirtelTigo Money." },
      { id: 3, question: "How do I download my purchases?", answer: "After completing your purchase, go to your account dashboard and click on 'My Purchases'. You'll find download links for all your items there. You can download them at any time." },
      { id: 4, question: "Are my payment details secure?", answer: "Yes, we use industry-standard encryption and security protocols. We partner with trusted payment processors and never store your full credit card details on our servers." },
      { id: 5, question: "What if I need help with a product?", answer: "For product-specific support, visit the product page and use the 'Ask a Question' feature. For general inquiries, use our contact form or email support directly." },
      { id: 6, question: "Can I use products for commercial projects?", answer: "It depends on the license type you purchased. Standard licenses are for personal use, while Commercial and Extended licenses allow for various business applications. Check the specific license details for each product." },
      { id: 7, question: "What is your refund policy?", answer: "We offer a 30-day money-back guarantee for most products. If you're not satisfied, contact our support team with your order details to process a refund. Some restrictions may apply to customized products." },
      { id: 8, question: "How long do I have access to updates?", answer: "Most products include lifetime updates. Some premium products may offer updates for a specific period (typically 6-12 months), after which a renewal may be required for continued update access." }
    ]
  end
  
  def help_category
    @category = params[:category]
    
    # This would typically come from a database
    @category_info = {
      "getting-started" => { name: "Getting Started", icon: "template", color: "blue" },
      "account" => { name: "Account & Profile", icon: "user", color: "amber" },
      "purchases" => { name: "Purchases & Downloads", icon: "cart", color: "green" },
      "payments" => { name: "Payments & Billing", icon: "lightning", color: "peach" },
      "licensing" => { name: "Product Licensing", icon: "book", color: "blue" },
      "technical" => { name: "Technical Support", icon: "code", color: "green" }
    }[@category]
    
    @articles = [
      { id: 1, title: "Introduction to #{@category_info[:name]}", slug: "introduction", excerpt: "Learn the basics of #{@category_info[:name]} and how to get started." },
      { id: 2, title: "Common #{@category_info[:name]} Questions", slug: "common-questions", excerpt: "Answers to frequently asked questions about #{@category_info[:name]}." },
      { id: 3, title: "Troubleshooting #{@category_info[:name]} Issues", slug: "troubleshooting", excerpt: "Solutions to common problems related to #{@category_info[:name]}." },
      { id: 4, title: "Advanced #{@category_info[:name]} Topics", slug: "advanced-topics", excerpt: "In-depth information for power users about #{@category_info[:name]}." },
      { id: 5, title: "#{@category_info[:name]} Best Practices", slug: "best-practices", excerpt: "Tips and recommendations for getting the most out of your experience." }
    ]
    
    render 'help_category'
  end
  
  def help_article
    @category = params[:category]
    @article = params[:article]
    
    # This would typically come from a database
    @category_info = {
      "getting-started" => { name: "Getting Started", icon: "template", color: "blue" },
      "account" => { name: "Account & Profile", icon: "user", color: "amber" },
      "purchases" => { name: "Purchases & Downloads", icon: "cart", color: "green" },
      "payments" => { name: "Payments & Billing", icon: "lightning", color: "peach" },
      "licensing" => { name: "Product Licensing", icon: "book", color: "blue" },
      "technical" => { name: "Technical Support", icon: "code", color: "green" }
    }[@category]
    
    # Sample article content - would come from database in real app
    @article_content = {
      title: "How to #{@article.titleize}",
      updated_at: 1.month.ago,
      content: "<p>This is a detailed guide on how to #{@article.humanize.downcase}. This would be a comprehensive article that helps users understand the topic thoroughly.</p><h2>Getting Started</h2><p>To begin with #{@article.humanize.downcase}, you'll need to understand the basics. Here's what you need to know:</p><ul><li>Important point 1 about #{@article.humanize.downcase}</li><li>Important point 2 about #{@article.humanize.downcase}</li><li>Important point 3 about #{@article.humanize.downcase}</li></ul><h2>Step-by-Step Instructions</h2><p>Follow these steps to complete the process:</p><ol><li>First, do this important step</li><li>Then, proceed to the next important step</li><li>Finally, complete the process by doing this</li></ol><h2>Advanced Tips</h2><p>Once you're comfortable with the basics, try these advanced techniques:</p><p>Advanced tip 1 for #{@article.humanize.downcase}.</p><p>Advanced tip 2 for #{@article.humanize.downcase}.</p><h2>Troubleshooting</h2><p>Having issues? Here are common problems and solutions:</p><h3>Problem: Something isn't working</h3><p>Solution: Try this approach to fix it.</p><h3>Problem: Another common issue</h3><p>Solution: Here's how to resolve this particular problem.</p>"
    }
    
    @related_articles = [
      { title: "Related article 1 about #{@category_info[:name]}", slug: "related-1" },
      { title: "Related article 2 about #{@category_info[:name]}", slug: "related-2" },
      { title: "Related article 3 about #{@category_info[:name]}", slug: "related-3" }
    ]
    
    render 'help_article'
  end

  def contact_submit
    # Process the form submission
    # For example:
    @name    = params[:name]
    @email   = params[:email]
    @subject = params[:subject]
    @message = params[:message]
    
    # Send email or save to database
    # ContactMailer.contact_email(@name, @email, @subject, @message).deliver_now
    
    # Flash a success message
    flash[:notice] = "Thank you for your message. We'll respond as soon as possible!"
    
    # Redirect back to contact page
    redirect_to contact_path
  rescue => e
    # Handle errors
    flash[:alert] = "Sorry, there was a problem sending your message. Please try again."
    redirect_to contact_path
  end
end
