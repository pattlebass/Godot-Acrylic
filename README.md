# Godot-Acrylic

An effect similar to Microsoft's [Acrylic](https://docs.microsoft.com/en-us/windows/apps/design/style/acrylic) and [Mica](https://learn.microsoft.com/en-us/windows/apps/design/style/mica) materials achieved in Godot 3.
It works by getting the wallpaper file and blurring it in the engine. [Here's the blurring algorithm](https://gist.github.com/pattlebass/5296ef5b49132ed1530863b3cf6d1b77).

## Showcase

https://user-images.githubusercontent.com/49322676/219870205-4841041b-52ba-4360-9b47-83f4f9841bfc.mov


## Limitations

- Implemented on Windows and Linux, but the fallback system is not great.
- Doesn't account for other windows (only blurs the background image)
