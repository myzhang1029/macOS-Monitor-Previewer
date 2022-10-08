# macOS Monitor Previewer

Monitor Preview is an application for previewing the content of any monitor
in an application window.

It is especially useful if, when the second monitor is a public display
(e.g. a theatre screen), and we want to make sure the content on it is correct.

Made for Pearson College UWC tech crew. Written with modern Swift and CoreGraphics.

## Overview

This application has a simple workflow: select a monitor on the left panel, and
start previewing on the right panel.

## Display Selection

On the left, there is a list of available monitors. It shows the name and some
specifications of the monitor. Click the "Refresh Displays" button to scan for
additional displays.

## Preview Panel

After clicking on a monitor, its content should appear on the right. You can
click "Restart" to force the stream to restart.

## Troubleshooting

1. My monitor is not showing up?

   Click "Refresh Displays" to rescan.

2. Instead of the preview, it shows "Display or streaming is not active."

   Click "Restart", double check if the monitor is still connected, and check
   if it is turned off. If it still doesn't work, click "Refresh Displays" on
   the left to refresh the list, then select the appropriate monitor again.
