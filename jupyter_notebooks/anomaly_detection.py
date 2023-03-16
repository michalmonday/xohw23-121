import numpy as np
from threading import Lock

class Anomaly_Detection:
    ''' Multidimensional distance based detection. '''
    def __init__(self, n_features):
        self.dataset = np.empty((0, n_features))
        self.n_features = n_features
        self.vectors_hashes = set()
        self.dataset_lock = Lock()

    def reset_dataset(self):
        with self.dataset_lock:
            del self.dataset
            del self.vectors_hashes
            self.dataset = np.empty((0, self.n_features))
            self.vectors_hashes = set()
    
    def hash_vector(self, counters_vector):
        ''' Result may be different after each run for the same values. 
        This needs to be remembered if we want to save the hashes and load them later. '''
        return hash(tuple(counters_vector))

    def update_dataset(self, counters_vector):
        vector_hash = self.hash_vector(counters_vector)
        if not self.is_vector_hash_in_dataset(vector_hash):
            self.vectors_hashes.add(vector_hash)
            with self.dataset_lock:
                self.dataset = np.vstack([self.dataset, counters_vector])

    def is_vector_hash_in_dataset(self, vector_hash):
        with self.dataset_lock:
            return vector_hash in self.vectors_hashes

    def get_max_cosine_similarity(self, counters_vector):
        if self.dataset.shape[0] == 0:
            return 0
        vector_hash = self.hash_vector(counters_vector)
        if self.is_vector_hash_in_dataset(vector_hash): 
            return 1
        with self.dataset_lock:
            return np.max(np.dot(self.dataset, counters_vector) / (np.linalg.norm(self.dataset, axis=1) * np.linalg.norm(counters_vector)))

    # def get_min_distance(self, counters_vector):
    #     if self.dataset.shape[0] == 0: return -1
    #     return np.min(np.linalg.norm(self.dataset - counters_vector, axis=1))

    # def add_random_value_to_dataset(self):
    #     self.dataset = np.vstack([self.dataset, np.random.rand(self.n_features)])
    
    def get_dataset_size(self):
        return self.dataset.shape[0]
    
    # def get_dataset_max_value(self):
    #     return np.max(self.dataset)
    
    def is_vector_anomaly(self, counters_vector):
        # threshold = self.get_dataset_max_value() * threshold_factor
        # return self.get_min_distance(counters_vector) > threshold
        return self.get_max_cosine_similarity(counters_vector) < 0.8
    
if __name__ == '__main__':
    dm = Anomaly_Detection(50)

    n_samples = 1000
    for i in range(n_samples):
        counters_vector = np.random.randint(0,100, 50)
        dm.update_dataset(counters_vector)
        last_counters_vector = counters_vector
    
    n_tests = 10
    for i in range(n_tests):
        counters_vector = np.random.randint(0,100, 50)
        if i == n_tests - 1:
            counters_vector = last_counters_vector
            counters_vector[0] = 2000
        print(f'Min distance: {dm.get_min_distance(counters_vector)}')
        print(f'Max cosine similarity: {dm.get_max_cosine_similarity(counters_vector)}')
        print(f'Is anomaly: {dm.is_vector_anomaly(counters_vector)}')
        print()

    print()