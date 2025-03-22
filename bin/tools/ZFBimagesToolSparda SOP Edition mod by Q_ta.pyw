import os
import struct
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image

class Application(tk.Frame):

    #--- Q_ta mod ------------------------------------------------------------------
    # Image size definition
    from collections import namedtuple
    ImageSize = namedtuple('ImageSize', [
        "full_width", "full_height", 
        "default_width", "default_height",
        "init_width", "init_height"
    ])
    img = ImageSize(
        "640", "480", 
        "144", "208", 
        #"144", "250" 
        "640", "400"
    )
    #-------------------------------------------------------------------------------

    def __init__(self, master: tk.Tk = None):
        super().__init__(master)
        self.master: tk.Tk = master
        self.pack(anchor="w")
        self.create_widgets()

        # Create frame for header
        self.header_frame = tk.Frame(self.master)
        self.header_frame.pack(anchor="w")

        # Create frame for ZFB File creation
        self.frame = tk.Frame(self.master)
        self.frame.pack(anchor="w")

        # Create bold font for label
        bold_font = ("Helvetica", 10, "bold")
        label_font = ("Helvetica", 10, "normal")

        instructions_text = "Select folder containing image files for bulk ZFB creation"

        # Instructions
        self.header_label = tk.Label(self.header_frame, text=instructions_text, font=bold_font)
        self.header_label.pack()

        # Input Folder - Label
        self.input_folder_label = tk.Label(self.frame, text="Input Folder: ", font=label_font)
        self.input_folder_label.grid(row=1, column=0, sticky="w")

        # Input Folder - Input box
        self.input_folder_var = tk.StringVar()
        self.input_folder_entry = tk.Entry(self.frame, textvariable=self.input_folder_var, width=70)
        self.input_folder_entry.grid(row=1, column=1, sticky="w", columnspan=5)

        # Input Folder - Browse button
        self.input_folder_button = tk.Button(self.frame, text="Browse", command=self.select_input_folder)
        self.input_folder_button.grid(row=1, column=6, sticky="w")

        # Output Folder - Label
        self.output_folder_label = tk.Label(self.frame, text="Output Folder: ", font=label_font)
        self.output_folder_label.grid(row=2, column=0, sticky="w")

        # Output Folder - Input box
        self.output_folder_var = tk.StringVar()
        self.output_folder_entry = tk.Entry(self.frame, textvariable=self.output_folder_var, width=70)
        self.output_folder_entry.grid(row=2, column=1, sticky="w", columnspan=5)

        # Output Folder - Browse button
        self.output_folder_button = tk.Button(self.frame, text="Browse", command=self.select_output_folder)
        self.output_folder_button.grid(row=2, column=6, sticky="w")

        # Core Label
        self.core_label = tk.Label(self.frame, text="CORE: ", font=label_font)
        self.core_label.grid(row=3, column=0, sticky="w")

        # Core Input box
        self.core_var = tk.StringVar()
        self.core_var.trace_add("write", self.core_input_callback)
        self.core_entry = tk.Entry(self.frame, textvariable=self.core_var, width=10)
        self.core_entry.grid(row=3, column=1, sticky="w")

        # Extension Label
        self.extension_label = tk.Label(self.frame, text="EXTENSION: ", font=label_font)
        self.extension_label.grid(row=3, column=2, sticky="w", columnspan=2)

        # Extension Input box
        self.extension_var = tk.StringVar()
        self.extension_entry = tk.Entry(self.frame, textvariable=self.extension_var, width=10)
        self.extension_entry.grid(row=3, column=4, sticky="w")

        # Create ZFB Files button
        self.create_zfb_button = tk.Button(self.frame, text="Create ZFB Files", command=self.create_zfb_files,
                                           font=("Helvetica", 14))
        self.create_zfb_button.grid(row=6, column=0, sticky="w", columnspan=5, pady=8)

    #--- Q_ta mod ------------------------------------------------------------------
        # Padding, Message Label
        self.padding_label = tk.Label(self.frame, text="", font=label_font, width=22)
        self.padding_label.grid(row=3, column=5, sticky="w")
        self.msg_var = tk.StringVar()
        self.msg_label = tk.Label(self.frame, textvariable=self.msg_var, font=label_font)
        self.msg_label.grid(row=7, column=0, sticky="w")

        # Image Size - Label
        self.imgwidth_label = tk.Label(self.frame, text="Image Size: ", font=label_font)
        self.imgwidth_label.grid(row=5, column=0, sticky="w")
        self.imgheight_label = tk.Label(self.frame, text=" x ", font=label_font)
        self.imgheight_label.grid(row=5, column=2, sticky="w")

        # Image Size Input box
        self.imgwidth_var = tk.StringVar()
        self.imgwidth_var.trace_add("write", self.imgsize_input_callback)
        self.imgwidth_entry = tk.Entry(self.frame, textvariable=self.imgwidth_var, width=10)
        self.imgwidth_entry.grid(row=5, column=1, sticky="w")
        self.imgheight_var = tk.StringVar()
        self.imgheight_var.trace_add("write", self.imgsize_input_callback)
        self.imgheight_entry = tk.Entry(self.frame, textvariable=self.imgheight_var, width=10)
        self.imgheight_entry.grid(row=5, column=3, sticky="w")

        # Image Size Fullscreen CheckButton
        self.img_fullscreen_var = tk.BooleanVar()
        self.img_fullscreen_var.set(True)
        self.img_fullscreen_check = tk.Checkbutton(self.frame, variable=self.img_fullscreen_var, command=self.change_fullscreen_state)
        self.img_fullscreen_check.grid(row=5, column=4, sticky="e")
        # Image Size Fullscreen - Label
        self.fullscreen_label = tk.Label(self.frame, text="Fullscreen mode", font=label_font)
        self.fullscreen_label.grid(row=5, column=5, sticky="w")
        self.change_fullscreen_state()

        c_dir = os.path.dirname(os.path.abspath(__file__))
        self.input_folder_var.set(c_dir)
        self.output_folder_var.set(c_dir + "\\output")
        self.imgwidth_var.set(self.img.init_width)
        self.imgheight_var.set(self.img.init_height)
        self.core_entry.bind("<Return>", self.entry_enter_key)
        self.extension_entry.bind("<Return>", self.entry_enter_key)
        self.create_zfb_button.bind("<Return>", self.entry_enter_key)
        self.core_entry.focus_set()

    def entry_enter_key(self, event):
        if event.keysym == "Return":
            if event.widget == self.core_entry:
                self.extension_entry.focus_set()
            if event.widget == self.extension_entry:
                self.create_zfb_button.focus_set()
            if event.widget == self.create_zfb_button:
                self.create_zfb_files()

    def core_input_callback(self, *args):
        self.extension_var.set(self.core_var.get())

    def imgsize_input_callback(self, *args):
        img_w = self.imgwidth_var.get()
        img_h = self.imgheight_var.get()
        if img_w == self.img.full_width and img_h == self.img.full_height:
            self.img_fullscreen_var.set(True)
        else:
            self.img_fullscreen_var.set(False)

    def change_fullscreen_state(self, *args):
        if self.img_fullscreen_var.get():
            self.imgwidth_var.set(self.img.full_width)
            self.imgheight_var.set(self.img.full_height)
        else:
            self.imgwidth_var.set(self.img.default_width)
            self.imgheight_var.set(self.img.default_height)
    #-------------------------------------------------------------------------------

    def create_widgets(self):
        # Menu bar creation
        self.menubar = tk.Menu(self.master)
        self.filemenu = tk.Menu(self.menubar, tearoff=0)
        self.filemenu.add_command(label="Exit", command=self.exit_handler)
        self.menubar.add_cascade(label="File", menu=self.filemenu)

        self.master.config(menu=self.menubar)

    def exit_handler(self):
        os._exit(0)

    def select_input_folder(self):
        folder_path = filedialog.askdirectory()
        if folder_path:
            self.input_folder_var.set(folder_path)

    def select_output_folder(self):
        folder_path = filedialog.askdirectory()
        if folder_path:
            self.output_folder_var.set(folder_path)

    def create_zfb_files(self):
        try:
            input_folder = self.input_folder_var.get()
            output_folder = self.output_folder_var.get()
            core = self.core_var.get()
            extension = self.extension_var.get()
        #--- Q_ta mod ------------------------------------------------------------------
            img_w = self.imgwidth_var.get()
            img_h = self.imgheight_var.get()
        #-------------------------------------------------------------------------------

            # Check if folders are selected
            #if not input_folder or not output_folder or not core or not extension:
            if not input_folder or not output_folder or not core or not extension or not img_w or not img_h:
                messagebox.showwarning('Warning', 'Please fill in all the fields and select input and output folders.')
                return

        #--- Q_ta mod ------------------------------------------------------------------
            #thumb_size = (640, 480)
            if not os.path.exists(output_folder):
                os.makedirs(output_folder)

            thumb_size = (int(img_w), int(img_h))
            self.msg_var.set("processing ... ")
            self.create_zfb_button["state"] = "disabled"
            root.update()
        #-------------------------------------------------------------------------------

            # Iterate over all files in the input folder
            for file_name in os.listdir(input_folder):
                file_path = os.path.join(input_folder, file_name)

                try:
                    # Attempt to open the file as an image
                    with Image.open(file_path) as img:
                        img = img.resize(thumb_size)
                        img = img.convert("RGB")

                        raw_data = []

                        # Convert image to RGB565
                        for y in range(thumb_size[1]):
                            for x in range(thumb_size[0]):
                                r, g, b = img.getpixel((x, y))
                                rgb = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
                                raw_data.append(struct.pack('H', rgb))

                        raw_data_bytes = b''.join(raw_data)

                        # Create .zfb filename
                        zfb_filename = os.path.join(output_folder, os.path.splitext(file_name)[0] + '.zfb')

                        # Write the image data to the .zfb file
                        with open(zfb_filename, 'wb') as zfb:
                            # Fill with 00 bytes until offset 0xEA00
                            zfb.write(raw_data_bytes)
                            zfb.write(b'\x00\x00\x00\x00')  # Write four 00 bytes
                            zfb.write(f"{core};{os.path.splitext(file_name)[0]}.{extension}.gba".encode('utf-8'))  # Write the modified filename
                            zfb.write(b'\x00\x00')  # Write two 00 bytes

                except Exception as img_error:
                    # Create a placeholder .zfb file if the file is not a recognized image
                    placeholder_data = b'\x00' * 0xEA00 + b'\x00\x00\x00\x00' + f"{core};{os.path.splitext(file_name)[0]}.{os.path.splitext(file_name)[1][1:]}.gba".encode('utf-8') + b'\x00\x00'
                    zfb_filename = os.path.join(output_folder, os.path.splitext(file_name)[0] + '.zfb')
                    with open(zfb_filename, 'wb') as zfb:
                        zfb.write(placeholder_data)

        #--- Q_ta mod ------------------------------------------------------------------
            self.msg_var.set("")
        #-------------------------------------------------------------------------------
            messagebox.showinfo('Success', 'ZFB files created successfully.')
        except Exception as e:
            messagebox.showerror('Error', f'An error occurred while creating the ZFB files: {str(e)}')

        #--- Q_ta mod ------------------------------------------------------------------
        self.create_zfb_button["state"] = "normal"
        self.msg_var.set("")
        #-------------------------------------------------------------------------------

# Create the application window
root = tk.Tk()
root.geometry("630x260")
root.resizable(False, False)
root.title("ZFBSpardaTool SOP [mod by Q_ta]")

app = Application(master=root)

# Redefine the window's close button to trigger the custom exit handler
root.protocol("WM_DELETE_WINDOW", app.exit_handler)

# Start the application
app.mainloop()
