Asset: VRChat scroll-style event calendar
Version: 1.0

Development: bd_
Design: Kotonoshi (@color_kotonoshi)

=== Overview ===

This asset displays data from the VRChat event calendar [1] operated by Cuckoo (@nest_cuckoo) within a VRChat world.
It supports scrolling through the displayed events to deal with cases where the event list overflows the display.

[1] - https://sites.google.com/view/vrchat-event

=== Usage ===

Place either the StdCalendar or UnlitCalendar prefab in the scene, and adjust the position and
scale as desired. Please avoid adjusting the aspect ratio of the prefab.。

StdCalendar is based on the Unity Standard shader, and is therefore influenced by world shadows and lighting.
The appearance can be adjusted by editing the CalendarMatStd material.
Avoid changing the albedo, or the tiling and offset settings in the main maps section.

UnlitCalendar is based on an unlit shader, and may be easier to use in worlds that make use of unlit shaders.
The brightness can be adjusted a bit in the CalendarMat material.

Note: When placed near the floor near spawn, there are cases where it may not be possible to drag the
      scrollbar to the bottom of the display. It is recommended to place it at least a meter or so from
      spawn.

=== Brightness adjustment ===

The UnlitCalendar asset, as well as the scrollbar elements on the StdCalendar asset, use unlit shaders
and therefore aren't influenced by world lighting and shadows. If brightness adjustment is required, please
adjust the following values.

* The Brightness value in the CalendarMat material (if using UnlitCalendar)
* The Normal color setting on the Scrollbar object within the prefab
* The Color setting on the Handle object within the prefab

=== License ===

The unity prefab and loading image are dedicated to the public domain under the Creative Commons CC0 Public Domain Dedication.
Please see https://creativecommons.org/publicdomain/zero/1.0/ or LICENSE-CC0.txt

The shader code is released under a combination of CC0 and the MIT license. Please check the headers for the relevant files for
more details.

The image loaded from the URL configured in the asset can be displayed using this asset
in VRChat worlds. Any other redistribution or modification is forbidden.

=== Credits ===

This asset was inspired by Tsubokura Teruaki's VRChat Event Calendar.

The data for the calendar is sourced from Cuckoo (@nest_cuckoo_)'s VRChat Event Calendar.
To register or update events, please see https://sites.google.com/view/vrchat-event

Graphic design, color assignments, and the header image on display at time of initial release were done by Kotonoshi (@color_kotonoshi).

The scroll syncing system is based loosely on the approach used by Phasedragon's Synced sliders prefab.

Thanks to Yukatayu, Hakotsuki, Ram.Type-0, and PhaxeNor for shader advice.

Thanks to Kamishiro Aoi for assisting with testing during the closed alpha period.

　　　　　　　　　　　　AND YOU　　　　　