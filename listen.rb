require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

set :public_dir, Dir.pwd

pcm = nil

fps = 0
s = Time.now.to_i

get '/' do
  if !request.websocket?
    redirect '/index.html'
  else
    request.websocket do |ws|
      ws.onopen do
        pcm = File.open("recorded/data.#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.pcm", "w")
        p pcm
        ws.send("sing it to me")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        if(msg.length < 100)
          p msg
          EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        else
          pcm.write(msg)

          t = Time.now.to_i
          if s != t
            print fps
            s = t
            fps = 0
          end
          fps += 1


          print "." ; STDOUT.flush
        end
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
        p pcm
        pcm.close if pcm
        pcm = nil
      end
    end
  end
end

