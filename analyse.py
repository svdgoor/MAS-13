import os
import pandas as pd
import matplotlib.pyplot as plt

# Read the CSV file, skipping the first 5 rows of metadata
folder = 'experiments/'
file = max(
    [file for file in os.listdir(folder)
        if file.endswith('-table.csv')],
    key=lambda x: int(x.split('-')[0])
)
file_extension = '.csv'
file_path = folder + file + file_extension
data = pd.read_csv(file_path, skiprows=6)


# # Save the cleaned data to a new CSV file
cleaned_file_path = folder + file + '_cleaned' + file_extension
data.to_csv(cleaned_file_path, index=False)

print(f"Cleaned data saved to {cleaned_file_path}")


# Load the CSV file
folder = 'experiments'
# check all files ending in -table_cleaned and take the highest number
file_path = max(
    [file for file in os.listdir(folder)
        if file.endswith('-table_cleaned.csv')],
    key=lambda x: int(x.split('-')[0])
)
file_ext = '.csv'
plot_folder = f'{folder}/{file_path}-img'
data = pd.read_csv(folder + "/" + file_path + file_ext)

os.makedirs(plot_folder, exist_ok=True)

# Group by 'memory-satisfact' and take the average of each group
data = data.drop(columns=['[run number]', '[step]'])
grouped_data = data.groupby('memory-satisfact').mean().reset_index()

# Print overview of the grouped data
print(grouped_data)


# List of columns to plot
columns_to_plot = grouped_data.columns[1:]
main_column = grouped_data.columns[0]

# Create bar charts for each variable against memory-satisfact
for column in columns_to_plot:
    plt.figure(figsize=(10, 5))
    plt.plot(grouped_data[main_column],
             grouped_data[column], marker='o', linestyle='-', color='skyblue')
    plt.xlabel('Memory Satisfact')
    plt.ylabel(column.replace('-', ' ').capitalize())
    plt.title(f'{column.replace("-", " ").capitalize()} vs Memory Satisfact')
    plt.xticks(ticks=grouped_data[main_column],
               labels=grouped_data[main_column])
    if '-percent' in column:
        plt.ylim(min(min(grouped_data[column]), 0) - 0.05,
                 max(max(grouped_data[column]), 1) + 0.05)
    plt.grid(True)
    plt.tight_layout()

    # Save the plot to a file
    plot_file_path = f'{plot_folder}/{column}_vs_memory_satisfact.png'
    plt.savefig(plot_file_path)

    # Show the plot in the console
    plt.show()

    print(f"Plot saved to {plot_file_path}")