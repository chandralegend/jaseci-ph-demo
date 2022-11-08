import {*} with "./similarity.jac";

walker get_suggested_parent {
    has anchor curr_best_match;

    has ph_id;
    has new_wkt_name, similarity_threshold, max_levels;
    has new_wrkt_emb, matches;

    can use.get_embedding;

    with entry{
        matches = [];
        curr_best_match = [null, 0.0];
        if (!similarity_threshold): similarity_threshold = 0.0;
        if (!max_levels): max_levels = 2;
        new_wrkt_emb = use.get_embedding(new_wkt_name)[0];
        std.log("===================================");
        std.log("new get_suggested_parent is invoked");
        std.log("===================================");
    }

    day {
        take --> node::workette;
    }

    workette {
        if (here.status == 'done' || here.status == 'canceled'): skip;
        if (here.wtype == 'workset'){
            root_emb = use.get_embedding(here.name)[0];
            root_sim = spawn here walker::predict_similarity(uuid=ph_id, data=[new_wrkt_emb, root_emb]);
            if (root_sim> similarity_threshold) {
                matches.list::append([here, root_sim, 0, here.name]);
            }
        }
        
        // Get all the Paths possible
        paths = spawn here walker::get_path_strings(max_levels=max_levels);
        
        // filtering out only the valid paths
        valid_paths = [];
        valid_joint_strings = [];
        for path in paths {
            if (path[1].status == 'done' || path[1].status == 'canceled'): continue;
            joined_str = "";
            for wrkt_name in path[0]{
                joined_str += wrkt_name;
                joined_str += " ";
            }
            valid_paths.list::append(path);
            valid_joint_strings.list::append(joined_str);
        }
        // batch encoding the valid paths
        if valid_joint_strings.length: answer_embs = use.get_embedding(valid_joint_strings);
        for i=0 to i<valid_joint_strings.length by i+=1{
            path_sim = spawn here walker::predict_similarity(uuid=ph_id, data=[new_wrkt_emb, answer_embs[i]]);
            if (path_sim > similarity_threshold) {
                matches.list::append([valid_paths[i][1], path_sim, valid_paths[i][2], valid_joint_strings[i]]);
            }
        }
    }

    with exit {
        // Get the best match
        if (matches.length) {
            best_matches = spawn here walker::get_best_wrkts(outputs=matches);
            if (best_matches.length){
                best_matches = std.sort_by_col(best_matches, 2);
                best_match = best_matches[-1];
                if (best_match[1] > curr_best_match[1]): curr_best_match = best_match;
            }
        }
 
        report [curr_best_match[0].name, curr_best_match[1]];
    }
}

walker get_path_strings {
    has anchor paths= [];

    has max_levels, curr_level;
    has start_str_list = [];

    with entry {
        if (!curr_level): curr_level = 1;
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

walker get_best_wrkts {
    has anchor curr_best_wrkts = [];
    has curr_best_score = 0;
    has outputs;
    has sorted_outputs;

    if (outputs.length): sorted_outputs = std.sort_by_col(outputs, 1, reverse=true);
    for output in sorted_outputs {
        if (output[1] > curr_best_score) {
            curr_best_wrkts = [];
            curr_best_wrkts.list::append(output);
            curr_best_score = output[1];
        } elif (output[1] == curr_best_score) {
            curr_best_wrkts.list::append(output);
        }
    }
}