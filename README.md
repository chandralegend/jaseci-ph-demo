# Jaseci Personalized Head Demo
This is a demo of using jaseci's PH (Personalized Head) Module to Create ph for each user of myca to have their own personalized parent recommendation engine. the data folder contains the necessary steps to make the dataset for each user. config folder contains the config files (YAML and Python file) where the training parameters and structure of the model has been defined. Inside the utils folder, there are utility functions we have used to implement the intended application logic and testing functions.

### **How to setup**
```bash
git clone https://github.com/chandralegend/jaseci-ph-demo.git
cd jaseci-ph-demo
```
```bash
conda create -n jaseci-ph-demo python=3.9
pip3 install -r requirements.txt
```

### **How to run**
```bash
jsctl -m
actions load module jaseci_ai_kit.ph
actions load module jaseci_ai_kit.use_enc
jac run app.jac
```