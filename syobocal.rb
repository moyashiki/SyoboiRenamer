#!/usr/bin/env ruby
# coding: utf-8

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'nkf'
require 'fileutils'
require 'pp'
require_relative 'config'
require_relative 'sanitize'

unless ARGV.size > 0
  warn "invalid arguments"
  exit
end

begin
  recorded_data_path = ARGV[0]
  time, title, channel = File.basename(recorded_data_path).split('_')
  channel, *ext = channel.split('.')
  #title, sub_title = title.split('「')  # FIXME
  start_time = Time.strptime(time, '%y%m%d%H%M') - 15*60
  end_time = Time.strptime(time, '%y%m%d%H%M') + 75*60

  # pre-replace
  if /darwin/ =~ RUBY_PLATFORM
    title.encode!("UTF-8", "UTF-8-MAC") # for OS X
  end

  REPLACE['pre'].each do |ary|
    title.gsub!(ary[0], ary[1])
  end

  # search
  filename = TEMPLATE

  json = Net::HTTP.get (URI.parse("http://cal.syoboi.jp/rss2.php?start=#{start_time.strftime('%Y%m%d%H%M')}&end=#{end_time.strftime('%Y%m%d%H%M')}&usr=#{USER}&alt=json"))
	# debug
	puts NKF.nkf('-m0Z1 -W -w', title)[0...4].strip
  if JSON.load(json)['items'].each do |program|
    # replace
		pp program
	puts NKF.nkf('-m0Z1 -W -w', title)[0...4].strip
    if program['ChName'] == CHANNEL[channel][0] && ( program['Title'].include?(title[0...4].strip) || program['Title'].include?(NKF.nkf('-m0Z1 -W -w', title)[0...4].strip) )
      next unless start_time < Time.at(program['StTime'].to_i) && Time.at(program['EdTime'].to_i) < end_time

      filename.gsub!("$StTime$", Time.at(program['StTime'].to_i).strftime('%y%m%d'))
      filename.gsub!("$Title$", program['Title'].sanitize)
      filename.gsub!("$ChName$", CHANNEL[channel][1])
      unless program['Count'].nil?
        filename.gsub!("$Count$", program['Count'])
      else
        filename.gsub!("$Count$", "")
      end
      unless program['SubTitle'].nil?
				if program['SubTitle'].length < 50
       		filename.gsub!("$SubTitle$", program['SubTitle'].sanitize)
				else 
        	filename.gsub!("$SubTitle$", "")
				end
      else
        filename.gsub!("$SubTitle$", "")
      end
      break true
    end
  end == true
    # post-replace
    REPLACE['post'].each do |ary|
      filename.gsub!(ary[0], ary[1])
    end

    filepath = "#{File.dirname(recorded_data_path)}/#{File.dirname(filename)}/#{File.basename(filename).strip}.#{ext.join('.')}"
    raise "#{filepath} already exists." if File.exist? filepath

    # make directories
    unless File.exist? File.dirname(filepath)
      FileUtils.mkdir_p File.dirname(filepath)
    end

    # rename
    FileUtils.mv recorded_data_path, filepath

    warn File.expand_path(filepath)
    print File.expand_path(filepath)

	# edit db
	recorded_js = File.open(RECORDED_DB) do |io|
			JSON.load(io)
	end
		
	recorded_js.reverse_each do |recorded_item|
		if recorded_item['recorded'] == recorded_data_path
			recorded_item['recorded'] = filepath 
			break
		end
	end
	
	File.open(RECORDED_DB,'w') do |io|
		JSON.dump(recorded_js, io)
	end

  else
    warn recorded_data_path
    print recorded_data_path
  end
rescue Exception => e
  warn e.message
  warn e.backtrace.inspect
  warn recorded_data_path
  print recorded_data_path
ensure
  # always executed
end
