walker create_similarity_head_list {
    can ph.create_head_list;
    ph.create_head_list(config_file = "config/config.yaml");
}

walker create_similarity_head {
    has anchor uuid;
    can ph.create_head;

    uuid = ph.create_head();
    report uuid;
}

walker predict_similarity {
    has anchor output;
    has uuid, data;
    can ph.predict;

    output = ph.predict(uuid = uuid, data=data);
}

walker train_similarity {
    has uuid, config;
    can ph.train;

    ph.train(uuid = uuid, config_file=config);
}

walker update_similarity {
    has uuid, path;
    can ph.update_weights;

    ph.update_weights(uuid = uuid, path=path);
}