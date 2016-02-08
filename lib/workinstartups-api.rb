require 'open-uri'
require 'json'

class WorkInStartupsAPI
  def initialize(category=0, count = 20, random = false, type = 0)
    @category = category
    @count = count
    @random = (random ? 1 : 0)
    @type = type
    @from_date = 0
    @format = 'id title'
  end
  def set_from date
    @from_date = date
  end
  def set_format format
    @format = format
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
  def self.category_from_string string
    stripped = string.downcase.gsub(/\W+/, '')
    category = case stripped
      when 'all' then 0
      when 'cofounder' then 16
      when 'programmer' then 1
      when 'designer' then 2
      when 'intern' then 3
      when 'tester' then 5
      when 'marketer' then 7
      when 'manager' then 8
      when 'consultant' then 9
      when 'sale' then 15
    end
  end

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
    formatted = ""
    if @format.include?"id"
      formatted += "id: " + string["id"]
    end
    if @format.include?"title"
      formatted += "\nTitle: " + string["title"]
    end
    if @format.include?"category"
      formatted += "\nCategory: " + string["category_name"]
    end
    if @format.include?"description"
      formatted += "\nDescription: " + string["description"]
    end
    formatted
  end
  def get_latest formatted=true
    query = create_query
    open(query) do |f|
      f.each_line do |line|
        raw = line
        unless raw.nil?
          data = raw.gsub('var jobs = ','').gsub(';', '')
          obj = JSON.parse(data)
          @formatted = Array.new
          @latest = Array.new
          @from_date ||= Date.today
          obj.each do |job|
            if Date.parse(job["created_on"]) > @from_date
              @formatted << (format job)
              @latest << job
            end
          end
        end
      end
    end
    if formatted
      @formatted
    else
      @latest
    end
  end
  def get_job id=nil
    if id.nil?
      raise "No Id for job"
    end
    if @latest.nil?
      get_latest
    end
    format @latest.select{|obj| obj["id"] == id}.first
  end
end
