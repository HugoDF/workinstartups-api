require 'open-uri'
require 'json'

class API
  def initialize(category=0, count = 20, random=false, type=0)
    @category = category
    @count = count
    @random = (random ? 1 : 0)
    @type = type
    @from_date = 0
  end
  def set_from date
    @from_date = date
  end
  # Categories:
  # 1: Programmers
  # 2: Designers
  # 3: Interns
  # 4: undefined
  # 5: Testers
  # 6: undefined
  # 7: Marketers
  # 8: Managers
  # 9: Consultants
  # 10: undefined
  # 11: undefined
  # 12: undefined
  # 13: undefined
  # 14: undefined
  # 15: Sales
  # 16: Co-Founders

  # Type:
  # 0: all
  # fulltime
  # parttime
  # freelance

  # Ordering:
  # 0: by post date
  # 1: randomly

  def create_query
    base_uri = URI.parse("http://workinstartups.com/job-board/api/api.php")
    params = {
      action: 'getJobs',
      type: @type,
      category: @category,
      count: @count,
      random: @random,
      days_behind: 0,
      response: 'json'
    }
    query_string = params.map{|k,v| "#{k}=#{v}"}.join('&')
    @query = base_uri
    @query.query = query_string
    @query
  end
  def format string
    formatted = string["category_name"] + "\n" + string["title"] + "\n" + string["description"]
  end
  
  def get
    query = create_query
    open(query) do |f|
      f.each_line do |line|
        raw = line
        unless raw.nil?
          data = raw.gsub('var jobs = ','').gsub(';', '')
          obj = JSON.parse(data)
          @formatted = Array.new
          @from_date ||= Date.today
          obj.each do |job|
            if Date.parse(job["created_on"]) > @from_date
              @formatted << (format job)
            end
          end
        end
      end
    end
    @formatted
  end
end