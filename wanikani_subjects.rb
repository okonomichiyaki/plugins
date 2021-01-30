require 'resolv-replace'
require 'net/http'
require 'json'

$apikey=ARGV[0]

def get_wanikani(uri)
    req = Net::HTTP::Get.new(uri)
    req['Wanikani-Revision']='20170710'
    req['Authorization']="Bearer #{$apikey}"
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
    JSON.parse(res.body)
end

def make_uri(types,levels)
    uri = URI("https://api.wanikani.com/v2/subjects")
    params = {}
    if (types.length > 0)
        params[:types] = types.join(',')
    end
    if (levels.length > 0)
        params[:levels] = levels.join(',')
    end
    uri.query = URI.encode_www_form(params)
    uri
end

json=get_wanikani(make_uri(['vocabulary'], []))
$subjects={}

def process(json)
    json['data'].each do |item|
        readings=item['data']['readings'].map { |r| r['reading'] }
        meanings=item['data']['meanings'].map { |m| m['meaning'] }
        #puts readings,meanings
        meanings.each do |meaning|
            if not $subjects.key?(meaning)
                $subjects[meaning]=[]
            end
            $subjects[meaning].push(*readings)
        end
    end
end
next_url=json['pages']['next_url']
process(json)
while next_url != nil
    json=get_wanikani(URI(next_url))
    process(json)
    next_url=json['pages']['next_url']  
end
print 'export const vocabulary: { [key: string]: string[] } = '
print JSON.generate($subjects)
print "\n"
#p $subjects['Character']
