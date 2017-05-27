#!/bin/zsh
# ZSH script to move windows to designated parts of the screen, activated by keyboard shortcuts
set -x
if [[ $(pgrep -c -f "move_window.sh") -gt 1 ]] ; then ; exit 0 ; fi
# Do stuff
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
    hyper_ids=($(xdotool search --class Hyper))
    active_window=$(xdotool getactivewindow)
    if [[ -z "${hyper_ids}" ]]; then
      sleep 1
      hyper_ids=($(xdotool search --class Hyper))
      if [[ -z "${hyper_ids}" ]]; then
        if [[ $(pgrep -c -f "move_window.sh") -gt 1 ]] ; then ; exit 0 ; fi
        /opt/Hyper/hyper > ~/hyper.log 2>&1 &
        xdotool search --sync --class Hyper windowsize ${xsize} ${ysize} windowmove ${newx} ${newy} windowactivate
      fi
    elif [[ ${hyper_ids[(i)${active_window}]} -le ${#hyper_ids} ]] ; then
      xdotool windowminimize ${active_window}
    else
      xdotool search --class Hyper windowsize ${xsize} ${ysize} windowmove ${newx} ${newy} windowactivate
    fi
    exit 0
  ;;
esac
xdotool getactivewindow windowsize "${xsize}" "${ysize}" windowmove "${newx}" "${newy}"

# TODO: Unmaximize windows, but find a way to do it without flicker
# wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
