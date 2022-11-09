import {*} with "./utils/parent_suggestion.jac";
import {*} with "./utils/utils.jac";
import {*} with "./utils/similarity.jac";

walker init{
    has user_file = 'data/data/user_2/2022-08-01.json', config_file = 'config/config.yaml';
    has new_wkt_name = "Review Riva PR";
    can file.load_json;
    root {
        user_data = file.load_json(user_file);
        day_node = spawn here walker::build_graph(json_file= user_file, end=user_data.length-2);

        spawn here walker::create_similarity_head_list;

        uuid = spawn here walker::create_similarity_head;

        untrained_best_match = spawn day_node walker::get_suggested_parent(ph_id=uuid, new_wkt_name=new_wkt_name);

        spawn here walker::train_similarity(uuid=uuid);
        new_weights_path = 'output/models/MycaParentTrainer/' + uuid + '/model_best.pth';
        spawn here walker::update_similarity(uuid=uuid, path=new_weights_path);

        trained_best_match = spawn day_node walker::get_suggested_parent(ph_id=uuid, new_wkt_name=new_wkt_name);
    }
}