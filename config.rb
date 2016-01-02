USER = "moyashiki"
TEMPLATE = "$Title$/[$StTime$][$ChName$] $Title$ \#$Count$ $SubTitle$"
RECORDED_DB = "/home/chinachu/Chinachu/data/recorded.json"
CHANNEL = JSON.load(File.read(File.dirname(File.expand_path(__FILE__)) + "/channel.json"))
REPLACE = JSON.load(File.read(File.dirname(File.expand_path(__FILE__)) + "/replace.json"))
