import {*} with "./utils/parent_suggestion.jac";
import {*} with "./utils/utils.jac";
import {*} with "./utils/similarity.jac";

walker app{
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

walker generate_results {
    has user;
    can file.load_json, file.dump_json;

    root {
        // creating a ph_list
        spawn here walker::create_similarity_head_list;

        // creating a ph for the user
        uuid = spawn here walker::create_similarity_head;
        # In Production, we have to map the uuid to the user so we can bring it back later

        // loading the user's last month data
        user_file = 'data/data/' + user + '/2022-06-01.json';
        user_data = file.load_json(user_file);
        day_node = spawn here walker::build_graph(json_file=user_file, end=user_data.length);

        #loading the test data
        test_file = 'data/' + user + '_test_dataset.json';
        test_datas = file.load_json(test_file);

        // getting the best match for each test data using the untrained model
        untrained_outputs = [];
        for test_data in test_datas {
            new_wkt_name = test_data['wrkt_str'];
            best_match = spawn day_node walker::get_suggested_parent(ph_id=uuid, new_wkt_name=new_wkt_name);
            untrained_outputs.list::append({'new_wkt_name': new_wkt_name, 'best_match': best_match[0].name, 'target': test_data['target']});
        }
        untrained_output_file = 'output/' + user + '_untrained_outputs.json';
        file.dump_json(untrained_output_file, untrained_outputs);

        // training the model using the data collected until the last month
        spawn here walker::train_similarity(uuid=uuid);
        new_weights_path = 'output/models/MycaParentTrainer/' + uuid + '/model_best.pth';
        spawn here walker::update_similarity(uuid=uuid, path=new_weights_path);

        // getting the best match for each test data using the trained model
        trained_outputs = [];
        for test_data in test_datas {
            new_wkt_name = test_data['wrkt_str'];
            best_match = spawn day_node walker::get_suggested_parent(ph_id=uuid, new_wkt_name=new_wkt_name);
            trained_outputs.list::append({'new_wkt_name': new_wkt_name, 'best_match': best_match[0].name, 'target': test_data['target']});
        }
        trained_output_file = 'output/' + user + '_trained_outputs.json';
        file.dump_json(trained_output_file, trained_outputs);
    }
}

walker init {
    has user = 'user_3';
    root {
        spawn here walker::generate_results(user=user);
    }
}