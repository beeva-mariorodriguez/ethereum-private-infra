#!/bin/bash
if [[ ! -d keystore ]]
then
    geth account new -keystore keystore -password /dev/null
fi

