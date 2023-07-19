fx_version "cerulean"
game "gta5"

title "Onebit_Groups"
description "A Groups app made for LB-Phone"
author "RijayJH"

client_script "client.lua"

server_script "server.lua"

shared_script "@ox_lib/init.lua"

files {
    "ui/**/*"
}

ui_page "ui/index.html"

lua54 'yes'
