function VVK_getWatchersCheckBoxes(watchers_dom_id) {
  var bw_users=$(watchers_dom_id+'-users');

  return bw_users == null ? null : Prototype.Selector.select("input[type=checkbox]", bw_users);
}


function toggleWatchersCheckBoxes(ids_to_toggle_str,on_off_str,watchers_dom_id) {
    var user_ids=ids_to_toggle_str.evalJSON();
    var turn_on=on_off_str.evalJSON();
    var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

    if(user_check_boxes!=null) {
      var i;
      for(i=0;i<user_check_boxes.length;i++) {
        if(user_ids[0] == -1 || user_ids.indexOf(parseInt(user_check_boxes[i].value)) != -1) {
            if(turn_on==-1) {
              if(user_check_boxes[i].checked==0) {
                turn_on=1;
              } else {
                turn_on=0;
              }
            }
            user_check_boxes[i].checked=turn_on;
        }
      }
    }
}

function highlightWatchers(watchers_dom_id) {
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

  if(user_check_boxes!=null) {
    var value=$(watchers_dom_id+'-search').value.toUpperCase();
    var i;
    var user_name;
    var label_elem;

    for(i=0;i<user_check_boxes.length;i++) {
      label_elem=user_check_boxes[i].up();
      label_elem.removeClassName('bw-floating');
      label_elem.removeClassName('bw-floating-select');

      user_name=label_elem.readAttribute('full_text').toUpperCase();

      if(value.length > 1 && user_name.include(value)) {
        label_elem.addClassName('bw-floating-select');
      } else {
        label_elem.addClassName('bw-floating');
      }
    }
  }
}

function toggleSelectedWatchers(on_off_str,watchers_dom_id) {
  var turn_on=on_off_str.evalJSON();
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

  if(user_check_boxes!=null) {
    var i;

    for(i=0;i<user_check_boxes.length;i++) {
      if(user_check_boxes[i].up().hasClassName('bw-floating-select')) {
        user_check_boxes[i].checked=turn_on;
      }
    }

  }
}

function serializeWatchersForRemote(watchers_pfx,watchers_dom_id) {
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);
  var uri_str;

  uri_str='';

  if(user_check_boxes!=null) {
    var i;

    for(i=0;i<user_check_boxes.length;i++) {
      if(user_check_boxes[i].checked) {
        uri_str += (watchers_pfx + '=' + user_check_boxes[i].value + '&')
      }
    }
  }

  return uri_str;
}
