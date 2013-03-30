function VVK_getWatchersCheckBoxes(watchers_dom_id) {
  return bw_users=$('#' + watchers_dom_id + '-users [type=checkbox]');
}

function toggleWatchersCheckBoxes(ids_to_toggle_str,on_off_str,watchers_dom_id) {
  var user_ids=jQuery.parseJSON(ids_to_toggle_str);
  var turn_on=jQuery.parseJSON(on_off_str);
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

  if(user_check_boxes!=null) {
    var i;
    for(i=0;i<user_check_boxes.length;i++) {
      if(user_ids[0] == -1 || user_ids.indexOf(parseInt(user_check_boxes[i].value)) != -1) {
        if(turn_on==-1) {
          turn_on = !user_check_boxes[i].checked;
        }
        user_check_boxes[i].checked=turn_on;
      }
    }
  }
}

function highlightWatchers(watchers_dom_id) {
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

  if(user_check_boxes!=null) {
    var value=$('#'+watchers_dom_id+'-search').val().toUpperCase();
    var i;
    var user_name;
    var label_elem;

    for(i=0;i<user_check_boxes.length;i++) {
      label_elem=$(user_check_boxes[i]).parent();
      label_elem.removeClass('bw-floating');
      label_elem.removeClass('bw-floating-select');

      user_name=label_elem.attr('full_text').toUpperCase();

      if(value.length > 1 && user_name.indexOf(value) >= 0) {
        label_elem.addClass('bw-floating-select');
      } else {
        label_elem.addClass('bw-floating');
      }
    }
  }
}

function toggleSelectedWatchers(on_off_str,watchers_dom_id) {
  var turn_on=jQuery.parseJSON(on_off_str);
  var user_check_boxes=VVK_getWatchersCheckBoxes(watchers_dom_id);

  if(user_check_boxes!=null) {
    var i;

    for(i=0;i<user_check_boxes.length;i++) {
      if($(user_check_boxes[i]).parent().hasClass('bw-floating-select')) {
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
