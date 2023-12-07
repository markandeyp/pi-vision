from guizero import App, PushButton, Picture, Box, Text
from PIL import Image, ImageOps
from os.path import exists
from keras.models import load_model  # TensorFlow is required for Keras to work
import numpy as np

IMAGE_WIDTH = 224
IMAGE_HEIGHT = 224

np.set_printoptions(suppress=True)


class AIApp:
    def __init__(self):
        self.app = None
        self.image = None
        self.picture = None
        self.model = load_model("model/keras_Model.h5", compile=False)
        self.class_names = open("model/labels.txt", "r").readlines()
        self.text_class = None
        self.text_confidence = None

    def choose_image(self):
        image_path = self.app.select_file(
            "Choose an image", filetypes=[["JPG", "*.jpg"], ["PNG", "*.png"]])
        if (exists(image_path)):
            self.image = Image.open(image_path).convert("RGB")
            self.image = ImageOps.fit(
                self.image, (IMAGE_WIDTH, IMAGE_HEIGHT), Image.Resampling.LANCZOS)
            self.picture.image = self.image
            self.text_class.clear()
            self.text_confidence.clear()

    def identify_image(self):
        if (self.image == None):
            self.app.error("Error", "Choose an image first")
        else:
            image_array = np.asarray(self.image)
            normalized_image_array = (
                image_array.astype(np.float32) / 127.5) - 1
            data = np.ndarray(
                shape=(1, 224, 224, 3), dtype=np.float32)
            data[0] = normalized_image_array
            prediction = self.model.predict(data)
            index = np.argmax(prediction)
            class_name = self.class_names[index]
            confidence_score = prediction[0][index]
            self.text_class.value = "The number is " + class_name[0]
            self.text_confidence.value = "Confidence is {:.2f}%".format(
                confidence_score * 100)

    def build_app(self, title):
        self.app = App(title, bg="white", height=500, width=500)
        self.picture = Picture(self.app, image="placeholder.png",
                               width=IMAGE_WIDTH, height=IMAGE_HEIGHT)
        Box(self.app, width=self.app.width, height=20)
        button_box = Box(self.app, layout="grid")
        PushButton(button_box, text="Choose Image",
                   command=self.choose_image, grid=[0, 0])
        Box(button_box, width=10, height=10, grid=[1, 0])
        PushButton(button_box, text="Identify Image",
                   command=self.identify_image, grid=[2, 0])
        Box(self.app, width=self.app.width, height=20)
        self.text_class = Text(self.app, text="", size=20)
        self.text_confidence = Text(self.app, text="", size=20)

    def run_app(self):
        self.app.display()


aiApp = AIApp()
aiApp.build_app("AI Pie - A Slice For Everyone")
aiApp.run_app()
