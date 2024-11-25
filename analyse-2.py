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
file_path = folder + file
data = pd.read_csv(file_path, skiprows=6)

plot_folder = f'{folder}/{file_path}-img'
os.makedirs(plot_folder, exist_ok=True)

# Group by 'memory-satisfact' and take the average of each group
data = data.drop(columns=['[run number]', '[step]'])
grouped_data = data.groupby('memory-satisfact').mean().reset_index()
grouped_data = data.groupby(['memory-satisfact', 'use-memory-to-mutate']
                            ).mean().reset_index()

# Print overview of the grouped data
print(grouped_data)


# List of columns to plot
columns_to_plot = grouped_data.columns[1:]
main_column = grouped_data.columns[0]

# Create bar charts for each variable against memory-satisfact
percentage_columns = [col for col in columns_to_plot if '-percent' in col]
for column in percentage_columns:
    plt.figure(figsize=(10, 5))
    for memory_satisfact in grouped_data['memory-satisfact'].unique():
        subset = grouped_data[
            grouped_data['memory-satisfact'] == memory_satisfact
        ]
        plt.plot(subset['use-memory-to-mutate'], subset[column], marker='o',
                 linestyle='-', label=f'Memory Satisfact {memory_satisfact}')
    plt.xlabel('Use Memory to Mutate')
    plt.ylabel(column.replace('-', ' ').capitalize())
    plt.title(f'{column.replace("-", " ").capitalize()} \
              vs Use Memory to Mutate')
    plt.legend(title='Memory Satisfact')
    plt.grid(True)
    plt.tight_layout()

    # Save the plot to a file
    plot_file_path = f'{plot_folder}/{column}_vs_use_memory_to_mutate.png'
    plt.savefig(plot_file_path)

    # Show the plot in the console
    plt.show()

    print(f"Plot saved to {plot_file_path}")
