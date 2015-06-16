require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

base_url = "http://210.8.51.75/"
comment_url = "mailto:council@botanybay.nsw.gov.au"
page = agent.get("#{base_url}eservice/daEnquiry/currentlyAdvertised.do?function_id=521&nodeNum=2812")

page.search(".non_table_headers").each do |header|
  field_values = header.next.search(".inputField").map { |i| i.inner_text }

  record = {
    address: header.inner_text.squeeze(" "),
    description: field_values[0],
    council_reference: field_values[3],
    date_received: Date.parse(field_values[4]).to_s,
    info_url: base_url + header.at(:a).attr(:href),
    comment_url: comment_url,
    date_scraped: Date.today
  }

  if (ScraperWiki.select("* from data where `council_reference`='#{record[:council_reference]}'").empty? rescue true)
    ScraperWiki.save_sqlite([:council_reference], record)
  else
    puts "Skipping already saved record " + record[:council_reference]
  end
end
