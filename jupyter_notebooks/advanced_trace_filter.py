# Advanced trace filter (ATF) configuration functions are in "continuous_monitoring_system_controller.py"

import json
import os
from copy import deepcopy
from threading import Lock
# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt

class ATF_MODE:
    PATTERN_COLLECTION = 0
    ANOMALY_DETECTION = 1

# helper functions
def bits_in_int(n, bit_type, bit_size=1024):
    count = 0
    while n:
        n &= n - 1
        count += 1
    if bit_type == 0:
        return bit_size - count
    return count

def calculate_atf_pkt_deterministic_offset(key):
    offset = 0
    keys = list(atf_pkt_deterministic_structure.keys())
    for k in reversed(keys):
        if k == key:
            return offset
        offset += atf_pkt_deterministic_structure[k]

def create_seed_mask_and_range_for_values(values_dict):
    seed = 0
    mask = 0
    for k, v in values_dict.items():
        mask_chunk = ((1 << atf_pkt_deterministic_structure[k]) - 1) << calculate_atf_pkt_deterministic_offset(k)
        mask |= mask_chunk
        seed |= (v << calculate_atf_pkt_deterministic_offset(k)) & mask_chunk
    # range is a single number, it is equal to the number of bits in the mask
    # this way the specified seed must match exactly the current atf_data_pkt_deterministic, resulting in the number
    # of positive bits equal to range_
    range_ = bits_in_int(mask, bit_type=1, bit_size=1024) 
    return seed, mask, range_

# must match the atf_data_pkt_deterministic structure in "continuous_monitoring_system.sv" file
atf_pkt_deterministic_structure = {
    # from MSB to LSB
    # 'bits T6': 64,
    # 'bits T5': 64,
    # 'bits T4': 64,
    # 'bits T3': 64,
    # 'bits S11': 64,
    # 'bits S10': 64,
    # 'bits S9': 64,
    # 'bits S8': 64,
    # 'bits S7': 64,
    # 'bits S6': 64,
    # 'bits S5': 64,
    # 'bits S4': 64,
    # 'bits S3': 64,
    'S2': 64,
    # 'bits A7': 64,
    # 'bits A6': 64,
    # 'bits A5': 64,
    # 'bits A4': 64,
    'A3': 64, # fourth argument
    'A2': 64, # third argument
    'A1': 64, # second argument
    'A0': 64, # first argument (and return value)
    'S1': 64, # saved register
    'FP': 64, # frame pointer (S0)
    # 'bits T2': 64,
    'T1': 64,
    'T0': 64, # temporary register
    'TP': 64, # thread pointer
    'GP': 64, # global pointer
    'SP': 64, # stack pointer
    'RA': 64, # return address
    'HPCs' : 39, # performance event indicating bits
    'instr': 32,
    'PC': 64  # program counter
}

class ATF_Rules:
    def __init__(self, cms_ctrl):
        self.cms_ctrl = cms_ctrl
        self.rules_lock = Lock()
        self.rules = {} # key = index, value = dict like:
                        # { 
                        #   "active" : True,
                        #   "attributes" : {"PC":0x80000000, "A0":1000}
                        # }
        # self.load_rules()
        # self.push_all_rules_to_cms()

    def load_rules(self, f_name="atf_rules.json"):
        # if file exists
        if os.path.exists(f_name):
            try:
                with open(f_name) as f:
                    self.rules = {int(k):v for k, v in json.load(f).items()}
            except Exception as e:
                print("Error loading atf rules:", e)
                self.rules = {}
        else:
            print(f"No '{f_name}' file found.")

    def push_all_rules_to_cms(self):
        self.cms_ctrl.reset_atf()
        with self.rules_lock:
            for index, rule in self.rules.items():
                if not rule["active"]:
                    continue
                self.cms_ctrl.set_atf_match_rule(int(index), rule["attributes"])
    
    def store_rules(self, f_name="atf_rules.json"):
        with open(f_name, 'w') as f:
            json.dump(self.rules, f, indent=4)
    
    def get_rules(self):
        with self.rules_lock:
            return deepcopy(self.rules)

    def get_rules_as_strings(self):
        ''' This is needed because cJSON does not support 64-bit values, so we convert them to hex '''
        with self.rules_lock:
            rules_str = deepcopy(self.rules)
        
        for index, rule in rules_str.items():
            for k, v in rule["attributes"].items():
                rules_str[index]["attributes"][k] = hex(v)[2:]
        # return dict with values as hex strings
        return rules_str

    def has_rule(self, index):
        index = int(index)
        return index in self.rules

    def set_rule(self, index, attributes_dict, is_active):
        # convert all attributes to numerical values from hex strings
        # this is needed because cJSON does not support 64-bit values
        index = int(index)
        for k, v in attributes_dict.items():
            try:
                attributes_dict[k] = int(v, 16)
            except Exception as e:
                print(f"advanced_trace_filter set_rule error converting attribute {k} to int: {e}")

        with self.rules_lock:
            self.rules[index] = {
                "active" : is_active,
                "attributes" : attributes_dict
            }
        if is_active:
            self.cms_ctrl.set_atf_match_rule(int(index), attributes_dict)
        else:
            self.cms_ctrl.reset_atf_match_rule(int(index))
        self.store_rules()
    
    def set_rule_active(self, index, is_active):
        index = int(index)
        if index not in self.rules:
            raise Exception(f"Rule with index {index} does not exist. Can't set active state.")
        with self.rules_lock:
            self.rules[index]["active"] = is_active
        if is_active:
            self.cms_ctrl.set_atf_match_rule(index, self.rules[index]["attributes"])
        else:
            self.cms_ctrl.reset_atf_match_rule(index)
        self.store_rules()


        

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

