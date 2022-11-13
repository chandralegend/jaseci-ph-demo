# Jaseci Personalized Head Demo
This is a demo of using jaseci's PH (Personalized Head) Module to Create ph for each user of myca to have their own personalized parent recommendation engine. the data folder contains the necessary steps to make the dataset for each user. config folder contains the config files (YAML and Python file) where the training parameters and structure of the model has been defined. Inside the utils folder, there are utility functions we have used to implement the intended application logic and testing functions.

### **How to setup**
1. Clone the repository
```bash
git clone https://github.com/chandralegend/jaseci-ph-demo.git
cd jaseci-ph-demo
```
2. Install the requirements
```bash
conda create -n jaseci-ph-demo python=3.9
pip3 install -r requirements.txt
```
3. Download the dataset
```bash
sh data/download.sh
```

### **How to run**
1. Open the data/dataset.ipynb notebook and run the cells under "Create file.json to parse to the dataset_builder.jac". This will create a file.json file in the data folder.
2. Then run the follwing in jsctl. This will create a dataset.hs file in the data folder.
```bash
cd data
jsctl run dataset_builder.jac
```
3. Open the data/dataset.ipynd notebook and run the cells under ## Data Processing". This will create a necessary file for the training and testing.
4. Then run the following in jsctl. This will create a PH head for the user and train it and evaluate it.


```bash
actions load module jaseci_ai_kit.ph
actions load module jaseci_ai_kit.use_enc
jac run app.jac
```
5. Open the evaluate.ipynb notebook and run the cells to calculate the accuracy of the model.

> **Results**
>
> For the 'User_3'. Trained using the first 4 month's data and tested on the last 4 month's data. The following results were obtained.
> - Untrained accuracy: **0.453125**
>- Trained accuracy: **0.484375**
>- Increase in accuracy: **~3%**

> **Note**
>
> This is just a demonstration about how we can use Jaseci's Personalized Head on a custom dataset. This can be 
improved further by using a larger dataset ,using a more complex model and more thoughtout data processing.