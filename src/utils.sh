#!/bin/bash

function wait_emulator_to_be_ready () {
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi      
  done
}

function change_language_if_needed() {
  if [ ! -z "${LANGUAGE// }" ] && [ ! -z "${COUNTRY// }" ]; then
    wait_emulator_to_be_ready
    echo "Language will be changed to ${LANGUAGE}-${COUNTRY}"
    until adb root
    do
    	sleep 1
    done
    until adb shell 'setprop persist.sys.language $LANGUAGE; setprop persist.sys.country $COUNTRY; stop; start'
    do
    	sleep 1
    done
    until adb unroot
    do
    	sleep 1
    done
    echo "Language is changed!"
  fi
}

function install_google_play () {
  wait_emulator_to_be_ready
  echo "Google Play Service will be installed"
  adb install -r "/root/google_play_services.apk"
  echo "Google Play Store will be installed"
  adb install -r "/root/google_play_store.apk"
  
  until adb install -r /root/com.google.android.webview_102.0.5005.125.apk
  do
  	sleep 1
  done
  until adb install -r /root/com.android.chrome_102.0.5005.125.apk
  do
  	sleep 1
  done
}

function enable_proxy_if_needed () {
  if [ "$ENABLE_PROXY_ON_EMULATOR" = true ]; then
    if [ ! -z "${HTTP_PROXY// }" ]; then
      if [[ $HTTP_PROXY == *"http"* ]]; then
        protocol="$(echo $HTTP_PROXY | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        proxy="$(echo ${HTTP_PROXY/$protocol/})"
        echo "[EMULATOR] - Proxy: $proxy"

        IFS=':' read -r -a p <<< "$proxy"

        echo "[EMULATOR] - Proxy-IP: ${p[0]}"
        echo "[EMULATOR] - Proxy-Port: ${p[1]}"

        wait_emulator_to_be_ready
        echo "Enable proxy on Android emulator. Please make sure that docker-container has internet access!"
        until adb root
        do
        	sleep 1
        done

        echo "Set up the Proxy"
        until adb shell 'content update --uri content://telephony/carriers --bind proxy:s:"0.0.0.0" --bind port:s:"0000" --where "mcc=310" --where "mnc=260"'
        do
        	sleep 1
        done
        until adb shell 'content update --uri content://telephony/carriers --bind proxy:s:"${p[0]}" --bind port:s:"${p[1]}" --where "mcc=310" --where "mnc=260"'
        do
        	sleep 1
        done
        echo '
until adb root
do
 msleep 1
done
until adb shell 'content update --uri content://telephony/carriers --bind proxy:s:"${p[0]}" --bind port:s:"${p[1]}" --where "mcc=310" --where "mnc=260"'
  do
  sleep 1 
  done
 until adb unroot
do
	sleep 1
done'>/root/src/proxy.sh
        chmod a+x /root/src/proxy.sh
        
        if [ ! -z "${HTTP_PROXY_USER}" ]; then
          until adb shell 'content update --uri content://telephony/carriers --bind user:s:"${HTTP_PROXY_USER}" --where "mcc=310" --where "mnc=260"'
          do
          	sleep 1
          done
        fi
        if [ ! -z "${HTTP_PROXY_PASSWORD}" ]; then
          until adb shell 'content update --uri content://telephony/carriers --bind password:s:"${HTTP_PROXY_PASSWORD}" --where "mcc=310" --where "mnc=260"'
          do
          	sleep 1
          done
        fi
        until adb shell 'content update --uri content://telephony/carriers --bind proxy:s:"${p[0]}" --bind port:s:"${p[1]}" --where "mcc=310" --where "mnc=260"'
        do
        	sleep 1
        done
        until adb unroot
        do
        	sleep 1
        done

        # Mobile data need to be restarted for Android 10 or higher
        until adb shell 'svc data disable'
        do
        	sleep 1
        done
        until adb shell 'svc data enable'
        do
        	sleep 1
        done
      else
        echo "Please use http:// in the beginning!"
      fi
    else
      echo "$HTTP_PROXY is not given! Please pass it through environment variable!"
      exit 1
    fi
  fi
}

change_language_if_needed
sleep 1
enable_proxy_if_needed
sleep 1
install_google_play
##PROXY setting does not compute in a function but in a separate shell file... :-/
##generated above
/root/src/proxy.sh
## remove personalisation process and some amumations for chrome
/root/src/chrome_setup.sh