# Import libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import (mean_squared_error, mean_absolute_error,
                             mean_absolute_percentage_error, r2_score)

# Load the dataset
df = pd.read_csv("dataset.csv")
# Check dataset information
print(df.info())
# Check top five rows
print(df.head())
# Check bottom five rows
print(df.tail())
# Create deep copy object (the original object will not be effected)
viz = df.copy()

# Check missing values
print(df.isna().sum())

# Split the data
x = df.drop(["Close", "Date", "Adj Close"], axis=1)
y = df["Close"]
x_train, x_test, y_train, y_test = train_test_split(x, y, random_state=0)
print(x_train.head())

# Linear Regression
model_lnr = LinearRegression()
model_lnr.fit(x_train, y_train)
y_pred = model_lnr.predict(x_test)

# Model Evaluation
print("MSE",round(mean_squared_error(y_test,y_pred), 3))
print("RMSE",round(np.sqrt(mean_squared_error(y_test,y_pred)), 3))
print("MAE",round(mean_absolute_error(y_test,y_pred), 3))
print("MAPE",round(mean_absolute_percentage_error(y_test,y_pred), 3))
print("R2 Score : ", round(r2_score(y_test,y_pred), 3))

# Visualization
viz['Date']=pd.to_datetime(viz['Date'],format='%Y-%m-%d')

plt.title('Closing Stock Price', color="black")
plt.plot(viz.Date, viz.Close, color="red")
plt.legend(["Close"], loc ="lower right", facecolor='white', labelcolor='black')
plt.show()

plt.title('Actual VS Predicted', color="black")
plt.scatter(y_pred, y_test, color='red', marker='o', label='Predicted')
plt.scatter(y_test, y_test, color='blue', label='Actual')
plt.plot(y_test, y_test, color='blue')
plt.legend(loc="lower right", facecolor='white', labelcolor='black')
plt.show()

# Prediction
close=model_lnr.predict(x)
result=pd.DataFrame({"actual":df["Close"],"predicted":close})
result["Date"]=viz["Date"]
result.set_index(["Date"],inplace=True)

# Saving to CSV
result.to_csv("output_stock.csv")