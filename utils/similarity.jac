walker create_similarity_head_list {
    can ph.create_head_list;
    ph.create_head_list(config_file = "config/config.yaml");
}

walker create_similarity_head {
    has anchor _uuid;
    has uuid;
    can ph.create_head;
    if (!uuid): _uuid = ph.create_head();
    else: _uuid = ph.create_head(uuid = uuid);
}

walker predict_similarity {
    has anchor output;
    has uuid, data;
    can ph.predict;

    output = ph.predict(uuid = uuid, data=data);
}

walker train_similarity {
    has uuid, config;
    can ph.train_head;

    ph.train_head(config_file=config, uuid = uuid);
}

walker update_similarity {
    has uuid, path;
    can ph.load_weights;

    ph.load_weights(uuid = uuid, path=path);
}