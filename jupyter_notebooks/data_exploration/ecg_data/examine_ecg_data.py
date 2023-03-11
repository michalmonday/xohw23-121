import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# df = pd.read_csv('ecg_data.csv', index_col=0)
df = pd.read_csv('ecg_with_repr.csv', index_col=0)

# df['exec_time'] = df['clk_counter'] - df['fifo_full_ticks_counts']

def times_between_indices(time_column, indices, include_zero=True):
    if include_zero:
        indices = [0] + indices
    times = []
    for i, ind in enumerate(indices):
        if i != len(indices) - 1:
            t = time_column.loc[ind: indices[i+1]].sum()
            times.append(t)
    return times
# df['exec_time_between_jal'].plot(marker='o', linestyle='None', figsize=(10, 5))


def convert_row_data_to_binary_representation(row, bits_size=1024):
    # resulting bits will store:
    # { 
    #   296 spare bits,
    #   256 bits for A0-A3 registers, 
    #   32 bits for instruction,
    #   64 bits for clk_count
    #   64 bits for PC,
    #   39 bits for HPC overflow map,
    #   273 bits for HPC values
    # }

    # bits = 0
    # bits = (bits << 64) + row['A3']
    # bits = (bits << 64) + row['A2']
    # bits = (bits << 64) + row['A1']
    # bits = (bits << 64) + row['A0']
    # bits = (bits << 32) + int(row['instr'], 16)
    # bits = (bits << 64) + row['clk_counter']
    # bits = (bits << 64) + int(row['pc'], 16)
    # bits = (bits << 39) + 0 # overflow_map (not used yet, just need to change pynq_wrapper.ipynb and collect data again)
    # for i in range(37):
    #     bits = (bits << 7) + row.iloc[-38+i]

    #     print(i, bits)
    # return bits

    bits = ''
    bits += f"{row['A3']:064b}"
    bits += f"{row['A2']:064b}"
    bits += f"{row['A1']:064b}"
    bits += f"{row['A0']:064b}"
    bits += f"{int(row['instr'], 16):032b}"
    # bits += f"{row['clk_counter']:064b}"
    # bits += f"{0:064b}" # clk_counter (not used as it is temporally non-deterministic)
    bits += f"{int(row['pc'], 16):064b}"
    # bits += f"{0:039b}" # overflow_map (not used yet, just need to change pynq_wrapper.ipynb and collect data again)
    # for i in range(37):
    #     bits += f"{row.iloc[-38+i]:07b}"
    return int(bits, 2)

#nums = []
#for i in range(df.shape[0]):
#    bits = convert_row_data_to_binary_representation(df.iloc[i])
#    # print(bits)
#    # print( int(bits, 2) )
#    nums.append(int(bits, 2))

def number_of_ones_in_int(num, bits_size=1024):
    count = 0
    for i in range(bits_size):
        if num & 1 == 1:
            count += 1
        num >>= 1
    return count

def number_of_zeros_in_int(num, bits_size=1024):
    count = 0
    for i in range(bits_size):
        if num & 1 == 0:
            count += 1
        num >>= 1
    return count

def calculate_diff_similarities(int_representations, bits_size=512):
    similarities = [0]
    for i, val_str in enumerate(int_representations):
        if i == 0:
            continue
        val = int(val_str)
        prev_val = int(int_representations[i-1]) 
        similarity = number_of_zeros_in_int(val ^ prev_val, bits_size=bits_size) # / 1024
        similarities.append(similarity)
    return similarities
    # df['similarities'] = (df['int_repr'] ^ df['int_repr'].shift(1).fillna(0)).apply(number_of_ones_in_int) / 1024

def calculate_similarities(int_representations, seed_value, bits_size=512):
    similarities = []
    for i, val_str in enumerate(int_representations):
        val = int(val_str)
        similarity = number_of_zeros_in_int(val ^ seed_value, bits_size=bits_size) # / 1024
        similarities.append(similarity)
    return similarities



def set_atf_seed_input(seed_value, seed_bit_width=512):
    ''' The seed value may be very long (e.g. 512 bits), the ctrl_wdata is only 64 bits wide,
    for that reason it must be supplied by writing multiple times to this address.  '''
    assert type(seed_value) != str, "Seed value must be an integer, not a string."
    assert seed_bit_width % 64 == 0, "Seed bit width must be a multiple of 64."
    # send MSB first

    fake_destination = 0
    for i in reversed(range(0, seed_bit_width, 64)):
        # send the MSB 64 bits of the seed value
        fake_destination = fake_destination << 64 | (seed_value >> 960)
        # self.send_data_to_cms(seed_value >> i, __class__.ATF_SEED_INPUT)
        seed_value <<= 64
    return fake_destination