# def bits_in_int(n, bit_type=1, bits_size=1024):
#     count = 0
#     while n:
#         n &= n - 1
#         count += 1
#     if bit_type == 0:
#         return bits_size - count
#     return count

# def calculate_similarities(pattern_series, seed_value, bits_size=1024):
#     similarities = []
#     for i, val in enumerate(pattern_series):
#         similarity = bits_in_int(val ^ seed_value, bit_type=0, bits_size=bits_size) 
#         similarities.append(similarity)
#     return similarities

# def plot_similarities(pattern_series, seed_values, frequency_threshold=40):
#     subplots_count = len(seed_values)
#     fig, axs = plt.subplots(subplots_count, 1, figsize=(10, 10))
#     for i in range(subplots_count):
#         similarities = pd.Series( calculate_similarities(pattern_series, seed_values[i]) )
#         # df[f'similarities_{i}'].plot(ax=axs[i], marker='o', markersize=2, linestyle='None', figsize=(10, 5))
#         value_counts = similarities.value_counts() 
#         indices_to_keep = similarities[ similarities.apply(lambda x: value_counts[x] < frequency_threshold) ].index
#         similarities.plot(ax=axs[i], marker='o', markersize=4, linestyle='-', linewidth=1, markerfacecolor='purple', markeredgecolor='black', figsize=(10, 5))
#         similarities.loc[indices_to_keep].plot(ax=axs[i], marker='o', markersize=6, linestyle='-', linewidth=1, color='red', markerfacecolor='red', markeredgecolor='black', figsize=(10, 5))
#     fig.show()
#     plt.show()

# if __name__ == '__main__':
#     seed_values = [
#         177711519189312448730221354182231558637597247368997856568353600156165082445924819823086537219813803655034425629222957323519789380881194761015097109113643492436494853351158801548809156587381022653656419362316880053721686257530213295492302669648879908944155843661259355247416136342707255439323305353187196384197,
#         97081571863202119540470995029932637987382626048125687395340616282408632421277679546841495729477368094495309346930269433005263784085567995676967413458616276771557870749853558953668198221519854005958192694960818014644861142877940285940418374394054218041391691990482562200656727048780580334389685158025765443103,
#         72988107250237495920102714721503671840119863320115041683284531007689094102132598416320545594765641915178544865414967713102711085720852615743397925981381353282342725210089676502129828507026310241957836986390459284800711987057378064364236224455662089777969480543544087753566469674185432144927462598143211900517,
#         106738977566983570110852620103400377292300453533011930141192199599635355298019566489684667006901891008645206022308884524698672777156607193011201304696737478287933507774884537488656010294279259572309150944453315991769055525611886872257222021232796393976378766870457343819513999607183988917017181317401129555928,
#         169792675614791427976691633934932484586471498037900305609681272694122116775948066266882052337887995216909734192970940273795107953077453183798027110768376688442875847747615398585154418296643575223613186058178239082384113881177527628936523102969662509304773940933200420209467102324760081730668971104131876503488
#         ]
#     # def create_big_integer_of_size(size):
#     #     return int(''.join(np.random.choice(['0', '1'], size=size)), 2)
#     # seed_values = [create_big_integer_of_size(1024) for i in range(5)]
#     pattern_series = pd.Series(np.random.randint(0, 1024, size=1000))
#     plot_similarities(pattern_series, seed_values=seed_values)
