# Advanced trace filter (ATF) configuration functions are in "continuous_monitoring_system_controller.py"
# This file provides functions to check/plot frequency of XNOR results and choose seeds/ranges for ATF.

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# def times_between_indices(time_column, indices, include_zero=True):
#     if include_zero:
#         indices = [0] + indices
#     times = []
#     for i, ind in enumerate(indices):
#         if i != len(indices) - 1:
#             t = time_column.loc[ind: indices[i+1]].sum()
#             times.append(t)
#     return times
# # df['exec_time_between_jal'].plot(marker='o', linestyle='None', figsize=(10, 5))

def bits_in_int(n, bit_type=1, bits_size=1024):
    count = 0
    while n:
        n &= n - 1
        count += 1
    if bit_type == 0:
        return bits_size - count
    return count

def calculate_similarities(pattern_series, seed_value, bits_size=1024):
    similarities = []
    for i, val in enumerate(pattern_series):
        similarity = bits_in_int(val ^ seed_value, bit_type=0, bits_size=bits_size) 
        similarities.append(similarity)
    return similarities

def plot_similarities(pattern_series, seed_values, frequency_threshold=40):
    subplots_count = len(seed_values)
    fig, axs = plt.subplots(subplots_count, 1, figsize=(10, 10))
    for i in range(subplots_count):
        similarities = pd.Series( calculate_similarities(pattern_series, seed_values[i]) )
        # df[f'similarities_{i}'].plot(ax=axs[i], marker='o', markersize=2, linestyle='None', figsize=(10, 5))
        value_counts = similarities.value_counts() 
        indices_to_keep = similarities[ similarities.apply(lambda x: value_counts[x] < frequency_threshold) ].index
        similarities.plot(ax=axs[i], marker='o', markersize=4, linestyle='-', linewidth=1, markerfacecolor='purple', markeredgecolor='black', figsize=(10, 5))
        similarities.loc[indices_to_keep].plot(ax=axs[i], marker='o', markersize=6, linestyle='-', linewidth=1, color='red', markerfacecolor='red', markeredgecolor='black', figsize=(10, 5))
    fig.show()
    plt.show()

if __name__ == '__main__':
    seed_values = [
        177711519189312448730221354182231558637597247368997856568353600156165082445924819823086537219813803655034425629222957323519789380881194761015097109113643492436494853351158801548809156587381022653656419362316880053721686257530213295492302669648879908944155843661259355247416136342707255439323305353187196384197,
        97081571863202119540470995029932637987382626048125687395340616282408632421277679546841495729477368094495309346930269433005263784085567995676967413458616276771557870749853558953668198221519854005958192694960818014644861142877940285940418374394054218041391691990482562200656727048780580334389685158025765443103,
        72988107250237495920102714721503671840119863320115041683284531007689094102132598416320545594765641915178544865414967713102711085720852615743397925981381353282342725210089676502129828507026310241957836986390459284800711987057378064364236224455662089777969480543544087753566469674185432144927462598143211900517,
        106738977566983570110852620103400377292300453533011930141192199599635355298019566489684667006901891008645206022308884524698672777156607193011201304696737478287933507774884537488656010294279259572309150944453315991769055525611886872257222021232796393976378766870457343819513999607183988917017181317401129555928,
        169792675614791427976691633934932484586471498037900305609681272694122116775948066266882052337887995216909734192970940273795107953077453183798027110768376688442875847747615398585154418296643575223613186058178239082384113881177527628936523102969662509304773940933200420209467102324760081730668971104131876503488
        ]
    # def create_big_integer_of_size(size):
    #     return int(''.join(np.random.choice(['0', '1'], size=size)), 2)
    # seed_values = [create_big_integer_of_size(1024) for i in range(5)]
    pattern_series = pd.Series(np.random.randint(0, 1024, size=1000))
    plot_similarities(pattern_series, seed_values=seed_values)
