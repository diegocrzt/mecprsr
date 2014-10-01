#!/usr/bin/env ruby
# encoding: utf-8

# Front-End del parser
require 'sinatra/base'
require './mecprsr'


#if $0 == __FILE__ #RUBY MAGIC!
class FrontEndApp < Sinatra::Base

  configure do
  	#print "Running #{$0}"
  	enable :sessions
  end

  get '/' do
    erb :form
  end

  get '/csv' do
    #Adaptar de acuerdo a sesion
    session[:fileIntermedio] = session[:file]+'_Intermedio.txt'
    session[:fileCSV] = session[:file]+'_CSV.txt'
    system("pdftotext -layout  -fixed 2 "+session[:file]+" "+session[:fileIntermedio])

    main(session[:fileIntermedio], session[:fileCSV])
    send_file session[:fileCSV], :type => 'Application/octet-stream'
  end

  post '/upload' do
    file_name = 'public/uploads/' + params[:file][:filename]
    File.open(file_name, 'w') {|f| f.write(params[:file][:tempfile].read) }
    session[:file] = file_name
    return 'The file was successfully uploaded! <a href="/csv">GET CSV<>'
  end
#end

  run! if app_file == $0
end




