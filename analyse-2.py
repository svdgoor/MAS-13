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

# Add a column with the ratios between
# "coopother-agg","defother-agg","coopown-agg","defown-agg"
# and their sum
data['interaction-agg'] = data['coopother-agg'] + data['defother-agg']\
    + data['coopown-agg']\
    + (data['defown-agg'] if 'defown-agg' in data.columns else 0)
data['coopother-agg-ratio'] = data['coopother-agg'] / data['interaction-agg']
data['defother-agg-ratio'] = data['defother-agg'] / data['interaction-agg']
data['coopown-agg-ratio'] = data['coopown-agg'] / data['interaction-agg']
if 'defown-agg' in data.columns:
    data['defown-agg-ratio'] = data['defown-agg'] / data['interaction-agg']

grouped_data = data.groupby('environmentType').mean().reset_index()

# Split the data by 'environmentType'
env_0 = grouped_data[grouped_data['environmentType'] == 0]
env_1 = grouped_data[grouped_data['environmentType'] == 1]
env_2 = grouped_data[grouped_data['environmentType'] == 2]

# print head flipped over xy
print(env_0.head().T)

exit(0)


# Run the rest of the script on each environment type separately
for env_data, env_type in zip([env_0, env_1, env_2],
                              ["Segregation", "Mixed", "Semi-Isolation"]):
    print(f"Processing environment type {env_type}")

    # List of columns to plot
    columns_to_plot = env_data.columns[1:]
    main_column = env_data.columns[0]

    # Create bar charts for each variable against memory-satisfact
    percentage_columns = [col for col in columns_to_plot if '-percent' in col]
    for column in percentage_columns:
        plt.figure(figsize=(10, 5))
        for memory_satisfact in env_data['memory-satisfact'].unique():
            subset = env_data[
                env_data['memory-satisfact'] == memory_satisfact
            ]
            plt.plot(subset['use-memory-to-mutate'],
                     subset[column], marker='o',
                     linestyle='-', label=memory_satisfact)
        plt.xlabel('Use Memory to Mutate')
        plt.ylabel(column.replace('-', ' ').capitalize())
        plt.title(f'{column.replace("-", " ").capitalize()} \
                    vs Use Memory to Mutate (Environment Type {env_type})')
        plt.legend(title='Memory Satisfact')
        plt.grid(True)
        plt.tight_layout()

        # Save the plot to a file
        plot_file_path = f'{plot_folder}\
            /{column}_vs_use_memory_to_mutate_env_{env_type}.png'

        # Save
        plt.savefig(plot_file_path)

        # Show the plot in the console
        # plt.show()

        print(f"Plot saved to {plot_file_path}")
