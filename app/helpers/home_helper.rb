module HomeHelper
  def arrange_by_year(newsletters)
    newsletter_years = newsletters.collect(&:year).uniq
    yearwise_articles = {}
    
    for each_newsletter_year in newsletter_years
      yearwise_articles[each_newsletter_year] = []
    end
    
    for each_newsletter in newsletters
      newsletter_hash = Hash.new
      newsletter_hash[:article_name] = each_newsletter.name
      newsletter_hash[:article_path] = each_newsletter.newsletter_path
      
      yearwise_articles[each_newsletter.year] << newsletter_hash
      
    end
    
    yearwise_articles
    
  end

end
