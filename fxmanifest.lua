fx_version 'cerulean'
game 'gta5'

description 'Zoom Over Shoulder'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_script 'client.lua'


files {
    'config/cl_config.lua',
    'config/sv_config.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'