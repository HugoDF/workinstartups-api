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
  def category_from_string string
    stripped = string.downcase.gsub(/\W+/, '')
    case stripped
      when stripped.include?'all'
        0
      when stripped.include?'cofounder'
        16
      when stripped.include?'programmer'
        1
      when stripped.include?'designer'
        2
      when stripped.include?'intern'
        3
      when stripped.include?'tester'
        5
      when stripped.include?'marketer'
        7
      when stripped.include?'manager'
        8
      when stripped.include?'consultant'
        9
      when stripped.include?'sale'
        15
    end
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
