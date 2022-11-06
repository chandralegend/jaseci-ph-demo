import torch
from jaseci_ai_kit.use_enc import encode
import pandas as pd

class MycaParentModel(torch.nn.Module):
    def __init__(self, embedding_length, ph_nhead, ph_ff_dim, batch_first, ph_nlayers):
        super().__init__()
        encoder_layer = torch.nn.TransformerEncoderLayer(
            d_model=embedding_length,
            nhead=ph_nhead,
            dim_feedforward=ph_ff_dim,
            batch_first=batch_first)
        self.encoder = torch.nn.TransformerEncoder(
            encoder_layer=encoder_layer, num_layers=ph_nlayers
        )
        self.cosine_similarity = torch.nn.CosineSimilarity(dim=1, eps=1e-6)
        torch.nn.init.xavier_uniform_(self.encoder.weight)

    def forward(self, emb1, emb2):
        x1 = self.encoder(emb1)
        x2 = self.encoder(emb2)
        x = self.cosine_similarity(x1, x2)
        return x

class MycaDataset(torch.utils.data.Dataset):
    def __init__(self, data_dir):
        self.data_dir = data_dir
        dataset_pd = pd.read_csv(data_dir)

        y = dataset_pd['output']
        self.y = torch.tensor(y)

        x1 = dataset_pd['joint_str']
        x2 = dataset_pd['wrkt_str']
        # encode the joint_str and wrkt_str
        x1 = encode(x1)
        x2 = encode(x2)
        self.x1 = torch.tensor(x1)
        self.x2 = torch.tensor(x2)
        self.x = torch.cat((self.x1, self.x2), 1)

    def __len__(self):
        return len(self.y)

    def __getitem__(self, idx):
        return (self.x1[idx], self.x2[idx]), self.y[idx]

class MycaPreProcessor:
    def __init__(self):
        pass

    def process(self, x):
        pass

class MycaPostProcessor:
    def __init__(self):
        pass

    def process(self, x):
        pass