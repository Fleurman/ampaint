# Am.Paint (v0.08.5)

---
## Menu

#### ![new_icon](icons/newfile.png) New Project: 
create a new canvas of X pixels on Y pixels
the values must be even.

#### ![load_icon](icons/load.png) Load Project:
load a file in the folder 'Saves'
The list of the files to show is in the file 'Saves/Files.txt'

#### ![save_icon](icons/save.png) Save Project:
save the project in the folder 'Saves'

#### ![png_icon](icons/export.png) Export in `.png`: 
export the image in the folder 'Exports'

#### ![txt_icon](icons/exporttxt.png) Export in `.txt`: 
Export the image data in the folder 'Exports'.
Each color is a different letter, transparent pixels are `.`

---
## Tools

#### ![pencil_icon](icons/pencil.png) Pencil
Draw a pixel in 3 sizes

#### ![eraser_icon](icons/eraser.png) Eraser
Erase a pixel in 3 sizes

#### ![bucket_icon](icons/bucket.png) Bucket
- Fill contiguneous pixels
- Erase contiguneous pixels
- Fill all pixels by color

#### ![shapes_icon](icons/shapes.png) Shapes
- Draws lined or full ellipse
- Draws lined or full rectangle

#### Move
By pressing `m + arrow` key you can move the content of the current layer.

#### Line
By pressing the `shift` key, you can draw a line with the Pencil & Eraser tools.

#### Picker
By clicking on a pixel while pressing the `left ctr` key you will set the selected color.

#### Tiles
Toggle the image tilling by pressing the `t` key.

#### Color Swap
Switch the front and back color by pressing `a` key.

---
## Viewer
You can change the background color of the viewer by clicking on it.

---
## Shortcuts
All shortcuts can be defined in the file `CONFIG.ini`

---
## Window
The window dimensions can be defined in the file `CONFIG.ini`
- **width:** between 800px & 1920px
- **height:** between 560px & 1280px