#!/usr/local/bin/liquidsoap

set("log.file",true)
set("log.file.path","./log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("harbor.bind_addr","0.0.0.0")

backup_playlist = playlist("./playlist.txt",conservative=true,mode="normal",reload_mode="watch")
output.dummy(fallible=true,backup_playlist)

live_dj = input.harbor("live",port=9000)

on_fail = single("./technical_difficulties.wav")

source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])

# We output the stream to an icecast
# server, in ogg/vorbis and mp3 format.
output.icecast(%vorbis,id="icecast",
               mount="myradio.ogg",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)
output.icecast(%mp3,id="icecast",
               mount="myradio.mp3",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)

# dump live_dj recordings to a file
output.file(%mp3, "./live_dj.mp3", live_dj,fallible=true)
