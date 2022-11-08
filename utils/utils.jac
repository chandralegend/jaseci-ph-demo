node workette {
    has name, order, date, status, snooze_till, color, links, expanded_children, note_last_updated;
    has wtype, note, is_MIT, is_ritual, is_active;
    has recurring_order;
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