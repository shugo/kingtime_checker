require "open-uri"
require "json"
require "mail"

config = JSON.load(File.read("config.json"))
api_token = config["api_token"]
division = config["division"]
admin = config["admin"]

call_api = ->(path, params) {
  uri = "https://api.kingtime.jp/v1.0" + path +
    "?" + URI.encode_www_form(params)
  s = open(uri, "Authorization" => "Bearer #{api_token}", &:read)
  JSON.load(s)
}

t = Time.now - 24 * 60 * 60
date = t.strftime("%F")

employees = call_api.("/employees", "additionalFields" => "emailAddresses")
schedule = call_api.("/daily-schedules/",
                     "division" => division, "ondivision" => true,
                     "start" => date, "end" => date)
exit if schedule.nil?
timerecord = call_api.("/daily-workings/timerecord",
                       "division" => division, "ondivision" => true,
                       "start" => date, "end" => date)

employee_table = employees.each_with_object({}) { |i, h|
  h[i["key"]] = i
}
timerecord_table = timerecord.each_with_object({}) { |i, h|
  h[i["date"]] = {}
  i["dailyWorkings"].each { |j|
    h[i["date"]][j["employeeKey"]] = j["timeRecord"]
  }
}
errors = Hash.new { |h, k| h[k] = [] }
schedule.each { |i|
  i["dailySchedules"].each { |j|
    next if j["scheduleTypeName"] != "通常勤務"
    employee_key = j["employeeKey"]
    employee = employee_table[employee_key]
    next if employee.nil? || employee["divisionCode"] != division
    tr = timerecord_table.dig(j["date"], employee_key)
    if tr.nil?
      errors[employee_key] << "#{j['date']}の打刻がありません"
    elsif tr.size.odd? ||
        tr.sort_by { |k|
          k["time"]
        }.each_with_index.any? { |k, l|
          k["code"] != (l % 2 + 1).to_s
        }
      errors[employee_key] << "#{j['date']}の出勤・退勤の対応が取れていません"
    end
  }
}
errors.each { |employee_key, errs|
  employee = employee_table[employee_key]
  mail = Mail.new {
    from admin["email"]
    to employee["emailAddresses"][0]
    cc admin["email"]
    subject "打刻確認のお願い"
    body <<EOF
#{employee["lastName"]}さん

以下の打刻について確認をお願いします。

#{errs.join}
EOF
  }
  mail.delivery_method(:smtp, address: "localhost", port: 25,
                       enable_starttls_auto: false)
  mail.charset = "utf-8"
  mail.content_transfer_encoding = "8bit"
  mail.deliver!
}
