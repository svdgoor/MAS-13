import os
import pandas as pd

# Read the CSV file, skipping the first 5 rows of metadata
folder = 'experiments/'
file = max(
    [file for file in os.listdir(folder)
        if file.endswith('-TABLE.csv')],
    key=lambda x: int(x.split('-')[0])
)
file_extension = '.csv'
file_path = folder + file + file_extension
data = pd.read_csv(file_path, skiprows=6)


# # Save the cleaned data to a new CSV file
cleaned_file_path = folder + file + '_cleaned' + file_extension
data.to_csv(cleaned_file_path, index=False)

print(f"Cleaned data saved to {cleaned_file_path}")
