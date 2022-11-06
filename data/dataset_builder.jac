node workette {
    # Note last updated used when?
    # links?
    has name, order, date, status, snooze_till, color, links, expanded_children, note_last_updated;
    has wtype, note, is_MIT, is_ritual, is_active;
    has recurring_order;
    # What are run-start, run-time;
    has run_start, run_time;
    has private name_emb, name_used_for_emb, note_emb, note_used_for_emb;
    has highlight_type;
    has focus_order, ritual_order;
}

edge parent;

node day {
    has anchor day, note, order, focus_order = [], ritual_order = [], expanded_children, show_hidden_items, focusR, log, highlevel_groups, note_last_updated;
    has recurring_order;
    has ll_version, item_filters;
    can date.quantize_to_day, date.date_day_diff;
}

walker build_graph {
    has anchor day_node;
    has json_file;
    has end;
    has nodes = {};
    can file.load_json;

    root{
        user_data = file.load_json(json_file);
        day_node = spawn node::day;

        for i=0 to i < end by i+=1{
            node_text = user_data[i].text;
            node_id = user_data[i].id;
            node_type = user_data[i].wtype;
            node_parent = user_data[i].parent;
            if (node_type == "daynode") {
                nodes[node_id] = day_node;
            } else {
                wrkt_node = spawn node::workette(wtype=node_type, name=node_text);
                nodes[node_parent] -[parent]-> wrkt_node;
                nodes[node_id] = wrkt_node;
            }
        }
    }
}

walker get_nodes_dict {
    has anchor nodes = {};
    has json_file;

    root{
        user_data = file.load_json(json_file);
        for i=0 to i < user_data.length by i+=1{
            node_id = user_data[i].id;
            node_text = user_data[i].text;
            nodes[node_id] = node_text;
        }
    }
}

walker get_path_strings {
    has max_levels, curr_level;
    has start_str_list = [];
    has anchor paths= [];

    with entry {
        if (!curr_level): curr_level = 1;
    }

    day {
        take --> node::workette;
    }

    workette {
        if (curr_level > max_levels  || here.status == 'done' || here.status == 'canceled'): skip;

        if (start_str_list.length): current_str_list = start_str_list;
        else: current_str_list = [here.name];
        
        workset_str_list = current_str_list.list::copy;
        for subwrkt in -[parent]-> node:: workette{
            workset_str_list.list::append(subwrkt.name);
            if (subwrkt.name): current_str_list.list::append(subwrkt.name);
            subwrkt_paths = spawn subwrkt walker::get_path_strings(start_str_list = current_str_list.list::copy, max_levels = max_levels, curr_level = curr_level+1);
            paths.list::extend(subwrkt_paths);
            if (current_str_list.length): current_str_list.list::pop;
        }
        if (here.wtype=="workset"): paths.list::append([workset_str_list, here, 1]);
    }
}

walker build_dataset {
    has json_files;
    can file.load_json, file.dump_json;

    root {
        dataset = {};
        // json_files = file.load_json('test_files.json');
        json_files = ["2022-08-01.json"];
        for json_file in json_files {
            results = [];
            user_data = file.load_json(json_file);
            nodes = spawn here walker::get_nodes_dict(json_file = json_file);
            
            for i=2 to i < 44 by i+=1{
                
                workette_txt = user_data[i].text;
                target_node_txt = nodes[user_data[i].parent];
                if (user_data[i].wtype == "workette"){
                    std.out("Processing node",i,"of",user_data.length);
                    day_graph_node = spawn here walker::build_graph(json_file=json_file, end=i);
                    paths = spawn day_graph_node walker::get_path_strings(max_levels=2);

                    for path in paths {
                        results.list::append([path[0], path[1].name, workette_txt, target_node_txt]);
                    }
                }
            }

            dataset[json_file] = results;
        }
        file.dump_json("dataset.json", dataset);
    }
}

walker init {
    root {
        spawn here walker::build_dataset;
    }
}
