  until adb root
  do
    sleep 1
  done
  until adb shell svc wifi disable
  do 
    sleep 2
  done
  until adb shell svc bluetooth disable
  do
    sleep 1
  done
  until adb shell echo '"chrome --disable-fre --no-default-browser-check --no-first-run" > /data/local/tmp/chrome-command-line'
  do 
    sleep 1
  done
  until adb shell settings put global window_animation_scale 0
  do
        sleep 1
  done
  until adb shell settings put global transition_animation_scale 0
  do
        sleep 1
  done
  until adb shell settings put global animator_duration_scale 0
  do
        sleep 1
  done
  until adb unroot
  do
    sleep 1
  done
  until adb reboot
  do
    sleep 1
  done