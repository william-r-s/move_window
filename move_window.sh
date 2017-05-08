#!/bin/zsh
# ZSH script to move windows to designated parts of the screen, activated by keyboard shortcuts

xdotool getdisplaygeometry | read x y; echo "$x $y"
newy=0
# Leave room for panel at the bottom of the screen
ysize=$((${y} - 25))
case $1 in
  # Calculate x coordinate, size of window (always maximized vertically)
  center)
    newx=$((1 * $x / 6))
    xsize=$((4 * $x / 6))
  ;;
  left)
    newx=0
    xsize=$((3 * $x / 6))
  ;;
  right)
    newx=$((3 * $x / 6))
    xsize=$((3 * $x / 6))
  ;;
  max)
    newx=0
    xsize="${x}"
  ;;
  hyper)
    # Place hyper terminal at the bottom of the screen
    newx=$((1 * $x / 6))
    xsize=$((4 * $x / 6))
    newy=$((4 * $y / 6))
    ysize=$((2 * $y / 6 - 25))
    if [[ "$(xdotool search --desktop 0 --class Hyper)" == "$(xdotool getactivewindow)" ]] ; then
      xdotool search --desktop 0 --class Hyper windowminimize
    else
      xdotool search --desktop 0 --class Hyper windowsize ${xsize} ${ysize} windowmove ${newx} ${newy} windowactivate
      if [[ $? != 0 ]] ; then
        /opt/Hyper/hyper > ~/hyper.log 2>&1
        xdotool search --sync --desktop 0 --class Hyper windowsize ${xsize} ${ysize} windowmove ${newx} ${newy} windowactivate
      fi
    fi
    exit
  ;;
esac
xdotool getactivewindow windowsize "${xsize}" "${ysize}" windowmove "${newx}" "${newy}"

# TODO: Unmaximize windows, but find a way to do it without flicker
# wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