my_rows = [
{
    'A3': 0,
    'A2': 0,
    'A1': 4028,
    'A0': 0,
    'instr': '00000000',
    'pc': '80000000'
},
{
    'A3': 0,
    'A2': 0,
    'A1': 4028,
    'A0': 0,
    'instr': 'F14022F3',
    'pc': '80000000'
},
{
    'A3': 0,
    'A2': 0,
    'A1': 4028,
    'A0': 0,
    'instr': '8A010113',
    'pc': '8000000C'
},
{
    'A3': 0,
    'A2': 0,
    'A1': 4028,
    'A0': 0,
    'instr': '0280006F',
    'pc': '80000010'
},
{
    'A3': 2147551272,
    'A2': 5063528411713059128,
    'A1': 2147551272,
    'A0': 8,
    'instr': 'FEF760E3',
    'pc': '800007A0'
}
]

seed_values = [
    11806078428487616667595100393877188612246406242155061336067773483696989000736494004054006429374090960102566967936116921923046441487106498268898839523731684,
    10830175431449689389649939503930932214491902249168567446969045384872327938557471652274447065375505551205183343985222416134942588750294913863109553079849262
    # 11701581837841963276894014534419707858330783084199615018119541543271944538834208043257789107411541233071098083684234512901474585728442933004339228388405226,
    # 2856606689754592115309952821242076177262750807436196338552332128667145561798718848771686246226516703758489898577814654170947393255129774889165426335379257,
    # 238324089197754441094168637527561981457839715565789971881596257641921709749536134816705605314348443542558840486379178175885611492839509090200428313006102
]

subplots_count = len(seed_values)
# create 5 subplots 1 under another
fig, axs = plt.subplots(subplots_count, 1, figsize=(10, 10))

# value_sent = set_atf_seed_input(seed_values[0], seed_bit_width=1024)
# orignal_value = seed_values[0]
# print()
# print(f'value_sent=  {value_sent}\n')
# print(f'orignal_value=  {orignal_value}\n')

# for i, my_row in enumerate(my_rows):
#     print(f'row {i}:')
#     b = convert_row_data_to_binary_representation(my_row, bits_size=1024)
#     # print(b)
#     ones = calculate_similarities([int(b, 2)], seed_values[0], bits_size=512)[0]
#     print(f'pc={my_row["pc"]}, instr={my_row["instr"]}, ones={ones}')
#     print()

# exit()


df['int_repr'] = df.apply(lambda row: str(convert_row_data_to_binary_representation(row)), axis=1)

for i in range(subplots_count):
    # df['similarities_diff_1'] = calculate_diff_similarities(df['int_repr'].values)
    # df['similarities_diff_1'].plot(marker='o', linestyle='None', figsize=(10, 5))
    #random binary string of length 1024

    # seed_value = int(''.join(np.random.choice(['0', '1'], size=512)), 2)
    seed_value = seed_values[i]
    print(f'seed_value={seed_value}')
    df[f'similarities_{i}'] = calculate_similarities(df['int_repr'].values, seed_value)
    # df[f'similarities_{i}'].plot(ax=axs[i], marker='o', markersize=2, linestyle='None', figsize=(10, 5))


    value_counts = df[f'similarities_{i}'].value_counts() 
    indices_to_keep = df[f'similarities_{i}'][ df[f'similarities_{i}'].apply(lambda x: value_counts[x] < 40) ].index

    df[f'similarities_{i}'].plot(ax=axs[i], marker='o', markersize=4, linestyle='-', linewidth=1, markerfacecolor='purple', markeredgecolor='black', figsize=(10, 5))

    df[f'similarities_{i}'].loc[indices_to_keep].plot(ax=axs[i], marker='o', markersize=6, linestyle='-', linewidth=1, color='red', markerfacecolor='red', markeredgecolor='black', figsize=(10, 5))




    
fig.show()

jal_indices = df[df['instr_names'] == 'JAL'].index
j_indices = df[df['instr_names'] == 'J'].index


pcs_at_jal = df[df['instr_names'] == 'JAL']['pc']
pcs_at_j = df[df['instr_names'] == 'J']['pc']

# list unique program counters at JAL instructions
unique_pcs_jal = df[df['instr_names'] == 'JAL']['pc'].unique()
unique_pcs_j = df[df['instr_names'] == 'J']['pc'].unique()

print(unique_pcs_jal)
print(unique_pcs_j)


sorted_indices_without_repetitions = sorted(list(set(jal_indices) | set(j_indices)))

jal_times = times_between_indices(df['exec_time'], jal_indices)
j_times = times_between_indices(df['exec_time'], j_indices)
both_times = times_between_indices(df['exec_time'], sorted_indices_without_repetitions)
# plt.plot(jal_times, marker='o', linestyle='None', label='JAL times')
# plt.plot(j_times, marker='o', linestyle='None', label='J times')
# plt.plot(both_times, marker='o', linestyle='None', label='JAL and J indices')


plt.legend()
plt.show()